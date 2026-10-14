import multiprocessing as mp
import numpy as np
from multiprocessing import Pool, cpu_count
import argparse
from collections import defaultdict, deque
import logging
import logging.handlers
import csv
import datetime
import math
import time
import json
import queue as _queue
import os
import copy

_global_graph = None
_global_cells = None
_global_tech_vias = None
_global_spef_nodes_by_net = None
_global_spef_pins_by_net = None
_global_spef_pin_name_to_node_by_net = None
_global_top_pins = None
_global_components = None
_global_dbu = None
_global_verbose = None
_global_spef_edge_dict = None
_global_def_point_to_pin_name = None 

# Store the shared read-only inputs (technology data, SPEF tables, DEF-to-pin names) in module globals of a worker process. #
# Called once per worker by multiprocessing.Pool, so the data is not sent again with every net.                             #
def init_worker(graph, cells, tech_vias, top_pins, components, dbu, verbose,
                spef_edge_dict, def_point_to_pin_name,
                spef_nodes_by_net, spef_pins_by_net, spef_pin_name_to_node_by_net):
    global _global_graph, _global_cells, _global_tech_vias, _global_top_pins, _global_components
    global _global_dbu, _global_verbose, _global_spef_edge_dict, _global_def_point_to_pin_name
    global _global_spef_nodes_by_net, _global_spef_pins_by_net, _global_spef_pin_name_to_node_by_net
    _global_graph = graph
    _global_cells = cells
    _global_tech_vias = tech_vias
    _global_top_pins = top_pins
    _global_components = components
    _global_dbu = dbu
    _global_verbose = verbose
    _global_spef_edge_dict = spef_edge_dict
    _global_def_point_to_pin_name = def_point_to_pin_name
    _global_spef_nodes_by_net = spef_nodes_by_net
    _global_spef_pins_by_net = spef_pins_by_net
    _global_spef_pin_name_to_node_by_net = spef_pin_name_to_node_by_net

def _process_net_wrapper(args):
    return process_net(*args)

# Process one net in a worker. Maps the DEF routing tree onto the SPEF RC tree, reads the resistance and capacitance of every         #
# DEF edge from the SPEF, adds the topology features and checks the result against the SPEF totals (resistance, length, capacitance). #
# Returns a dict with the mapping, the per-edge rows, the node rows, the skip reason (empty if the net passes) and the error          #
# percentages, or None if the DEF and SPEF trees cannot be mapped.                                                                    #
def process_net(net_name, def_net_info, spef_net_info, def_pin_points_for_net):
    import copy
    def_net_info = copy.deepcopy(def_net_info)
    
    logging.info(f"[Worker {os.getpid()}] processing net {net_name}")
    global _global_graph, _global_cells, _global_tech_vias, _global_top_pins, _global_components
    global _global_dbu, _global_verbose, _global_spef_edge_dict, _global_def_point_to_pin_name

    graph = _global_graph
    cells = _global_cells
    tech_vias = _global_tech_vias
    top_pins = _global_top_pins
    components = _global_components
    dbu = _global_dbu
    verbose = _global_verbose
    spef_edge_dict = _global_spef_edge_dict
    def_point_to_pin_name = _global_def_point_to_pin_name

    # Map every pin point back to its pin name #
    def_net_info['point_to_pin'] = {pt: nm for nm, pt in def_pin_points_for_net.items()}

    # Sort the DEF edges by their end points, so the result does not depend on the input order #
    if 'def_edges' in def_net_info:
        def_net_info['def_edges'] = sorted(
            def_net_info['def_edges'],
            key=lambda e: (_get_coords(e['p1']), _get_coords(e['p2']))
        )

    # Map the DEF points to SPEF nodes and the DEF edges to SPEF edges #
    def_to_spef, edge_map = map_net_by_reachable_sets(
        net_name, def_net_info, spef_net_info, graph,
        def_point_to_pin_name, def_pin_points_for_net,
        dbu, verbose,
    )

    # Step 1: select driver point (physical coord from def_pin_points_for_net) #
    driver_point_for_features = None

    # cell output pin (direction O) #
    for nm, pt in def_pin_points_for_net.items():
        if def_to_spef and graph.get(def_to_spef.get(pt, ''), {}).get('direction') == 'O':
            driver_point_for_features = pt
            break

    # top-level input port (direction I, no colon in SPEF node id) #
    if driver_point_for_features is None:
        for nm, pt in def_pin_points_for_net.items():
            spef_node = def_to_spef.get(pt, '') if def_to_spef else ''
            if (graph.get(spef_node, {}).get('direction') == 'I'
                    and ':' not in spef_node):
                driver_point_for_features = pt
                break

    if driver_point_for_features is None:
        driver_point_for_features = next(iter(def_pin_points_for_net.values()), None)

    # Step 2: build def_edge_adj #
    def_edge_adj = defaultdict(list)
    for e in def_net_info.get('def_edges', []):
        def_edge_adj[e['p1']].append(e['p2'])
        def_edge_adj[e['p2']].append(e['p1'])

    # Step 3: resolve driver to virtual key if physical coord has no edges #
    if driver_point_for_features is not None:
        virtual_key = ('virtual', driver_point_for_features)
        if (not def_edge_adj.get(driver_point_for_features)
                and def_edge_adj.get(virtual_key)):
            driver_point_for_features = virtual_key

    #  Step 4: derive driver SPEF node after virtual key resolution #
    driver_spef_node_for_features = (
        def_to_spef.get(driver_point_for_features)
        if def_to_spef and driver_point_for_features is not None
        else None
    )

    #  Step 5: build is_driver_set and is_sink_set #
    is_driver_set = set()
    is_sink_set = set()

    if def_to_spef and driver_point_for_features is not None:
        is_driver_set.add(driver_point_for_features)
        for nm, pt in def_pin_points_for_net.items():
            if pt != driver_point_for_features and ('virtual', pt) != driver_point_for_features:
                virtual_twin = ('virtual', pt)
                if virtual_twin in def_edge_adj:
                    # BFS visits virtual twin, not physical coord
                    is_sink_set.add(virtual_twin)
                else:
                    # BFS visits physical coord directly
                    is_sink_set.add(pt)

    # Layer ordering for index-based features #
    LAYER_ORDER = ['metal1', 'metal2', 'metal3', 'metal4', 'metal5',
                   'metal6', 'metal7', 'metal8', 'metal9', 'metal10']
    LAYER_IDX = {l: i for i, l in enumerate(LAYER_ORDER)}

    #  Step 6: edge length lookup #
    edge_len_lookup = {}
    zero_len_pairs = set()
    for e in def_net_info.get('def_edges', []):
        if e.get('zero_length'):
            edge_len_lookup[(e['p1'], e['p2'])] = 0.0
            edge_len_lookup[(e['p2'], e['p1'])] = 0.0
            zero_len_pairs.add((e['p1'], e['p2']))
            zero_len_pairs.add((e['p2'], e['p1']))
            continue
        points = [e['p1']] + e.get('intermediate', []) + [e['p2']]
        total = 0.0
        for i in range(len(points) - 1):
            ax, ay = _get_coords(points[i])
            bx, by = _get_coords(points[i + 1])
            total += abs(bx - ax) + abs(by - ay)
        total /= _global_dbu
        edge_len_lookup[(e['p1'], e['p2'])] = total
        edge_len_lookup[(e['p2'], e['p1'])] = total

    # Pin points set #
    pin_pts = set(def_pin_points_for_net.values())

    #  Step 7: forward BFS from driver #
    tree_depth = {}
    bfs_order = []
    if driver_point_for_features is not None:
        queue = deque([(driver_point_for_features, None, 0)])
        visited = {driver_point_for_features}
        while queue:
            node, parent, depth = queue.popleft()
            tree_depth[node] = depth
            bfs_order.append((node, parent))
            if isinstance(node, tuple) and isinstance(node[0], str) and node[0] == 'virtual':
                raw = node[1]
                if raw not in tree_depth:
                    tree_depth[raw] = depth
            for nbr in def_edge_adj.get(node, []):
                if nbr not in visited:
                    visited.add(nbr)
                    queue.append((nbr, node, depth + 1))

    all_def_nodes = set()
    for e in def_net_info.get('def_edges', []):
        all_def_nodes.add(e['p1'])
        all_def_nodes.add(e['p2'])

    unvisited = all_def_nodes - set(tree_depth.keys())
    component_offset = max(tree_depth.values()) + 100 if tree_depth else 100

    while unvisited:
        local_root = max(unvisited, key=lambda n: len(def_edge_adj.get(n, [])))
        queue = deque([(local_root, None, component_offset)])
        local_visited = {local_root}
        while queue:
            node, parent, depth = queue.popleft()
            tree_depth[node] = depth
            bfs_order.append((node, parent))
            if isinstance(node, tuple) and isinstance(node[0], str) and node[0] == 'virtual':
                raw = node[1]
                if raw not in tree_depth:
                    tree_depth[raw] = depth
            for nbr in def_edge_adj.get(node, []):
                if nbr not in local_visited and nbr not in tree_depth:
                    local_visited.add(nbr)
                    queue.append((nbr, node, depth + 1))
        unvisited -= local_visited
        component_offset += 100

    #  Step 8: bottom-up pass for subtree stats #
    bfs_parent_map = {}
    for node, parent in bfs_order:
        if node not in bfs_parent_map:
            bfs_parent_map[node] = parent

    subtree_n_sinks = {}
    subtree_total_len = {}
    for node, parent in reversed(bfs_order):
        own_sink = 1 if node in is_sink_set else 0
        children = [
            nbr for nbr in def_edge_adj.get(node, [])
            if tree_depth.get(nbr, -1) == tree_depth.get(node, 0) + 1
            and bfs_parent_map.get(nbr) == node
        ]
        subtree_n_sinks[node] = own_sink + sum(subtree_n_sinks.get(c, 0) for c in children)
        child_len = sum(
            edge_len_lookup.get((node, c), 0.0) + subtree_total_len.get(c, 0.0)
            for c in children
        )
        subtree_total_len[node] = child_len

    # No mapping was found, the net cannot be used #
    if def_to_spef is None:
        return None

    #  Step 9: sink count #
    driver_pin_name = next(
        (nm for nm, pt in def_pin_points_for_net.items()
         if pt == driver_point_for_features
         or ('virtual', pt) == driver_point_for_features),
        None
    )
    n_sink_pins = len(def_pin_points_for_net) - (1 if driver_pin_name else 0)

    spef_all_nodes = {nid for nid, nd in graph.items() if nd.get('net') == net_name}
    spef_pin_nodes = {nid for nid in spef_all_nodes
                      if graph[nid].get('coords') is not None
                      and graph[nid].get('direction') is not None}
    spef_steiner = {nid for nid in spef_all_nodes
                      if len(graph[nid].get('neighbors', {})) >= 3
                      and nid not in spef_pin_nodes}

    steiner_pts = def_net_info.get('steiner_points', {})
    def_physical = [pt for pt in steiner_pts
                    if not (isinstance(pt, tuple) and isinstance(pt[0], str))]
    def_virtual = [pt for pt in steiner_pts
                    if isinstance(pt, tuple) and isinstance(pt[0], str)
                    and pt[0] == 'virtual']

    edge_pts = {pt for e in def_net_info.get('def_edges', [])
                 for pt in (e['p1'], e['p2'])}
    def_split = [pt for pt in edge_pts
                 if isinstance(pt, tuple) and isinstance(pt[0], str)
                 and pt[0] in ('split', 'virtual_spf')]

    via_counts = {}
    for seg in def_net_info.get('segments', []):
        if seg.get('via'):
            via_counts[seg['via']] = via_counts.get(seg['via'], 0) + 1
    total_vias = sum(via_counts.values())
    via_detail = ', '.join(f"{v}x{k}" for k, v in sorted(via_counts.items()))

    for pt, data in steiner_pts.items():
        if isinstance(pt, tuple) and isinstance(pt[0], str):
            kind = pt[0]
            coord = data.get('coords') or _get_coords(pt)
        else:
            kind = 'physical'
            coord = pt
        degree = data.get('degree', '?')

    # Resistance, capacitance and length of every DEF edge, taken from the mapped SPEF edges #
    rc_data = compute_edge_rc_correlation_with_metal(
        net_name, def_net_info, spef_net_info,
        def_to_spef, edge_map, dbu, graph,
        spef_edge_dict=spef_edge_dict,
    )

    # Totals of the net in the SPEF and in the mapped DEF edges, used for the consistency checks #
    spef_total_R = sum(res['value'] for res in spef_net_info.get('res', []))
    spef_total_cap = spef_net_info['delay']
    total_def_length_um = compute_total_def_length_from_edges(def_net_info.get('def_edges', []), dbu)
    total_length_mapped = sum(item['total_length_um'] for item in rc_data)
    total_R_mapped = sum(
        item['R_ohms'] for item in rc_data
        if not item['def_edge'].get('zero_length', False)
    )

    # Build the output rows (edges and nodes) and check R, length and C against the SPEF. skip_reason is empty if all #
    # checks pass                                                                                                     #
    csv_rows, node_rows, skip_reason = compute_edge_features_for_csv(
        net_name=net_name,
        def_net_info=def_net_info,
        spef_net_info=spef_net_info,
        rc_data=rc_data,
        def_to_spef=def_to_spef,
        edge_map=edge_map,
        graph=graph,
        dbu_scale=dbu,
        spef_total_R=spef_total_R,
        spef_total_cap=spef_total_cap,
        total_length_mapped=total_length_mapped,
        total_def_length_um=total_def_length_um,
        def_adj=def_edge_adj,
        tree_depth=tree_depth,
        n_sink_pins=n_sink_pins,
        subtree_n_sinks=subtree_n_sinks,
        subtree_total_len=subtree_total_len,
        driver_def_point=driver_point_for_features,
        driver_spef_node=driver_spef_node_for_features,
    )

    # Capacitance check of a passing net, written to the log #
    if not skip_reason:
        edge_cap_sum = sum(row.get('C_edge_pf', 0.0) for row in csv_rows)
        node_cap_sum = sum(row.get('C_node_pf', 0.0) for row in node_rows)
        reconstructed_cap = edge_cap_sum + node_cap_sum

        cap_err_pct = (
            abs(reconstructed_cap - spef_total_cap) / spef_total_cap * 100.0
            if spef_total_cap > 1e-12 else 0.0
        )

        logging.info(
            f"[CAP CHECK] {net_name}: "
            f"edge_C={edge_cap_sum:.6g}, "
            f"node_C={node_cap_sum:.6g}, "
            f"total={reconstructed_cap:.6g}, "
            f"SPEF={spef_total_cap:.6g}, "
            f"err={cap_err_pct:.3f}%"
        )

    # Edge counts and the resistance error for the log #
    n_edges = len(def_net_info.get('def_edges', []))
    n_mapped = len(edge_map) if edge_map else 0
    n_zero = sum(1 for e in def_net_info.get('def_edges', []) if e.get('zero_length'))
    r_err_pct = abs(total_R_mapped - spef_total_R) / spef_total_R * 100 if spef_total_R > 1e-9 else 0.0

    if not skip_reason:
        logging.info(f"[PASS] {net_name}: "
                     f"edges={n_mapped}/{n_edges} mapped, zero={n_zero}, "
                     f"R={total_R_mapped:.3f} vs SPEF={spef_total_R:.3f} (err={r_err_pct:.2f}%), "
                     f"len={total_length_mapped:.3f}/{total_def_length_um:.3f}um")
    else:
        logging.info(f"[SKIP] {net_name}: {skip_reason} | "
                     f"edges={n_mapped}/{n_edges}, zero={n_zero}, "
                     f"R={total_R_mapped:.3f} vs SPEF={spef_total_R:.3f} (err={r_err_pct:.2f}%), "
                     f"len={total_length_mapped:.3f}/{total_def_length_um:.3f}um")

    # Length coverage failed. Compute the length of each unmapped edge (the value is not used further) #
    if skip_reason and "length coverage" in skip_reason:
        for e in def_net_info.get('def_edges', []):
            key = (e['p1'], e['p2'])
            if key not in edge_map:
                points = [e['p1']] + e.get('intermediate', []) + [e['p2']]
                seg_len = sum(
                    abs(_get_coords(points[i+1])[0] - _get_coords(points[i])[0]) +
                    abs(_get_coords(points[i+1])[1] - _get_coords(points[i])[1])
                    for i in range(len(points)-1)
                ) / dbu            

    # Total capacitance of the output rows (edges plus nodes) against the SPEF total #
    edge_cap_sum = sum(row.get('C_edge_pf', 0.0) for row in csv_rows) if not skip_reason else 0.0
    node_cap_sum = sum(row.get('C_node_pf', 0.0) for row in node_rows) if not skip_reason else 0.0
    total_C_mapped = edge_cap_sum + node_cap_sum

    c_err_pct = (
        abs(total_C_mapped - spef_total_cap) / spef_total_cap * 100.0
        if spef_total_cap > 1e-12 else 0.0
    )

    # Result of the net #
    return {
        'net_name':            net_name,
        'def_to_spef':         def_to_spef,
        'edge_map':            edge_map,
        'rc_data':             rc_data,
        'csv_rows':            csv_rows,
        'skip_reason':         skip_reason,

        'total_length_mapped': total_length_mapped,
        'total_def_length_um': total_def_length_um,

        'spef_total_R':        spef_total_R,
        'spef_total_cap':      spef_total_cap,

        'total_R_mapped':      total_R_mapped,
        'r_err_pct':           r_err_pct,

        'total_C_mapped':      total_C_mapped,
        'edge_cap_sum':        edge_cap_sum,
        'node_cap_sum':        node_cap_sum,
        'c_err_pct':           c_err_pct,

        'node_rows':           node_rows if not skip_reason else []
    }
 
# Sort key for DEF points of the three kinds. A raw point is (x, y), a virtual twin is ('virtual', (x, y)) and a split point is #
# ('split', (x, y), reachable set). The coordinates come first and the kind breaks ties (raw 0, virtual 1, split 2), so the     #
# order of the points is the same in every run.                                                                                 #
def _point_sort_key(pt):
    if isinstance(pt, tuple) and len(pt) >= 2 and isinstance(pt[0], str):
        if pt[0] == 'split':
            return (pt[1][0], pt[1][1], 2)
        return (pt[1][0], pt[1][1], 1)   # ('virtual', (x,y))
    return (pt[0], pt[1], 0)

def _get_coords(pt):
    if isinstance(pt, tuple) and len(pt) >= 2 and isinstance(pt[0], str):
        return pt[1]   # ('virtual',(x,y)) or ('split',(x,y),frozenset)
    return pt

# Metal layer of the wire between two points. Tries both directions, and the raw coordinates if the points are virtual or split #
# points. Returns None if the pair is unknown.                                                                                  #
def _lookup_layer(point_pair_layer, a, b):
    # Try the points as given, then their plain coordinates #
    for key in [(a, b), (b, a),
                (_get_coords(a), _get_coords(b)),
                (_get_coords(b), _get_coords(a))]:
        layer = point_pair_layer.get(key)
        if layer is not None:
            return layer
    return None

# Give every DEF node that has no SPEF node (def_to_spef) the SPEF node of its mapped neighbours. These are junctions that the    #
# SPEF has collapsed. One mapped neighbour or one distinct SPEF node: copy it. Several: take the SPEF node that lies on the paths #
# between them (the common interior, the one with the most connections if there are several). Otherwise take the SPEF node with   #
# the most connections. The node is named CollapsedSteiner<coord>. def_to_spef and point_to_pin are modified in place.            #
def _assign_unmatched_def_nodes(def_edges, def_adj, def_to_spef, point_to_pin,
                                spef_adj, verbose=False):
    all_def_nodes = set()
    for e in def_edges:
        all_def_nodes.add(e['p1'])
        all_def_nodes.add(e['p2'])
 
    # DEF nodes without a SPEF node #
    unmatched = [n for n in all_def_nodes if n not in def_to_spef]
    if not unmatched:
        return
  
    for node in unmatched:
        # Neighbours of the node that already have a SPEF node #
        mapped_neighbours = [
            (nb, def_to_spef[nb])
            for nb in def_adj.get(node, [])
            if nb in def_to_spef
        ]
 
        if not mapped_neighbours:
            continue
 
        # One mapped neighbour, the node is a collapsed point on the way to it #
        if len(mapped_neighbours) == 1:
            nb, spef_nb = mapped_neighbours[0]
            def_to_spef[node] = spef_nb
            if node not in point_to_pin:
                point_to_pin[node] = f"CollapsedSteiner{_get_coords(node)}"
            continue
 
        # Distinct SPEF nodes of the neighbours, in a fixed order #
        spef_nodes = [s for _, s in mapped_neighbours]
        seen = set()
        unique_spef = []
        for s in spef_nodes:
            if s not in seen:
                seen.add(s)
                unique_spef.append(s)
 
        # All neighbours sit on the same SPEF node #
        if len(unique_spef) == 1:
            def_to_spef[node] = unique_spef[0]
            if node not in point_to_pin:
                point_to_pin[node] = f"CollapsedSteiner{_get_coords(node)}"
            continue
 
        # Nodes between every pair of neighbour SPEF nodes. A collapsed junction lies on all of these paths #
        pair_interiors = []
        for i in range(len(unique_spef)):
            for j in range(i + 1, len(unique_spef)):
                path = find_path_spef(unique_spef[i], unique_spef[j], spef_adj)
                if path and len(path) > 2:
                    pair_interiors.append(set(path[1:-1]))
 
        # Intersection of the interiors #
        non_empty = [s for s in pair_interiors if s]
 
        if non_empty:
            common = non_empty[0].copy()
            for s in non_empty[1:]:
                common &= s
 
            if len(common) == 1:
                best = next(iter(common))
                def_to_spef[node] = best
                if node not in point_to_pin:
                    point_to_pin[node] = f"CollapsedSteiner{_get_coords(node)}"
                continue
 
            elif len(common) > 1:
                best = max(common,
                           key=lambda x: len(spef_adj.get(x, [])))
                def_to_spef[node] = best
                if node not in point_to_pin:
                    point_to_pin[node] = f"CollapsedSteiner{_get_coords(node)}"
                continue
 
        # Fallback, the neighbour SPEF node with the most connections #
        best = max(unique_spef,
                   key=lambda x: len(spef_adj.get(x, [])))
        def_to_spef[node] = best
        if node not in point_to_pin:
            point_to_pin[node] = f"CollapsedSteiner{_get_coords(node)}"
        if verbose:
            logging.debug(f"    [UNMATCHED] {node} -> SPEF {best} "
                  f"(fallback: max-degree among {unique_spef})")
 
def point_equals(p, coord):
    return _get_coords(p) == coord

# True if the coordinate lies on the edge, i.e. on one of its horizontal or vertical segments (end points included). #
# The edge is the chain p1, intermediate points, p2.                                                                 #
def is_point_on_edge(edge, coord):
    p1 = edge['p1']
    p2 = edge['p2']
    intermediates = edge.get('intermediate', [])
    # All corner points of the edge in order #
    points = [p1] + intermediates + [p2]
    x, y = coord
    for i in range(len(points)-1):
        a, b = points[i], points[i+1]
        ax, ay = _get_coords(a)
        bx, by = _get_coords(b)
        # Vertical segment, then horizontal segment #
        if ax == bx:  
            if ax == x and min(ay, by) <= y <= max(ay, by):
                return True
        elif ay == by: 
            if ay == y and min(ax, bx) <= x <= max(ax, bx):
                return True
    return False

# Split a DEF edge at a fraction of its Manhattan length. Returns the two new edges and the split point. The new edges keep #
# the original edge and the ratio in _split_info, and the layer of every new segment is written to point_pair_layer.        #
def split_edge_at_ratio(original_edge, ratio, point_pair_layer, dbu_scale):
    p1 = original_edge['p1']
    p2 = original_edge['p2']
    intermediates = original_edge.get('intermediate', [])
    points = [p1] + intermediates + [p2]

    # Length and layer of every segment of the edge #
    segments = []          
    total_len = 0
    for i in range(len(points)-1):
        a, b = points[i], points[i+1]
        ax, ay = _get_coords(a)
        bx, by = _get_coords(b)
        seg_len = abs(bx-ax) + abs(by-ay)
        layer = _lookup_layer(point_pair_layer, a, b)
        segments.append((layer, seg_len, a, b))
        total_len += seg_len

    # Walk along the segments until the target length is reached, then place the split point on that segment #
    target_len = ratio * total_len
    accumulated = 0
    split_point = None
    split_idx = None
    split_frac = None
    for idx, (layer, seg_len, a, b) in enumerate(segments):
        if accumulated + seg_len >= target_len - 1e-9:
            remaining = target_len - accumulated
            ax, ay = _get_coords(a)
            bx, by = _get_coords(b)
            if ax == bx: 
                direction = 1 if by > ay else -1
                split_y = ay + direction * remaining
                split_point = (ax, int(split_y))
            else:          
                direction = 1 if bx > ax else -1
                split_x = ax + direction * remaining
                split_point = (int(split_x), ay)
            split_idx = idx
            split_frac = remaining / seg_len
            break
        accumulated += seg_len

    if split_point is None:
        raise ValueError("Split point not found")

    points1 = [p1]
    points2 = [split_point]
    for i in range(split_idx):
        points1.append(points[i+1])
    points1.append(split_point)
    points2.extend(points[split_idx+1:])
    if points2[-1] != p2:
        points2.append(p2)

    edge1 = {
        'p1': p1,
        'p2': split_point,
        'intermediate': points1[1:-1],
        '_split_info': {
            'original_edge': original_edge,
            'ratio': ratio,
            'total_len': total_len,
            'side': 'first'
        }
    }
    edge2 = {
        'p1': split_point,
        'p2': p2,
        'intermediate': points2[1:-1],
        '_split_info': {
            'original_edge': original_edge,
            'ratio': 1 - ratio,
            'total_len': total_len,
            'side': 'second'
        }
    }

    segs1 = [edge1['p1']] + edge1['intermediate'] + [edge1['p2']]
    for i in range(len(segs1)-1):
        a, b = segs1[i], segs1[i+1]
        layer = _lookup_layer(point_pair_layer, a, b)
        if layer is None:
            layer = segments[split_idx][0]
        point_pair_layer[(a, b)] = layer
        point_pair_layer[(b, a)] = layer

    segs2 = [edge2['p1']] + edge2['intermediate'] + [edge2['p2']]
    for i in range(len(segs2)-1):
        a, b = segs2[i], segs2[i+1]
        layer = _lookup_layer(point_pair_layer, a, b)
        if layer is None:
            layer = segments[split_idx][0]
        point_pair_layer[(a, b)] = layer
        point_pair_layer[(b, a)] = layer

    return edge1, edge2, split_point

# Split a DEF edge at a given coordinate that lies on it. Returns the two new edges. Like split_edge_at_ratio, but the position is #
# a coordinate and not a length fraction. Raises ValueError if the coordinate is not on the edge.                                  #
def split_edge_at_coord(edge, target_coord, point_pair_layer):

    p1 = edge['p1']
    p2 = edge['p2']
    intermediates = edge.get('intermediate', [])
    points = [p1] + intermediates + [p2]

    # Total Manhattan length of the original edge #
    total_len_original = 0
    for i in range(len(points)-1):
        a, b = points[i], points[i+1]
        ax, ay = _get_coords(a)
        bx, by = _get_coords(b)
        total_len_original += abs(bx-ax) + abs(by-ay)

    # Find the segment that holds the coordinate and the fraction of that segment before it #
    target_x, target_y = target_coord
    split_idx = None
    split_frac = None
    for i in range(len(points)-1):
        a, b = points[i], points[i+1]
        ax, ay = _get_coords(a)
        bx, by = _get_coords(b)
        if ax == bx: 
            if ax == target_x and min(ay, by) <= target_y <= max(ay, by):
                split_idx = i
                seg_len = abs(by - ay)
                split_frac = 0 if seg_len == 0 else abs(target_y - ay) / seg_len
                break
        elif ay == by:  
            if ay == target_y and min(ax, bx) <= target_x <= max(ax, bx):
                split_idx = i
                seg_len = abs(bx - ax)
                split_frac = 0 if seg_len == 0 else abs(target_x - ax) / seg_len
                break

    if split_idx is None:
        raise ValueError(f"Coordinate {target_coord} not on edge {p1}->{p2}")

    # Corner points of the two new edges. Drop a corner that coincides with the split point #
    points1 = points[:split_idx+1] + [target_coord]
    points2 = [target_coord] + points[split_idx+1:]

    if points1[-2] == target_coord:
        points1.pop()
    if points2[0] == points2[1]:
        points2.pop(0)

    # The two new edges #
    edge1 = {
        'p1': p1,
        'p2': target_coord,
        'intermediate': points1[1:-1],
        '_split_info': {
            'original_edge': edge,
            'ratio': split_frac,
            'total_len': total_len_original,
            'side': 'first'
        }
    }
    edge2 = {
        'p1': target_coord,
        'p2': p2,
        'intermediate': points2[1:-1],
        '_split_info': {
            'original_edge': edge,
            'ratio': 1 - split_frac,
            'total_len': total_len_original,
            'side': 'second'
        }
    }

    # Register the layer of the new segments. If a segment has no layer yet, take it from the original segment it came #
    # from, else 'unknown'                                                                                             #
    segs1 = [edge1['p1']] + edge1['intermediate'] + [edge1['p2']]
    for i in range(len(segs1)-1):
        a, b = segs1[i], segs1[i+1]
        layer = _lookup_layer(point_pair_layer, a, b)
        if layer is None:
            for j in range(len(points)-1):
                if (_get_coords(points[j]) == _get_coords(a) and
                    _get_coords(points[j+1]) == _get_coords(b)) or \
                   (_get_coords(points[j]) == _get_coords(b) and
                    _get_coords(points[j+1]) == _get_coords(a)):
                    layer = _lookup_layer(point_pair_layer, points[j], points[j+1])
                    break
        if layer is None:
            layer = "unknown"
        point_pair_layer[(a, b)] = layer
        point_pair_layer[(b, a)] = layer

    segs2 = [edge2['p1']] + edge2['intermediate'] + [edge2['p2']]
    for i in range(len(segs2)-1):
        a, b = segs2[i], segs2[i+1]
        layer = _lookup_layer(point_pair_layer, a, b)
        if layer is None:
            for j in range(len(points)-1):
                if (_get_coords(points[j]) == _get_coords(a) and
                    _get_coords(points[j+1]) == _get_coords(b)) or \
                   (_get_coords(points[j]) == _get_coords(b) and
                    _get_coords(points[j+1]) == _get_coords(a)):
                    layer = _lookup_layer(point_pair_layer, points[j], points[j+1])
                    break
        if layer is None:
            layer = "unknown"
        point_pair_layer[(a, b)] = layer
        point_pair_layer[(b, a)] = layer

    return edge1, edge2

# Read the LEF geometry from the JSON file (data/configs/ng45_lef_geometry.json), which replaces parsing the LEF files. Returns #
# cells (macro -> pin -> list of (layer, rectangle), plus "_size"), tech_vias (via name -> list of (layer, rectangle))          #
# and viarules (rule name -> layers with enclosure, rectangle and spacing). Lists in the JSON become tuples.                    #
def load_lef_json(json_path):
    with open(json_path, "r") as f:
        raw = json.load(f)

    # Cell geometry #
    cells = {}
    for cell_name, pin_map in raw.get("cells", {}).items():
        rebuilt = {}
        for key, value in pin_map.items():
            if key == "_size":
                rebuilt["_size"] = tuple(value)
            else:
                rebuilt[key] = [(layer, tuple(rect)) for layer, rect in value]
        cells[cell_name] = rebuilt

    # Via shapes #
    tech_vias = {}
    for via_name, layer_list in raw.get("vias", {}).items():
        tech_vias[via_name] = [(layer, tuple(rect)) for layer, rect in layer_list]

    # Via rules. A rule that has rectangles and no via of the same name is also registered as a via #
    viarules = {}
    for rule_name, rule_data in raw.get("viarules", {}).items():
        layers = []
        via_layers = []
        for lyr in rule_data.get("layers", []):
            entry = {"name": lyr["name"]}
            if "enclosure" in lyr:
                entry["enclosure"] = tuple(lyr["enclosure"])
            if "rect" in lyr:
                entry["rect"] = tuple(lyr["rect"])
                via_layers.append((lyr["name"], tuple(lyr["rect"])))
            if "spacing" in lyr:
                entry["spacing"] = tuple(lyr["spacing"])
            layers.append(entry)
        viarules[rule_name] = {"name": rule_data.get("name", rule_name), "layers": layers}
        if rule_name not in tech_vias and via_layers:
            tech_vias[rule_name] = via_layers

    return cells, tech_vias, viarules

# Read the cell LEF file. Returns cells: macro -> {"_size": (width, height), pin name: [(layer, (xl, yl, xh, yh)), ...]}. #
# The lengths are multiplied by dbu to give database units. Only the pin shapes (PORT rectangles) are kept.               #
def parse_lef(lef_path, dbu):
    cells = {}
    current_cell = None
    current_pin = None
    in_port = False
    current_layer = None

    with open(lef_path, "r") as f:
        for raw_line in f:
            line = raw_line.strip()
            tokens = line.split()
            if not line or line.startswith("#") or not tokens:
                continue

            # Start of a macro #
            if tokens[0] == "MACRO" and len(tokens) >= 2:
                current_cell = tokens[1]
                cells[current_cell] = {}
                current_pin = None
                in_port = False
                current_layer = None
                continue

            # End of the macro #
            if tokens[0] == "END" and len(tokens) >= 2 and tokens[1] == current_cell:
                current_cell = None
                current_pin = None
                in_port = False
                current_layer = None
                continue

            if current_cell is None:
                continue

            # Cell width and height #
            if tokens[0] == "SIZE" and len(tokens) >= 5 and tokens[2] == "BY":
                try:
                    cells[current_cell]['_size'] = (
                        float(tokens[1]) * dbu,
                        float(tokens[3]) * dbu,
                    )
                except ValueError:
                    pass
                continue

            # Start and end of a pin #
            if tokens[0] == "PIN" and len(tokens) >= 2:
                current_pin = tokens[1]
                cells[current_cell].setdefault(current_pin, [])
                in_port = False
                current_layer = None
                continue

            if tokens[0] == "END" and len(tokens) >= 2 and tokens[1] == current_pin:
                current_pin = None
                in_port = False
                current_layer = None
                continue

            if current_pin is None:
                continue

            # Only the rectangles inside a PORT are pin shapes. Each LAYER line sets the layer of the rectangles that #
            # follow                                                                                                  #
            if tokens[0] == "PORT":
                in_port = True
                current_layer = None
                continue

            if tokens[0] == "END" and len(tokens) == 1 and in_port:
                in_port = False
                current_layer = None
                continue

            if not in_port:
                continue

            if tokens[0] == "LAYER" and len(tokens) >= 2:
                current_layer = tokens[1]
                continue

            # Pin rectangle on the current layer #
            if tokens[0] == "RECT" and len(tokens) >= 5:
                try:
                    xl = float(tokens[1]) * dbu
                    yl = float(tokens[2]) * dbu
                    xh = float(tokens[3]) * dbu
                    yh = float(tokens[4]) * dbu
                except ValueError:
                    continue
                cells[current_cell][current_pin].append(
                    (current_layer, (xl, yl, xh, yh))
                )

    return cells

# Read the technology LEF file. Returns vias (via name -> [(layer, rectangle)]) and viarules (rule name -> type and the #
# layers with enclosure, rectangle and spacing). The lengths are multiplied by dbu.                                     #
def parse_tech_lef(tech_lef_path, dbu):
    vias = {}
    viarules = {}
    current_via = None
    current_layer = None
    current_rule = None
    current_rule_data = None
    current_rule_layer = None

    with open(tech_lef_path, 'r') as f:
        for line in f:
            line = line.strip()
            tokens = line.split()
            if not line or line.startswith('#') or not tokens:
                continue

            # Start of a via definition #
            if tokens[0] == 'VIA' and len(tokens) >= 2:
                current_via = tokens[1]
                vias[current_via] = []
                current_layer = None
                current_rule = None
                continue

            # Start of a via rule #
            if tokens[0] == 'VIARULE' and len(tokens) >= 3:
                current_rule = tokens[1]
                current_rule_data = {'type': tokens[2], 'layers': []}
                viarules[current_rule] = current_rule_data
                current_layer = None
                current_via = None
                current_rule_layer = None
                continue

            # Inside a via, collect the layers and rectangles until END #
            if current_via:
                if tokens[0] == 'LAYER' and len(tokens) >= 2:
                    current_layer = tokens[1]
                elif tokens[0] == 'RECT' and len(tokens) >= 5:
                    try:
                        xl = float(tokens[1]) * dbu
                        yl = float(tokens[2]) * dbu
                        xh = float(tokens[3]) * dbu
                        yh = float(tokens[4]) * dbu
                        if current_layer:
                            vias[current_via].append((current_layer, (xl, yl, xh, yh)))
                    except ValueError:
                        pass
                elif tokens[0] == 'END' and len(tokens) >= 2 and tokens[1] == current_via:
                    current_via = None
                    current_layer = None
                continue

            # Inside a via rule, collect the layers and their enclosure, rectangle and spacing until END #
            if current_rule:
                if tokens[0] == 'LAYER' and len(tokens) >= 2:
                    current_rule_layer = {
                        'name': tokens[1],
                        'enclosure': None,
                        'rect': None,
                        'spacing': None,
                    }
                    current_rule_data['layers'].append(current_rule_layer)
                elif current_rule_layer:
                    if tokens[0] == 'ENCLOSURE' and len(tokens) >= 3:
                        try:
                            current_rule_layer['enclosure'] = (
                                float(tokens[1]) * dbu,
                                float(tokens[2]) * dbu,
                            )
                        except ValueError:
                            pass
                    elif tokens[0] == 'RECT' and len(tokens) >= 5:
                        try:
                            current_rule_layer['rect'] = (
                                float(tokens[1]) * dbu, float(tokens[2]) * dbu,
                                float(tokens[3]) * dbu, float(tokens[4]) * dbu,
                            )
                        except ValueError:
                            pass
                    elif tokens[0] == 'SPACING' and len(tokens) >= 4:
                        try:
                            current_rule_layer['spacing'] = (
                                float(tokens[1]) * dbu,
                                float(tokens[3]) * dbu,
                            )
                        except (ValueError, IndexError):
                            pass
                elif tokens[0] == 'END' and len(tokens) >= 2 and tokens[1] == current_rule:
                    current_rule = None
                    current_rule_data = None
                    current_rule_layer = None

    return vias, viarules

# Replace the "*" of a DEF wire path (x or y repeated from the previous point) by the coordinate of the previous point. #
# points is a list of (x, y) with None where the DEF has "*".                                                           #
def expand_star_points(points):
    last_x = last_y = None
    new_points = []
    for x, y in points:
        if x is None:
            x = last_x
        if y is None:
            y = last_y
        new_points.append((x, y))
        last_x, last_y = x, y
    return new_points

# Read the routed DEF. Returns components (instance -> macro, position, orientation), top_pins (top-level pin -> shapes, position, #
# orientation) and nets (net -> pins as (instance, pin) and the routed wire segments with layer, points and via name).             #
# Names are escaped for "$" and "." as in the SPEF. The file is read line by line with a small state                               #
# machine over the COMPONENTS, PINS and NETS sections.                                                                             #
def parse_def(def_path):
    components = {}
    top_pins = {}
    nets = {}

    section = None
    comp_buf = ""

    cur_pin = None
    cur_pin_layer = None
    cur_pin_rects = []
    cur_pin_x = 0
    cur_pin_y = 0
    cur_pin_orient = "N"

    cur_net = None

    with open(def_path, "r") as f:
        for raw in f:
            line = raw.strip()
            if not line:
                continue

            # Section boundaries #
            if line.startswith("COMPONENTS") and section is None:
                section = "COMPONENTS"
                continue
            if line.startswith("END COMPONENTS"):
                section = None
                comp_buf = ""
                continue

            if line.startswith("PINS") and section is None:
                section = "PINS"
                continue
            if line.startswith("END PINS"):
                if cur_pin is not None:
                    top_pins[cur_pin] = {
                        "rects": cur_pin_rects,
                        "x": cur_pin_x,
                        "y": cur_pin_y,
                        "orient": cur_pin_orient,
                    }
                    cur_pin = None
                section = None
                continue

            if line.startswith("NETS") and section is None:
                section = "NETS"
                continue
            if line.startswith("END NETS"):
                cur_net = None
                section = None
                continue

            # COMPONENTS, one instance per statement that ends with ";" (may span lines). Keep the macro, the position #
            # and the orientation                                                                                      #
            if section == "COMPONENTS":
                if line.startswith("-") or comp_buf:
                    comp_buf += " " + line
                    if ";" in line:
                        tokens = comp_buf.replace(";", " ").split()
                        if len(tokens) >= 3 and tokens[0] == "-":
                            inst_name = tokens[1]
                            inst_name = inst_name.replace("$", r"\$")
                            inst_name = inst_name.replace(".", r"\.")
                            macro_name = tokens[2]
                            x = y = orient = None
                            for i, tok in enumerate(tokens):
                                if tok == "(" and i + 3 < len(tokens):
                                    try:
                                        x = int(tokens[i + 1])
                                        y = int(tokens[i + 2])
                                        if i + 4 < len(tokens):
                                            orient = tokens[i + 4]
                                    except ValueError:
                                        pass
                            if x is not None and y is not None and orient is not None:
                                components[inst_name] = {
                                    "macro": macro_name,
                                    "x": x,
                                    "y": y,
                                    "orient": orient,
                                }
                        comp_buf = ""
                continue

            # PINS, a top-level pin has LAYER, rectangle and PLACED fields up to the closing ";" #
            if section == "PINS":
                if line.startswith("-") and cur_pin is None:
                    tokens = line.split()
                    if len(tokens) >= 2:
                        cur_pin = tokens[1]
                        cur_pin = cur_pin.replace(".", r"\.")
                        cur_pin_rects = []
                        cur_pin_layer = None
                        cur_pin_x = 0
                        cur_pin_y = 0
                        cur_pin_orient = "N"
                    continue

                if cur_pin is None:
                    continue

                tokens = line.split()
                i = 0
                while i < len(tokens):
                    tok = tokens[i]
                    if tok == "LAYER" and i + 1 < len(tokens):
                        cur_pin_layer = tokens[i + 1]
                        i += 2
                    elif tok == "(" and cur_pin_layer is not None:
                        if (i + 7 < len(tokens) and tokens[i + 3] == ")" and
                                tokens[i + 4] == "(" and tokens[i + 7] == ")"):
                            try:
                                x1 = int(tokens[i + 1])
                                y1 = int(tokens[i + 2])
                                x2 = int(tokens[i + 5])
                                y2 = int(tokens[i + 6])
                                cur_pin_rects.append(
                                    (cur_pin_layer, (x1, y1, x2, y2))
                                )
                                i += 8
                                continue
                            except ValueError:
                                pass
                        i += 1
                    elif tok == "PLACED" and i + 3 < len(tokens) and tokens[i + 1] == "(":
                        try:
                            cur_pin_x = int(tokens[i + 2])
                            cur_pin_y = int(tokens[i + 3])
                            if i + 5 < len(tokens) and tokens[i + 4] == ")":
                                cur_pin_orient = tokens[i + 5]
                                i += 6
                                continue
                        except (ValueError, IndexError):
                            pass
                        i += 1
                    else:
                        i += 1

                if line.endswith(";"):
                    top_pins[cur_pin] = {
                        "rects": cur_pin_rects,
                        "x": cur_pin_x,
                        "y": cur_pin_y,
                        "orient": cur_pin_orient,
                    }
                    cur_pin = None
                    cur_pin_layer = None
                continue

            # NETS, a net lists its pins "( instance pin )" and its ROUTED / NEW wire paths #
            if section == "NETS":
                if line.startswith("- "):
                    tokens = line.split()
                    if len(tokens) >= 2:
                        cur_net = tokens[1]
                        cur_net = cur_net.replace("$", r"\$")
                        cur_net = cur_net.replace(".", r"\.")
                        nets[cur_net] = {"pins": [], "segments": []}
                    continue

                if line.startswith(";"):
                    cur_net = None
                    continue

                if cur_net is None:
                    continue

                # Pin list of the net #
                if line.startswith("("):
                    tmp = line.replace("(", " ").replace(")", " ")
                    tokens = tmp.split()
                    for i in range(0, len(tokens), 2):
                        if i + 1 < len(tokens):
                            tokens[i] = tokens[i].replace(".", r"\.")
                            tokens[i+1] = tokens[i+1].replace(".", r"\.")
                            nets[cur_net]["pins"].append((tokens[i], tokens[i + 1]))
                    continue

                tokens = line.replace(";", " ").split()
                if not tokens:
                    continue

                # Wire path, ROUTED starts the first path and NEW the following paths. The path has a layer, points and #
                # possibly a via name                                                                                   #
                if tokens[0] == "+" and len(tokens) >= 3 and tokens[1] == "ROUTED":
                    layer = tokens[2]
                    rest = tokens[3:]
                elif tokens[0] == "NEW" and len(tokens) >= 2:
                    layer = tokens[1]
                    rest = tokens[2:]
                else:
                    continue

                # Points are "( x y )", the via name is the first other token #
                points = []
                via_name = None
                i = 0
                while i < len(rest):
                    tok = rest[i]
                    if tok == "(" and i + 3 < len(rest):
                        x = None if rest[i + 1] == "*" else int(rest[i + 1])
                        y = None if rest[i + 2] == "*" else int(rest[i + 2])
                        points.append((x, y))
                        i += 4
                    else:
                        if tok not in (")", "(") and via_name is None:
                            via_name = tok
                        i += 1

                # Store the segment with the star coordinates filled in #
                if points:
                    points = expand_star_points(points)
                    seg_id = len(nets[cur_net]["segments"])
                    nets[cur_net]["segments"].append({
                        "id": seg_id,
                        "layer": layer,
                        "points": points,
                        "via": via_name,
                    })

    return components, top_pins, nets

# Insert a point into every wire that runs through a via location. A via of a net sits at the end of a path. A wire of another #
# layer that the via connects and that passes through that point (but does not end there) gets the point as a new corner.      #
# Modifies the segments of def_nets in place.                                                                                  #
def split_wires_at_vias(def_nets, tech_vias):
    for net_name, net_info in def_nets.items():
        # Via locations of the net with their layer and via name #
        via_points = {}
        for seg in net_info['segments']:
            if seg.get('via'):
                via_name = seg['via']
                layer = seg['layer']
                point = seg['points'][-1]
                via_points[point] = (layer, via_name)

        for (vx, vy), (via_layer, via_name) in via_points.items():
            if via_name not in tech_vias:
                continue
            # Layers that this via connects #
            via_def = tech_vias[via_name]
            connected_layers = {l for l, _ in via_def}

            for seg in net_info['segments']:
                if seg['layer'] == via_layer:
                    continue
                if seg['layer'] not in connected_layers:
                    continue

                # Look for a horizontal or vertical piece that contains the via location strictly inside it #
                pts = seg['points']
                for i in range(len(pts) - 1):
                    x1, y1 = pts[i]
                    x2, y2 = pts[i + 1]
                    if x1 == x2 == vx and min(y1, y2) <= vy <= max(y1, y2):
                        if vy == y1 or vy == y2:
                            continue
                        seg['points'] = pts[:i + 1] + [(vx, vy)] + pts[i + 1:]
                        break
                    elif y1 == y2 == vy and min(x1, x2) <= vx <= max(x1, x2):
                        if vx == x1 or vx == x2:
                            continue
                        seg['points'] = pts[:i + 1] + [(vx, vy)] + pts[i + 1:]
                        break

# Absolute pin rectangles of a pin: [(layer, (xl, yl, xh, yh))]. For a top-level pin the rectangles are oriented and shifted to #
# its placement. For a cell pin the macro rectangles are oriented in the cell box and shifted to the instance position.         #
# Returns an empty list if the instance, macro or pin is unknown.                                                               #
def get_pin_abs_rects(inst_name, pin_name, components, cells, top_pins):
    # Top-level pin, "PIN" is the instance name that DEF uses for these #
    if inst_name == "PIN":
        pin_data = top_pins.get(pin_name)
        if not pin_data:
            return []
        rects = pin_data['rects']
        px, py = pin_data['x'], pin_data['y']
        orient = pin_data['orient']

        min_x = min_y = float('inf')
        max_x = max_y = float('-inf')
        for layer, (xl, yl, xh, yh) in rects:
            min_x = min(min_x, xl, xh)
            max_x = max(max_x, xl, xh)
            min_y = min(min_y, yl, yh)
            max_y = max(max_y, yl, yh)
        if min_x == float('inf'):
            return []

        width = max_x - min_x
        height = max_y - min_y

        abs_rects = []
        for layer, (xl, yl, xh, yh) in rects:
            oxl, oyl, oxh, oyh = orient_rect(xl, yl, xh, yh, orient, width, height)
            abs_rects.append((layer, (px + oxl, py + oyl, px + oxh, py + oyh)))
        return abs_rects

    # Cell pin #
    comp = components.get(inst_name)
    if comp is None:
        return []
    macro_pins = cells.get(comp["macro"])
    if not macro_pins:
        return []
    pin_rects = macro_pins.get(pin_name)
    if not pin_rects:
        return []

    cell_w, cell_h = macro_pins.get('_size', (0, 0))
    abs_rects = []
    for layer, (xl, yl, xh, yh) in pin_rects:
        oxl, oyl, oxh, oyh = orient_rect(xl, yl, xh, yh, comp["orient"], cell_w, cell_h)
        abs_rects.append((
            layer,
            (comp["x"] + oxl, comp["y"] + oyl,
             comp["x"] + oxh, comp["y"] + oyh),
        ))
    return abs_rects

# Transform a point inside a cell of size cell_w x cell_h for the DEF orientation (N, S, FN, FS, E, W, FE, FW). #
# An unknown orientation leaves the point unchanged.                                                            #
def orient_point(x, y, orient, cell_w, cell_h):
    if orient == "N":
        return x, y
    elif orient == "S":
        return cell_w - x, cell_h - y
    elif orient == "FN":
        return cell_w - x, y
    elif orient == "FS":
        return x, cell_h - y
    elif orient == "E":
        return y, cell_w - x
    elif orient == "W":
        return cell_h - y, x
    elif orient == "FE":
        return y, x
    elif orient == "FW":
        return cell_h - y, cell_w - x
    else:
        return x, y

def orient_rect(xl, yl, xh, yh, orient, cell_w, cell_h):
    corners = [(xl, yl), (xl, yh), (xh, yl), (xh, yh)]
    oriented = [orient_point(x, y, orient, cell_w, cell_h) for x, y in corners]
    xs = [p[0] for p in oriented]
    ys = [p[1] for p in oriented]
    return min(xs), min(ys), max(xs), max(ys)

# Insert a point into every wire that passes the centre of a pin of its net on the pin layer. The centre of each pin rectangle is #
# the split point if it lies strictly inside a straight piece of the wire. Modifies the segments of def_nets in place.            #
def split_wires_at_pins(def_nets, components, cells, tech_vias, top_pins, verbose):
    for net_name, net_info in def_nets.items():
        for (inst, pin) in net_info['pins']:
            # Absolute shapes of the pin #
            rects_with_layer = get_pin_abs_rects(inst, pin, components, cells, top_pins)
            if not rects_with_layer:
                continue

            pin_layers = {layer for layer, _ in rects_with_layer}

            for seg in net_info['segments']:
                if seg['layer'] not in pin_layers:
                    continue

                for (layer, (xl, yl, xh, yh)) in rects_with_layer:
                    if layer != seg['layer']:
                        continue

                    # Centre of the pin rectangle #
                    pin_cx = int((xl + xh) / 2.0)
                    pin_cy = int((yl + yh) / 2.0)

                    pts = seg['points']
                    for i in range(len(pts) - 1):
                        x1, y1 = pts[i]
                        x2, y2 = pts[i + 1]

                        split_pt = None
                        if x1 == x2 and x1 == pin_cx:
                            if min(y1, y2) < pin_cy < max(y1, y2):
                                split_pt = (pin_cx, pin_cy)
                        elif y1 == y2 and y1 == pin_cy:
                            if min(x1, x2) < pin_cx < max(x1, x2):
                                split_pt = (pin_cx, pin_cy)

                        if split_pt is not None:
                            seg['points'] = pts[:i+1] + [split_pt] + pts[i+1:]
                            break

# Centre of every pin as the middle of the bounding box of all its shapes. Cell pins are oriented and shifted to the instance #
# position and are keyed (instance, pin). Top-level pins are keyed ("PIN", pin) and their shapes are used as stored.          #
# Returns {(instance, pin): (x, y)} in integer database units.                                                                #
def compute_pin_centers(components, cells, top_pins, dbu_scale):
    pin_centers = {}

    # Cell pins #
    for inst_name, comp in components.items():
        macro = comp["macro"]
        macro_pins = cells.get(macro, {})
        cell_w, cell_h = macro_pins.get('_size', (0, 0))

        for pin_name, rects in macro_pins.items():
            if pin_name == '_size':
                continue
            if not rects:
                continue

            min_x = min_y = float('inf')
            max_x = max_y = float('-inf')

            for item in rects:
                try:
                    layer, (xl, yl, xh, yh) = item
                except ValueError:
                    try:
                        layer, xl, yl, xh, yh = item
                    except ValueError:
                        print(f"WARNING: Unexpected rect for pin {inst_name}/{pin_name}: {item}")
                        continue

                xl, yl, xh, yh = float(xl), float(yl), float(xh), float(yh)
                oxl, oyl, oxh, oyh = orient_rect(xl, yl, xh, yh, comp["orient"], cell_w, cell_h)
                abs_xl = comp["x"] + oxl
                abs_yl = comp["y"] + oyl
                abs_xh = comp["x"] + oxh
                abs_yh = comp["y"] + oyh

                min_x = min(min_x, abs_xl, abs_xh)
                max_x = max(max_x, abs_xl, abs_xh)
                min_y = min(min_y, abs_yl, abs_yh)
                max_y = max(max_y, abs_yl, abs_yh)

            if min_x != float('inf'):
                pin_centers[(inst_name, pin_name)] = (
                    int((min_x + max_x) / 2.0),
                    int((min_y + max_y) / 2.0),
                )

    # Top-level pins #
    for pin_name, pin_data in top_pins.items():
        if not isinstance(pin_data, dict) or 'rects' not in pin_data:
            continue

        min_x = min_y = float('inf')
        max_x = max_y = float('-inf')

        for item in pin_data['rects']:
            try:
                layer, (xl, yl, xh, yh) = item
            except ValueError:
                try:
                    layer, xl, yl, xh, yh = item
                except ValueError:
                    print(f"WARNING: Unexpected rect for top pin {pin_name}: {item}")
                    continue

            xl, yl, xh, yh = float(xl), float(yl), float(xh), float(yh)
            min_x = min(min_x, xl, xh)
            max_x = max(max_x, xl, xh)
            min_y = min(min_y, yl, yh)
            max_y = max(max_y, yl, yh)

        if min_x != float('inf'):
            pin_centers[("PIN", pin_name)] = (
                int((min_x + max_x) / 2.0),
                int((min_y + max_y) / 2.0),
            )

    return pin_centers

# Find, for every pin of every net, the point of the routed wires where the pin is connected. Tried in this order: the end of a #
# via whose shape overlaps a pin shape on the same layer, any wire point inside a pin shape, and the wire point that is closest #
# to the centre of a pin shape. A closest point is only accepted within tolerance (database units). Returns                     #
# def_pin_points {net: {pin name: point}} and def_point_to_pin_name {point: pin name}. A top-level pin is named by the pin      #
# only, a cell pin by instance/pin.                                                                                             #
def build_def_pin_points(def_nets, components, cells, tech_vias, top_pins,
                         tolerance=20000, verbose=False):
    def_pin_points = {}
    def_point_to_pin_name = {}

    for net_name, net_info in def_nets.items():
        net_pin_points = {}
        all_points = set()
        via_points = []

        for seg in net_info['segments']:
            # All wire points of the net and the via end points #
            all_points.update(seg['points'])
            if seg.get('via'):
                via_points.append((seg['points'][-1], seg['via']))

        # Absolute shapes of each pin, computed once #
        pin_rects_cache = {}

        for (inst, pin) in net_info['pins']:
            cache_key = (inst, pin)
            if cache_key not in pin_rects_cache:
                pin_rects_cache[cache_key] = get_pin_abs_rects(
                    inst, pin, components, cells, top_pins)
            rects_with_layer = pin_rects_cache[cache_key]

            if not rects_with_layer:
                continue

            # 1. via end point whose via shape overlaps a pin shape on the same layer #
            best_point = None
            best_dist = float('inf')

            for (vpoint, via_name) in via_points:
                if best_point is not None and best_dist == 0:
                    break
                vx, vy = vpoint
                if via_name not in tech_vias:
                    continue
                via_def = tech_vias[via_name]

                for (pin_layer, (xl_pin, yl_pin, xh_pin, yh_pin)) in rects_with_layer:
                    for (via_layer, (vxl_rel, vyl_rel, vxh_rel, vyh_rel)) in via_def:
                        if via_layer != pin_layer:
                            continue
                        abs_vxl = vx + vxl_rel
                        abs_vyl = vy + vyl_rel
                        abs_vxh = vx + vxh_rel
                        abs_vyh = vy + vyh_rel
                        if (abs_vxl < xh_pin and abs_vxh > xl_pin and
                                abs_vyl < yh_pin and abs_vyh > yl_pin):
                            best_point = vpoint
                            best_dist = 0
                            break
                    if best_point is not None:
                        break
                if best_point is not None:
                    break

            # 2. wire point inside a pin shape #
            if best_point is None:
                for (layer, (xl, yl, xh, yh)) in rects_with_layer:
                    for (px, py) in all_points:
                        if xl <= px <= xh and yl <= py <= yh:
                            best_point = (px, py)
                            best_dist = 0
                            break
                    if best_point is not None:
                        break

            # 3. wire point closest to the centre of a pin shape #
            if best_point is None:
                for (layer, (xl, yl, xh, yh)) in rects_with_layer:
                    pin_cx = (xl + xh) / 2.0
                    pin_cy = (yl + yh) / 2.0
                    for (px, py) in all_points:
                        dist = math.hypot(px - pin_cx, py - pin_cy)
                        if dist < best_dist:
                            best_dist = dist
                            best_point = (px, py)

            # Accept the point if it is close enough #
            pin_full_name = f"{inst}/{pin}" if inst != "PIN" else pin

            if best_point is not None:
                if best_dist <= tolerance:
                    net_pin_points[pin_full_name] = best_point
                    def_point_to_pin_name[best_point] = pin_full_name


        if net_pin_points:
            def_pin_points[net_name] = net_pin_points

    return def_pin_points, def_point_to_pin_name

# Steiner points of a net: wire points where three or more different wire pieces meet and that are not pin points. #
# Zero-length pieces are ignored. Returns {point: {"degree", "segments" (sorted ids of the segments through it)}}. #
def find_steiner_points_for_net(net_info, pin_points=None):
    edge_set = set()
    point_segs = defaultdict(set)

    for seg in net_info["segments"]:
        pts = seg["points"]
        seg_id = seg["id"]
        if len(pts) == 1 or pts[0] == pts[-1]:
            continue
        for i in range(len(pts) - 1):
            a, b = pts[i], pts[i + 1]
            if a == b:
                continue
            pair = (min(a, b, key=_point_sort_key), max(a, b, key=_point_sort_key))
            if pair not in edge_set:
                edge_set.add(pair)
            point_segs[a].add(seg_id)
            point_segs[b].add(seg_id)

    # Number of different wire pieces at every point #
    degree = defaultdict(int)
    for a, b in edge_set:
        degree[a] += 1
        degree[b] += 1

    return {
        p: {"degree": deg, "segments": sorted(point_segs.get(p, set()))}
        for p, deg in degree.items()
        if deg >= 3 and (pin_points is None or p not in pin_points)
    }

def add_def_steiner_points(def_nets, def_pin_points):
    for net_name, net_info in def_nets.items():
        pin_points = set(def_pin_points.get(net_name, {}).values())
        net_info['steiner_points'] = find_steiner_points_for_net(net_info, pin_points)

# Find pins that sit on a wire junction (the pin point has two or more different neighbours along the wires). Such a point is a #
# pin and a junction at the same time, so a virtual Steiner twin ('virtual', point) is added to steiner_points with the flag    #
# pin_at_same_pt. The edges are rewired later (see _ensure_steiner_point).                                                      #
def find_pin_steiner_conflicts(def_nets, def_pin_points):
    for net_name, net_info in def_nets.items():
        pin_points_for_net = set(def_pin_points.get(net_name, {}).values())

        # Segments through each point #
        point_to_segs = defaultdict(list)
        for seg in net_info['segments']:
            for pt in seg['points']:
                point_to_segs[pt].append(seg)

        for pin_pt in pin_points_for_net:
            segs_at_point = point_to_segs.get(pin_pt, [])
            wire_segs = [s for s in segs_at_point
                         if len(s['points']) >= 2 and s['points'][0] != s['points'][-1]]

            # Different neighbours of the pin point along the wires #
            neighbors = set()
            for seg in wire_segs:
                pts = seg['points']
                for i, pt in enumerate(pts):
                    if pt == pin_pt:
                        if i > 0:
                            neighbors.add(pts[i - 1])
                        if i < len(pts) - 1:
                            neighbors.add(pts[i + 1])

            # Junction at a pin, register the virtual twin #
            if len(neighbors) >= 2:
                layer = wire_segs[0]['layer'] if wire_segs else 'unknown'
                virtual_key = ('virtual', pin_pt)
                steiner_points = net_info.setdefault('steiner_points', {})
                if virtual_key not in steiner_points:
                    degree = sum(
                        1 for seg in net_info['segments']
                        for pt in seg['points'] if pt == pin_pt
                    )
                    steiner_points[virtual_key] = {
                        'degree': degree,
                        'segments': sorted(
                            seg['id'] for seg in net_info['segments']
                            if pin_pt in seg['points']
                        ),
                        'virtual': True,
                        'layer': layer,
                        'coords': pin_pt,
                        'pin_at_same_pt': pin_pt,
                    }

# Find vias that end where wires of the via layer meet them. The via end point is registered as a Steiner point, because the #
# wire changes direction or layer there (_ensure_steiner_point). Modifies net_info['steiner_points'] in place.               #
def find_same_layer_via_sandwiches(def_nets, def_pin_points, verbose):
    def is_real_segment(seg):
        pts = seg['points']
        return len(pts) >= 2 and pts[0] != pts[-1]

    for net_name, net_info in def_nets.items():
        segments = net_info['segments']
        pin_points_for_net = set(def_pin_points.get(net_name, {}).values())

        point_to_segs = defaultdict(list)
        for seg in segments:
            for pt in seg['points']:
                point_to_segs[pt].append(seg)

        # End point of every via segment #
        via_endpoints = {}
        for seg in segments:
            if seg.get('via') and is_real_segment(seg):
                via_pt = seg['points'][-1]
                via_endpoints[via_pt] = seg

        for via_pt, via_seg in via_endpoints.items():        
            via_layer = via_seg['layer']
            via_name = via_seg['via']

            # Other real segments on the via layer that touch the via end point #
            touching = [s for s in point_to_segs[via_pt] if s is not via_seg]
            same_layer_segs = [
                s for s in touching
                if s['layer'] == via_layer and is_real_segment(s)
            ]

            # Two or more wire pieces meet the via (the lengths computed here are not used further) #
            if len(same_layer_segs) >= 2:
                for i in range(len(same_layer_segs)):
                    for j in range(i + 1, len(same_layer_segs)):
                        seg_a = same_layer_segs[i]
                        seg_b = same_layer_segs[j]
                        len_a = sum(
                            abs(seg_a['points'][k+1][0] - seg_a['points'][k][0]) +
                            abs(seg_a['points'][k+1][1] - seg_a['points'][k][1])
                            for k in range(len(seg_a['points']) - 1)
                        )
                        len_b = sum(
                            abs(seg_b['points'][k+1][0] - seg_b['points'][k][0]) +
                            abs(seg_b['points'][k+1][1] - seg_b['points'][k][1])
                            for k in range(len(seg_b['points']) - 1)
                        )
                        _ensure_steiner_point(net_name, net_info, via_pt, via_layer,
                                              pin_points=pin_points_for_net, verbose=verbose)
            elif len(same_layer_segs) == 1:
                seg_a = same_layer_segs[0]
                len_a = sum(
                    abs(seg_a['points'][k+1][0] - seg_a['points'][k][0]) +
                    abs(seg_a['points'][k+1][1] - seg_a['points'][k][1])
                    for k in range(len(seg_a['points']) - 1)
                )
                _ensure_steiner_point(net_name, net_info, via_pt, via_layer,
                                      pin_points=pin_points_for_net, verbose=verbose)

# Make sure the point is a Steiner point of the net. If the point is also a pin point, add a virtual twin (('virtual', point)),  #
# join it to the pin point with a zero-length edge and move the end of the non-zero-length edges from the pin point to the twin, #
# so the pin hangs off the junction. Otherwise register the point as a virtual Steiner point. Does nothing if it exists already. #
def _ensure_steiner_point(net_name, net_info, point, layer, pin_points=None, verbose=False):
    steiner_points = net_info.get('steiner_points', {})

    # Pin at the junction, use a virtual twin #
    if pin_points and point in pin_points:
        virtual_key = ('virtual', point)
        if virtual_key not in steiner_points:
            degree = sum(
                1
                for seg in net_info['segments']
                for pt in seg['points']
                if pt == point
            )
            steiner_points[virtual_key] = {
                'degree': degree,
                'segments': sorted(
                    seg['id']
                    for seg in net_info['segments']
                    if point in seg['points']
                ),
                'virtual': True,
                'layer': layer,
                'coords': point,
                'pin_at_same_pt': point,
            }
            net_info['steiner_points'] = steiner_points

            existing_edges = net_info.setdefault('def_edges', [])
            # Zero-length edge between the twin and the pin point #
            already_wired = any(
                (e['p1'] == virtual_key and e['p2'] == point) or
                (e['p1'] == point and e['p2'] == virtual_key)
                for e in existing_edges
            )
            if not already_wired:
                existing_edges.append({
                    'p1': virtual_key,
                    'p2': point,
                    'zero_length': True,
                    'layer': layer,
                    'intermediate': [],
                })


                # Edges that ended at the pin point now end at the twin #
                for e in existing_edges:
                    if e.get('zero_length'):
                        continue
                    if e['p2'] == point:
                        e['p2'] = virtual_key
                    elif e['p1'] == point:
                        e['p1'] = virtual_key

        return

    # Plain Steiner point #
    if point in steiner_points:
        if verbose:
            logging.debug(
                f"    [STEINER] Point {point} already exists in Steiner points of net {net_name} "
                f"(degree={steiner_points[point]['degree']})"
            )
    else:
        degree = sum(
            1
            for seg in net_info['segments']
            for pt in seg['points']
            if pt == point
        )
        steiner_points[point] = {
            'degree': degree,
            'segments': sorted(
                seg['id']
                for seg in net_info['segments']
                if point in seg['points']
            ),
            'virtual': True,
            'layer': layer,
            'coords': point,
        }
        net_info['steiner_points'] = steiner_points

# Undirected adjacency of the wire points of a net: point -> list of the points that follow or precede it on a segment. #
def build_def_net_graph(net_info):
    graph = defaultdict(set)
    for seg in net_info['segments']:
        pts = seg['points']
        for i in range(len(pts) - 1):
            p1, p2 = pts[i], pts[i + 1]
            if p1 != p2:
                graph[p1].add(p2)
                graph[p2].add(p1)
    return {p: list(nbrs) for p, nbrs in graph.items()}

# Compress the wire graph to edges between points of interest (pins, Steiner points). From each point of interest every         #
# neighbour is followed through points that have exactly two neighbours and are not of interest, until a point of interest or a #
# branch is reached. Returns a list of {"p1", "p2", "intermediate" (points in between)}. Every chain is returned once.          #
def extract_def_edges_between_interest(graph, interest_points):
    edges = []
    visited_edges = set()

    for start in interest_points:
        if start not in graph:
            continue
        for nb in graph[start]:
            # Skip a chain that was already followed from its other end #
            canonical = (min(_point_sort_key(start), _point_sort_key(nb)),
                         max(_point_sort_key(start), _point_sort_key(nb)))
            if canonical in visited_edges:
                continue

            # Follow the chain #
            path = [start, nb]
            current = nb
            prev = start
            loop_guard = 0

            while (len(graph.get(current, [])) == 2
                   and current not in interest_points
                   and loop_guard < 100000):
                nxt = next((n for n in graph[current] if n != prev), None)
                if nxt is None or nxt == start:
                    break
                path.append(nxt)
                prev, current = current, nxt
                loop_guard += 1

            # Mark the pieces of the chain as visited and store the edge #
            end = current
            for i in range(len(path) - 1):
                a, b = path[i], path[i + 1]
                c = (min(_point_sort_key(a), _point_sort_key(b)),
                     max(_point_sort_key(a), _point_sort_key(b)))
                visited_edges.add(c)

            edges.append({'p1': start, 'p2': end, 'intermediate': path[1:-1]})

    return edges

# Read the *NAME_MAP section of the SPEF. Returns name_to_id, id_to_name (SPEF id such as *123 <-> full name) and raw_lines #
# (the section as text, written unchanged to the output SPEF).                                                              #
def parse_spef_name_map(spef_path):
    name_to_id = {}
    id_to_name = {}
    raw_lines = []
    in_name_map = False

    print(f"INFO: Parsing {spef_path}")

    with open(spef_path, "r") as f:
        for line in f:
            stripped = line.rstrip()
            if not stripped or stripped.startswith("//"):
                continue

            if stripped == "*NAME_MAP":
                in_name_map = True
                raw_lines.append(stripped)
                continue

            if in_name_map:
                if stripped.startswith("*") and " " not in stripped:
                    break
                raw_lines.append(stripped)
                if " " in stripped:
                    parts = stripped.split()
                    spef_id = parts[0]
                    full_name = " ".join(parts[1:])
                    id_to_name[spef_id] = full_name
                    name_to_id[full_name] = spef_id

    print(f"INFO: Found {len(name_to_id):,} SPEF name mappings")
    return name_to_id, id_to_name, raw_lines

# Return the lines of the *PORTS section of the SPEF (kept to be written unchanged to the output SPEF). #
def parse_spef_ports(spef_path):
    ports_lines = []
    in_ports = False

    with open(spef_path, "r") as f:
        for line in f:
            stripped = line.rstrip()
            if not stripped or stripped.startswith("//"):
                continue
            if stripped == "*PORTS":
                in_ports = True
                ports_lines.append(stripped)
                continue
            if in_ports:
                if stripped.startswith("*D_NET") and " " not in stripped:
                    break
                ports_lines.append(stripped)

    return ports_lines

# Read every *D_NET of the SPEF. Returns {DEF net name: {"spef_id", "def_name", "delay" (the total capacitance of the *D_NET #
# line), "conn" (pins and ports with direction, coordinates and pin capacitance), "cap", "res", "raw_conn"}}.                #
# Node ids "*12:3" are translated to DEF names "instance/3" with the name map.                                               #
def parse_spef_nets(spef_path, spef_mapping, spef_reverse):
    spef_nets = {}
    current_net = None
    current_section = None

    # DEF name of a SPEF node id. "*12:3" becomes "<name of *12>/3", a plain id is looked up directly. None if unknown. #
    def resolve_node_name(node_id):
        if ':' in node_id:
            base, suffix = node_id.split(':', 1)
            base_name = spef_reverse.get(base)
            return f"{base_name}/{suffix}" if base_name else None
        return spef_reverse.get(node_id)

    with open(spef_path, "r") as f:
        for line in f:
            stripped = line.rstrip()
            if not stripped or stripped.startswith("//"):
                continue

            # Skip the name map and the ports, they are read by their own functions #
            if stripped == "*NAME_MAP":
                while stripped not in ("*D_NET", "*PORTS", "*END"):
                    stripped = f.readline().rstrip()
                continue
            if stripped == "*PORTS":
                while stripped not in ("*D_NET", "*END"):
                    stripped = f.readline().rstrip()
                continue

            # Start of a net #
            if stripped.startswith("*D_NET"):
                tokens = stripped.split()
                if len(tokens) >= 3:
                    spef_net_id = tokens[1]
                    net_delay = float(tokens[2])
                    net_name = spef_reverse.get(spef_net_id)
                    if net_name:
                        current_net = {
                            "spef_id": spef_net_id,
                            "def_name": net_name,
                            "delay": net_delay,
                            "conn": [],
                            "cap": [],
                            "res": [],
                            "raw_conn": [],
                        }
                        spef_nets[net_name] = current_net
                    else:
                        print(f"WARNING: SPEF net ID {spef_net_id} not found in name mapping")
                        current_net = None
                continue

            # End of a net #
            if stripped == "*END" and current_net:
                current_net = None
                current_section = None
                continue

            if current_net is None:
                continue

            # Section of the net #
            if stripped == "*CONN":
                current_section = "CONN"
                current_net["raw_conn"].append(stripped)
                continue
            elif stripped == "*CAP":
                current_section = "CAP"
                continue
            elif stripped == "*RES":
                current_section = "RES"
                continue

            # *CONN, one *P (port) or *I (instance pin) per line. The direction of a port is stored inverted, because a #
            # port is seen from the other side                                                                          #
            if current_section == "CONN":
                current_net["raw_conn"].append(stripped)
                if stripped.startswith("*"):
                    tokens = stripped.split()
                    if len(tokens) >= 8:
                        node_name = resolve_node_name(tokens[1])
                        conn_type = tokens[0]   # '*P' or '*I'
                        raw_dir = tokens[2]   # 'O' or 'I' as written in SPEF
                        
                        if conn_type == '*P':
                            stored_dir = 'I' if raw_dir == 'O' else 'O'
                        else:
                            stored_dir = raw_dir
                        current_net["conn"].append({
                            "type":      conn_type,
                            "id":        tokens[1],
                            "def_name":  node_name,
                            "direction": stored_dir,
                            "node_type": tokens[3],
                            "x":         float(tokens[4]),
                            "y":         float(tokens[5]),
                            "pin_cap":   float(tokens[7]),
                        })

            # *CAP, node capacitance #
            elif current_section == "CAP" and stripped[0].isdigit():
                tokens = stripped.split()
                if len(tokens) == 3:
                    current_net["cap"].append({
                        "id": int(tokens[0]),
                        "node_id": tokens[1],
                        "def_name": resolve_node_name(tokens[1]),
                        "value": float(tokens[2]),
                    })

            # *RES, resistor between two nodes #
            elif current_section == "RES" and stripped[0].isdigit():
                tokens = stripped.split()
                if len(tokens) >= 4:
                    current_net["res"].append({
                        "id": int(tokens[0]),
                        "node1_id": tokens[1],
                        "node1_name": resolve_node_name(tokens[1]),
                        "node2_id": tokens[2],
                        "node2_name": resolve_node_name(tokens[2]),
                        "value": float(tokens[3]),
                    })

    print(f"INFO: Parsed {len(spef_nets):,} SPEF nets")
    return spef_nets

# Build one graph of all SPEF nodes. Returns {node id: {"def_name", "cap" (node capacitance), "coords", "neighbors" ({node: R}), #
# "net", and for pins "direction"}}. The nodes come from *CAP and *RES, the pin coordinates and directions from *CONN.           #
def build_spef_graph(spef_nets, spef_mapping, spef_reverse, verbose):
    graph = {}
    print("INFO: Building the SPEF graph from the RES and CAP data")

    for net_name, net_data in spef_nets.items():
        # Nodes with a capacitance #
        for cap_entry in net_data['cap']:
            node_id = cap_entry['node_id']
            node_name = spef_reverse.get(node_id, cap_entry['def_name'])
            graph[node_id] = {
                'def_name': node_name,
                'cap': cap_entry['value'],
                'coords': None,
                'neighbors': {},
                'net': net_name,
            }

        # Resistors, add missing nodes and connect both ends #
        for res_entry in net_data['res']:
            n1 = res_entry['node1_id']
            n2 = res_entry['node2_id']
            res = res_entry['value']

            for nid, nname_key in [(n1, 'node1_name'), (n2, 'node2_name')]:
                if nid not in graph:
                    graph[nid] = {
                        'def_name': spef_reverse.get(nid, res_entry[nname_key]),
                        'cap': 0.0,
                        'coords': None,
                        'neighbors': {},
                        'net': net_name,
                    }

            graph[n1]['neighbors'][n2] = res
            graph[n2]['neighbors'][n1] = res

        # Pin coordinates, direction and name #
        for conn_entry in net_data['conn']:
            node_id = conn_entry['id']
            if node_id in graph:
                graph[node_id]['coords'] = (conn_entry['x'], conn_entry['y'])
                graph[node_id]['direction'] = conn_entry['direction']
                if conn_entry.get('def_name'):
                    graph[node_id]['def_name'] = conn_entry['def_name']

    num_nodes = len(graph)
    num_edges = sum(len(n['neighbors']) for n in graph.values()) // 2
    return graph

# Store in every net the SPEF nodes with three or more neighbours (the branching points) as spef_net_info['steiner_points']. #
def add_spef_steiner_points(spef_nets, nodes_by_net):
    # nodes_by_net: {net_name -> {nid -> ndata}} prebuilt index (was a full
    # graph.items() rescan per net -> O(nets * |graph|)).
    for net_name, net_data in spef_nets.items():
        net_data['steiner_points'] = {
            nid: {
                'degree': len(ndata['neighbors']),
                'def_name': ndata['def_name'],
                'coords': ndata.get('coords'),
                'cap': ndata['cap'],
            }
            for nid, ndata in nodes_by_net.get(net_name, {}).items()
            if len(ndata['neighbors']) >= 3
        }

# Collapse the RC tree of one net into edges between pins and branching points. Chains of nodes with exactly two neighbours are #
# merged, their resistances and node capacitances are summed. Returns a list of {"node1", "node2", "total_resistance",          #
# "total_capacitance" (capacitance of the nodes in between), "intermediate" (the nodes in between)}.                            #
def collapse_spef_net_to_edges(net_nodes):
    # net_nodes: {nid -> data} for exactly this net (was rebuilt per call by
    # scanning the whole graph).
    nodes = net_nodes
    def is_spef_pin(nid):
        d = nodes[nid]
        return d.get('coords') is not None and d.get('direction') is not None

    # Points of interest are pins and every node that does not have exactly two neighbours #
    interest = {
        nid for nid, data in nodes.items()
        if is_spef_pin(nid) or len(data['neighbors']) != 2
    }

    edges = []
    visited_pairs = set()

    # Follow every chain from a point of interest to the next one #
    for start in interest:
        for nb in list(nodes[start]['neighbors']):
            canon = frozenset({start, nb})
            if canon in visited_pairs:
                continue

            path_nodes = [start, nb]
            total_res = nodes[start]['neighbors'][nb]
            current = nb
            prev = start
            loop_guard = 0

            while (len(nodes.get(current, {}).get('neighbors', {})) == 2
                   and current not in interest
                   and loop_guard < 100000):
                nxt = next((n for n in nodes[current]['neighbors'] if n != prev), None)
                if nxt is None or nxt == start:
                    break
                total_res += nodes[current]['neighbors'][nxt]
                path_nodes.append(nxt)
                prev, current = current, nxt
                loop_guard += 1

            end = current
            for i in range(len(path_nodes) - 1):
                visited_pairs.add(frozenset({path_nodes[i], path_nodes[i + 1]}))

            # Edge with the summed resistance and the capacitance of the nodes in between #
            intermediate_nodes = path_nodes[1:-1]
            total_cap = sum(nodes[n]['cap'] for n in intermediate_nodes if n in nodes)

            edges.append({
                'node1': start,
                'node2': end,
                'total_resistance': total_res,
                'total_capacitance': total_cap,
                'intermediate': intermediate_nodes,
            })

    return edges

# Shortest path (number of hops) between two SPEF nodes by breadth-first search. Returns the list of nodes from start to end, or None. #
def find_path_spef(start, end, spef_adj):
    if start == end:
        return [start]

    visited = {start}
    parent = {}
    queue = deque([start])

    while queue:
        node = queue.popleft()
        if node == end:
            break
        for nb in spef_adj.get(node, []):
            if nb not in visited:
                visited.add(nb)
                parent[nb] = node
                queue.append(nb)

    if end not in parent:
        return None

    path = []
    cur = end
    while cur != start:
        path.append(cur)
        cur = parent[cur]
    path.append(start)
    path.reverse()
    return path

# Add DEF nodes for SPEF branching points that have none. For such a SPEF node, whose neighbours are all mapped, the DEF edges #
# whose SPEF path runs through it are found. The split position is the coordinate of a neighbouring pin that lies on all these #
# edges, otherwise the point at the same share of resistance along the first edge. A virtual node ('virtual_spf', coordinate,  #
# SPEF node) is mapped to the SPEF node and the edges are split there. def_edges, def_adj, def_to_spef, spef_to_def and        #
# point_to_pin are modified in place.                                                                                          #
def insert_missing_spef_steiner_nodes(net_name, def_net_info, spef_net_info, graph, spef_adj, def_to_spef, spef_to_def, def_edges, def_adj, point_to_pin, point_pair_layer, dbu_scale, verbose):
    def is_pin_node(node_id):
        d = graph.get(node_id, {})
        return d.get('coords') is not None and d.get('direction') is not None

    all_spef_nodes = {nid for nid, ndata in graph.items() if ndata.get('net') == net_name}
    # SPEF branching points without a DEF node #
    unmapped_steiner = [
        nid for nid in all_spef_nodes
        if nid not in spef_to_def
        and len(graph[nid].get('neighbors', {})) >= 3
    ]
    unmapped_steiner.sort()

    # Only handle a node whose neighbours are all mapped #
    for spef_node in unmapped_steiner:
        neighbors = list(graph[spef_node]['neighbors'].keys())
        if not all(nb in spef_to_def for nb in neighbors):
            continue

        # DEF edges whose SPEF path runs through the node, with the share of the path resistance before the node #
        edges_to_process = []  
        for e in def_edges:
            p1, p2 = e['p1'], e['p2']
            if p1 not in def_to_spef or p2 not in def_to_spef:
                continue
            n1 = def_to_spef[p1]
            n2 = def_to_spef[p2]
            path = find_path_spef(n1, n2, spef_adj)
            if not path or spef_node not in path:
                continue

            idx = path.index(spef_node)
            r_to = 0.0
            for i in range(idx):
                a, b = path[i], path[i+1]
                r_to += graph[a]['neighbors'][b]
            r_from = 0.0
            for i in range(idx, len(path)-1):
                a, b = path[i], path[i+1]
                r_from += graph[a]['neighbors'][b]
            total_r = r_to + r_from
            if total_r == 0:
                continue
            ratio = r_to / total_r
            edges_to_process.append((e, ratio, r_to, r_from))

        if not edges_to_process:
            continue

        # A neighbouring pin whose coordinate lies on all these edges gives the split position #
        pin_neighbors = [nb for nb in neighbors if is_pin_node(nb)]
        pin_candidates = []
        for nb in pin_neighbors:
            def_pt = spef_to_def[nb]
            coord = _get_coords(def_pt)
            pin_candidates.append((nb, def_pt, coord))

        common_pin_coord = None
        common_pin_def_pt = None
        for _, def_pt, coord in pin_candidates:
            all_match = True
            for e, _, _, _ in edges_to_process:
                if not (point_equals(e['p1'], coord) or point_equals(e['p2'], coord)):
                    all_match = False
                    break
            if all_match:
                common_pin_coord = coord
                common_pin_def_pt = def_pt
                break

        # Split at the pin coordinate, it must lie on every edge #
        if common_pin_coord is not None:
            split_coord = common_pin_coord
            all_valid = True
            for e, _, _, _ in edges_to_process:
                if not is_point_on_edge(e, split_coord):
                    all_valid = False
                    break
            if not all_valid:
                continue
            
            # The pin already has a virtual twin on the same SPEF node, reuse it and split the edges there #
            existing_virtual = ('virtual', (split_coord[0], split_coord[1]))
            if existing_virtual in def_to_spef:
                current_spef = def_to_spef[existing_virtual]
                raw_coord = (split_coord[0], split_coord[1])
                if (raw_coord in def_to_spef and
                        def_to_spef[raw_coord] == current_spef and
                        current_spef != spef_node):
                    def_to_spef[existing_virtual] = spef_node
                    spef_to_def[spef_node] = existing_virtual
                    if existing_virtual not in point_to_pin:
                        point_to_pin[existing_virtual] = f"VirtualSteiner{split_coord}"
                    for e, ratio, _, _ in edges_to_process:
                        p1, p2 = e['p1'], e['p2']
                        if p1 == existing_virtual or p2 == existing_virtual:
                            continue
                        edge1, edge2 = split_edge_at_coord(e, split_coord, point_pair_layer)
                        edge1['p2'] = existing_virtual
                        edge2['p1'] = existing_virtual
                        def_edges.remove(e)
                        if p2 in def_adj[p1]: def_adj[p1].remove(p2)
                        if p1 in def_adj[p2]: def_adj[p2].remove(p1)
                        def_edges.append(edge1)
                        def_edges.append(edge2)
                        def_adj[edge1['p1']].append(edge1['p2'])
                        def_adj[edge1['p2']].append(edge1['p1'])
                        def_adj[edge2['p1']].append(edge2['p2'])
                        def_adj[edge2['p2']].append(edge2['p1'])
                    continue    
        else:
            # No pin, split the first edge at the resistance share and check the point on the other edges #
            ref_edge, ref_ratio, _, _ = edges_to_process[0]
            _, _, split_coord = split_edge_at_ratio(
                ref_edge, ref_ratio, point_pair_layer, dbu_scale
            )
            all_valid = True
            for e, _, _, _ in edges_to_process:
                if not is_point_on_edge(e, split_coord):
                    all_valid = False
                    break
            if not all_valid:
                continue
        
        # New virtual node for the SPEF node #
        virtual_key = ('virtual_spf', (split_coord[0], split_coord[1]), spef_node)
        def_to_spef[virtual_key] = spef_node
        spef_to_def[spef_node] = virtual_key
        point_to_pin[virtual_key] = f"VirtualSPF{split_coord[0]}_{split_coord[1]}"
    

        # Split every edge at the new node and update the edge list and the adjacency #
        for e, ratio, _, _ in edges_to_process:
            edge1, edge2 = split_edge_at_coord(e, split_coord, point_pair_layer)
            edge1['p2'] = virtual_key
            edge2['p1'] = virtual_key

            def_edges.remove(e)
            p1_orig, p2_orig = e['p1'], e['p2']
            if p2_orig in def_adj[p1_orig]:
                def_adj[p1_orig].remove(p2_orig)
            if p1_orig in def_adj[p2_orig]:
                def_adj[p2_orig].remove(p1_orig)

            def_edges.append(edge1)
            def_edges.append(edge2)
            def_adj[edge1['p1']].append(edge1['p2'])
            def_adj[edge1['p2']].append(edge1['p1'])
            def_adj[edge2['p1']].append(edge2['p2'])
            def_adj[edge2['p2']].append(edge2['p1'])


# Compute the reachable pin set of every node of the routed DEF tree of one net.            #
# The tree is walked depth first from the driver (start_point). The result maps each node   #
# to the frozenset of pin names that lie behind it, seen from the driver. The driver itself #
# is not counted as a pin of any node. The sets are the signature that topology alignment   #
# uses to match DEF Steiner nodes with SPEF nodes                                           #
def _compute_def_reachable(start_point, def_adj, point_to_pin, pin_points_set, zero_length_pairs=None):

    visited = set()
    parent_pins = {} 
    stack = [(start_point, False)]

    if zero_length_pairs is None:
        zero_length_pairs = set()

    while stack:
        node, processed = stack.pop()
        if not processed:
            if node in visited:
                continue
            visited.add(node)
            stack.append((node, True)) 

            pins = set()
            if node != start_point:  # the driver does not count as a reachable pin #
                if node in pin_points_set and node in point_to_pin:
                    pins.add(point_to_pin[node])
                # a virtual node stands for the pin at its physical location #
                if isinstance(node, tuple) and isinstance(node[0], str) and node[0] == 'virtual':
                    phys = node[1]
                    if phys in pin_points_set and phys in point_to_pin and phys != start_point:
                        pins.add(point_to_pin[phys])
            parent_pins[node] = pins

            for nbr in def_adj.get(node, []):
                if nbr not in visited:
                    stack.append((nbr, False))
        else:
            pins = parent_pins[node]
            for nbr in def_adj.get(node, []):
                if nbr not in parent_pins:
                    continue
                pair = (min(_point_sort_key(node), _point_sort_key(nbr)),
                        max(_point_sort_key(node), _point_sort_key(nbr)))
                if pair in zero_length_pairs:
                    # A raw pin point and its virtual twin are one location. Their pins must not be passed on to #
                    # each other, otherwise both would report the same pin and could not be told apart.          #
                    node_is_raw = not (isinstance(node, tuple) and isinstance(node[0], str))
                    nbr_is_virtual = (isinstance(nbr, tuple) and isinstance(nbr[0], str)
                                      and nbr[0] == 'virtual')
                    if node_is_raw and nbr_is_virtual:
                        continue
                    nbr_is_raw = not (isinstance(nbr, tuple) and isinstance(nbr[0], str))
                    node_is_virtual = (isinstance(node, tuple) and isinstance(node[0], str)
                                       and node[0] == 'virtual')
                    if nbr_is_raw and node_is_virtual:
                        continue
                pins.update(parent_pins[nbr])
            parent_pins[node] = pins

    return {node: frozenset(pins) for node, pins in parent_pins.items()}

# Compute the reachable sets for both DEF and SPEF graphs, and map them to each other based on the driver and pin information. #
# Returns two dictionaries: def_to_spef (mapping DEF points to SPEF nodes) and spef_to_def (mapping SPEF nodes to DEF points). #
def map_net_by_reachable_sets(net_name, def_net_info, spef_net_info, graph, def_point_to_pin_name, def_pin_points_for_net, dbu_scale, verbose):
    global _global_spef_nodes_by_net, _global_spef_pins_by_net, _global_spef_pin_name_to_node_by_net 

    net_graph = _global_spef_nodes_by_net.get(net_name, {})
    all_pin_nodes = _global_spef_pins_by_net.get(net_name, set())
    pin_name_to_spef = _global_spef_pin_name_to_node_by_net.get(net_name, {})

    spef_edges = spef_net_info.get('spef_collapsed_edges', [])
    if not spef_edges:
        return None, None

    spef_adj = defaultdict(list)
    for e in spef_edges:
        n1, n2 = e['node1'], e['node2']
        spef_adj[n1].append(n2)
        spef_adj[n2].append(n1)
    
    def is_pin_node(node_id):
        d = graph.get(node_id, {})
        return d.get('coords') is not None and d.get('direction') is not None

    all_pin_names = {graph[n]['def_name'] for n in all_pin_nodes if graph[n].get('def_name')}

    driver_spef, driver_pin_name = _select_driver(
        net_name, all_pin_nodes, graph, spef_adj, all_pin_names, is_pin_node, verbose)

    if driver_spef is None:
        return None, None
    
    def_driver_point = next((pt for name, pt in def_pin_points_for_net.items() if name == driver_pin_name), None,)
    if def_driver_point is None:
        return None, None

    def_edges = def_net_info.get('def_edges', [])
    def_adj = defaultdict(list)
    for e in def_edges:
        p1, p2 = e['p1'], e['p2']
        def_adj[p1].append(p2)
        def_adj[p2].append(p1)

    for pt in def_adj:
        def_adj[pt] = sorted(set(def_adj[pt]), key=_point_sort_key)

    point_to_pin = {pt: name for name, pt in def_pin_points_for_net.items()}

    for pt, data in def_net_info.get('steiner_points', {}).items():
        if data.get('virtual') and pt not in point_to_pin:
            if isinstance(pt, tuple) and isinstance(pt[0], str):
                point_to_pin[pt] = f"VirtualSteiner{data['coords']}"
            else:
                point_to_pin[pt] = f"VirtualSteiner{pt}"

    pin_points_set = set(def_pin_points_for_net.values())

    zero_length_pairs = set()
    for pt, data in def_net_info.get('steiner_points', {}).items():
        if data.get('virtual') and isinstance(pt, tuple) and pt[0] == 'virtual':
            phys = data['coords']
            pair = (min(_point_sort_key(pt), _point_sort_key(phys)),
                    max(_point_sort_key(pt), _point_sort_key(phys)))
            zero_length_pairs.add(pair)
    def_reachable = _compute_def_reachable(
        def_driver_point, def_adj, point_to_pin, pin_points_set, zero_length_pairs)

    spef_reachable = {}
    visited = set()
    stack = [(driver_spef, False)]
    parent_pins = {}

    # Perform a depth-first traversal of the SPEF graph to compute reachable pin sets for each node. #
    while stack:
        node, processed = stack.pop()
        if not processed:
            if node in visited:
                continue
            visited.add(node)
            stack.append((node, True))
            pins = set()
            if node != driver_spef and is_pin_node(node):
                name = graph[node].get('def_name')
                if name:
                    pins.add(name)
            parent_pins[node] = pins
            for nbr in spef_adj.get(node, []):
                if nbr not in visited:
                    stack.append((nbr, False))
        else:
            pins = parent_pins[node]
            for nbr in spef_adj.get(node, []):
                if nbr in spef_reachable:
                    pins.update(spef_reachable[nbr])
            spef_reachable[node] = pins

    def_to_spef = {}
    spef_to_def = {}

    # Map DEF points to SPEF nodes based on pin names and reachable sets. #
    for point, pin_name in point_to_pin.items():
        if isinstance(point, tuple) and isinstance(point[0], str):
            continue

        node_id = pin_name_to_spef.get(pin_name)
        if node_id is not None:
            def_to_spef[point] = node_id
            spef_to_def[node_id] = point

    if def_driver_point not in def_to_spef:
        def_to_spef[def_driver_point] = driver_spef
        spef_to_def[driver_spef] = def_driver_point

    coord_to_node = {}
    for key in point_to_pin:
        coord_to_node[_get_coords(key)] = key
    for key in def_to_spef:
        coord_to_node[_get_coords(key)] = key

    def_candidates = [p for p in def_adj if p not in def_to_spef]
    spef_candidates = set(
        nid for nid in sorted(spef_adj)
        if nid not in spef_to_def and not is_pin_node(nid)
    )
    def_candidates.sort(key=lambda p: len(def_reachable.get(p, set())), reverse=True)

    spef_by_pinset = defaultdict(list)
    for nid in spef_candidates:
        spef_by_pinset[frozenset(spef_reachable.get(nid, set()))].append(nid)
    for lst in spef_by_pinset.values():
        lst.sort()

    # First pass: Directly match DEF points to SPEF nodes with identical reachable pin sets. #
    for def_pt in def_candidates:
        pins_from_def = def_reachable.get(def_pt, set())
        if not pins_from_def:
            continue
        key = frozenset(pins_from_def)
        bucket = spef_by_pinset.get(key)
        match = bucket[0] if bucket else None
        if match is not None:
            def_to_spef[def_pt] = match
            spef_to_def[match] = def_pt
            spef_candidates.discard(match)
            bucket.pop(0)
            if not bucket:
                del spef_by_pinset[key]

    # Second pass: Attempt to match remaining DEF points to SPEF nodes based on subset relationships of reachable pin sets. #
    for def_pt in def_candidates:
        if def_pt not in def_to_spef:
            continue
        pins_from_def = def_reachable.get(def_pt, set())

        split_matches = sorted([
            nid for nid in spef_candidates
            if spef_reachable.get(nid, set()) < pins_from_def
        ])
        empty_spef_nodes = sorted([
            nid for nid in spef_candidates
            if not spef_reachable.get(nid, set())
        ])

        for spef_node in split_matches:
            spef_pins = spef_reachable[spef_node]

            best_parent = None
            best_size = float('inf')
            for candidate in def_candidates:
                if candidate not in def_to_spef:
                    continue
                candidate_pins = def_reachable.get(candidate, set())
                if spef_pins < candidate_pins and len(candidate_pins) < best_size:
                    best_size = len(candidate_pins)
                    best_parent = candidate

            if best_parent != def_pt:
                continue


            coords = _get_coords(def_pt)
            split_key_base = ('split', coords, frozenset(spef_pins))
            if split_key_base in def_to_spef:
                split_key = ('split', coords, frozenset(spef_pins), spef_node)
            else:
                split_key = split_key_base

            def_to_spef[split_key] = spef_node
            spef_to_def[spef_node] = split_key
            spef_candidates.discard(spef_node)
            point_to_pin[split_key] = f"SplitSteiner{coords}"

            _rewire_edges_for_split(
                def_pt, split_key, spef_node,
                def_edges, def_adj, def_to_spef,
                point_to_pin, spef_pins, spef_reachable,
                graph, spef_adj, def_candidates, def_reachable,
                collapsed_spef_adj=spef_adj, verbose=verbose,
            )

        for spef_node in list(empty_spef_nodes):
            if spef_node in spef_to_def:
                continue
            for spef_nb in graph.get(spef_node, {}).get('neighbors', {}):
                def_pt_nb = spef_to_def.get(spef_nb)
                if def_pt_nb is not None:
                    coords = _get_coords(def_pt_nb)
                    split_key = ('split', coords, frozenset())
                    def_to_spef[split_key] = spef_node
                    spef_to_def[spef_node] = split_key
                    spef_candidates.discard(spef_node)
                    point_to_pin[split_key] = f"InternalSteiner{coords}"
                    break

    # Third pass: Attempt to match remaining DEF points to SPEF nodes based on physical coordinates and reachable pin sets. #
    for pt in list(def_candidates):
        if pt in def_to_spef:
            continue
        if not (isinstance(pt, tuple) and len(pt) == 2 and pt[0] == 'virtual'):
            continue
        phys = pt[1]
        if phys not in def_to_spef:
            continue
        pt_pins = def_reachable.get(pt, set())
        if not pt_pins:
            continue
        for spef_node in list(spef_candidates):
            if spef_reachable.get(spef_node, set()) == pt_pins:
                def_to_spef[pt] = spef_node
                spef_to_def[spef_node] = pt
                spef_candidates.discard(spef_node)
                break

    # Fourth pass: For any remaining virtual DEF points, if they share physical coordinates with a mapped point, adopt that mapping. #
    for pt, data in def_net_info.get('steiner_points', {}).items():
        if data.get('virtual') and isinstance(pt, tuple) and pt[0] == 'virtual':
            if pt in def_to_spef:
                continue
            phys = data['coords']
            if phys in def_to_spef:
                spef_node = def_to_spef[phys]
                # KT-TODO: Only copy if the spef node is a steiner and not a pin
                if len(graph.get(spef_node, {}).get('neighbors', {})) >= 3:
                    def_to_spef[pt] = spef_node
                    if pt not in point_to_pin:
                        point_to_pin[pt] = f"VirtualSteiner{phys}"

    from __main__ import (insert_missing_spef_steiner_nodes,
                          split_edge_at_ratio, split_edge_at_coord,
                          _dedup_def_edges, _lookup_layer)

    insert_missing_spef_steiner_nodes(
        net_name, def_net_info, spef_net_info, graph,
        spef_adj, def_to_spef, spef_to_def,
        def_edges, def_adj, point_to_pin,
        def_net_info['point_pair_layer'], dbu_scale, verbose
    )

    _dedup_def_edges(def_edges, def_adj)

    zero_length_pairs = set()
    for pt, data in def_net_info.get('steiner_points', {}).items():
        if data.get('virtual') and isinstance(pt, tuple) and pt[0] == 'virtual':
            phys = data['coords']
            pair = (min(_point_sort_key(pt), _point_sort_key(phys)),
                    max(_point_sort_key(pt), _point_sort_key(phys)))
            zero_length_pairs.add(pair)
 
    def_reachable = _compute_def_reachable(
        def_driver_point, def_adj, point_to_pin, pin_points_set, zero_length_pairs)
    
    driver_pin_name_for_virtual = point_to_pin.get(def_driver_point)
    for pt, data in def_net_info.get('steiner_points', {}).items():
        if data.get('virtual') and isinstance(pt, tuple) and pt[0] == 'virtual':
            phys = data['coords']
            if phys == def_driver_point:
                driver_pins = def_reachable.get(def_driver_point, frozenset())
                if driver_pin_name_for_virtual:
                    def_reachable[pt] = frozenset(
                        p for p in driver_pins if p != driver_pin_name_for_virtual
                    )
                else:
                    def_reachable[pt] = driver_pins

    # Fifth pass: For any split DEF points, if they have a corresponding SPEF node, assign the reachable pin set from the SPEF graph. #
    for split_key, spef_node in def_to_spef.items():
        if isinstance(split_key, tuple) and split_key[0] == 'split':
            spef_pins = spef_reachable.get(spef_node, set())
            if split_key not in def_reachable:
                def_reachable[split_key] = frozenset(spef_pins)
 
    _assign_unmatched_def_nodes(
        def_edges, def_adj, def_to_spef, point_to_pin,
        spef_adj, verbose=verbose,
    )

    coord_to_spef = {}
    # First pass: record mappings for physical pin points (only) #
    for pt, spef_node in def_to_spef.items():
        if isinstance(pt, tuple) and isinstance(pt[0], str):
            continue  # skip virtual/split keys in first pass
        # pt is a physical coordinate (int,int)
        coord = _get_coords(pt)
        if coord not in coord_to_spef:
            coord_to_spef[coord] = spef_node

    # Second pass: for all points, if they share a coordinate with a pin, adopt that pin's SPEF node #
    for pt, spef_node in list(def_to_spef.items()):
        coord = _get_coords(pt)
        if coord in coord_to_spef:
            target = coord_to_spef[coord]
            if target != spef_node:
                # Reassign this point to the pin's SPEF node
                def_to_spef[pt] = target
                # Update reverse mapping
                if spef_node in spef_to_def and spef_to_def[spef_node] == pt:
                    del spef_to_def[spef_node]
                spef_to_def.setdefault(target, pt)
        else:
            # No pin at this coordinate, so this point becomes the authoritative mapping
            coord_to_spef[coord] = spef_node

    # Finally, build the edge map for DEF edges to SPEF nodes and check for mismatches in reachable pin sets. #
    edge_map = {}
    for e in def_edges:
        p1, p2 = e['p1'], e['p2']
        if p1 in def_to_spef and p2 in def_to_spef:
            n1 = def_to_spef[p1]
            n2 = def_to_spef[p2]
            if n1 == n2:
                edge_map[(p1, p2)] = (n1, n2, [n1])
            else:
                path = find_path_spef(n1, n2, spef_adj)
                if path:
                    edge_map[(p1, p2)] = (n1, n2, path)
 
    def_edge_lookup = {(e['p1'], e['p2']): e for e in def_edges}
    edge_mismatch_count = 0
    for (p1, p2), (n1, n2, path) in edge_map.items():
        e = def_edge_lookup.get((p1, p2), {})
        if e.get('zero_length') or n1 == n2:
            continue
        pins_from_def_p2 = def_reachable.get(p2, frozenset()) - def_reachable.get(p1, frozenset())
        pins_from_spef_n2 = spef_reachable.get(n2, set()) - spef_reachable.get(n1, set())
        if pins_from_def_p2 != pins_from_spef_n2:
            edge_mismatch_count += 1
 
    return def_to_spef, edge_map

# Selects a driver node from the SPEF graph that can reach all pin names in the net. #
def _select_driver(net_name, all_pin_nodes, graph, spef_adj, all_pin_names, is_pin_node, verbose):
    # Names of all pins that can be reached from a SPEF node (depth-first search over the SPEF adjacency). #
    def _reachable_pins(start):
        visited = set()
        reachable = set()
        stack = [start]
        while stack:
            node = stack.pop()
            if node in visited:
                continue
            visited.add(node)
            if node in all_pin_nodes and graph[node].get('def_name'):
                reachable.add(graph[node]['def_name'])
            stack.extend(nb for nb in spef_adj.get(node, []) if nb not in visited)
        return reachable

    # Case 1: cell output pins (direction O, has colon) #
    cell_output_pins = [n for n in all_pin_nodes
                        if graph[n].get('direction') == 'O' and ':' in n]
    for cand in sorted(cell_output_pins):
        if _reachable_pins(cand) >= all_pin_names:
            return cand, graph[cand]['def_name']

    # Case 2: top-level input ports (direction I, no colon) #
    toplevel_inputs = [n for n in all_pin_nodes
                       if graph[n].get('direction') == 'I' and ':' not in n]
    for cand in sorted(toplevel_inputs):
        if _reachable_pins(cand) >= all_pin_names:
            return cand, graph[cand]['def_name']

    # Case 3: any output pin (direction O, including top-level output ports) #
    output_pins = [n for n in all_pin_nodes if graph[n].get('direction') == 'O']
    for cand in sorted(output_pins):
        if _reachable_pins(cand) >= all_pin_names:
            return cand, graph[cand]['def_name']

    # Case 4: any input pin that can reach everything #
    input_pins = sorted([n for n in all_pin_nodes
                         if ':' not in n and graph[n].get('direction') == 'I'])
    for cand in input_pins:
        if _reachable_pins(cand) >= all_pin_names:
            return cand, graph[cand]['def_name']

    for node_id in sorted(spef_adj):
        pins = _reachable_pins(node_id)
        if pins >= all_pin_names:
            any_pin = next(iter(pins))
            return node_id, any_pin

    best_node = None
    best_pins = set()
    for node_id in spef_adj:
        pins = _reachable_pins(node_id)
        if len(pins) > len(best_pins):
            best_pins = pins
            best_node = node_id
    if best_node is not None and best_pins:
        any_pin = next(iter(best_pins))
        return best_node, any_pin

    for node_id in sorted(spef_adj):
        pins = _reachable_pins(node_id)
        if pins:
            return node_id, next(iter(pins))

    for node_id in sorted(spef_adj):
        return node_id, graph[node_id].get('def_name', node_id)

    return None, None

# This function rewires DEF edges to accommodate a split at a specified coordinate, #
# ensuring that the DEF representation aligns with the SPEF representation.         #
# It identifies edges that pass through a specified SPEF node and splits them at    #
# the given coordinate, creating new edges and updating adjacency lists accordingly.#
# Additionally, it adds a zero-length edge between the original DEF point and the   #
# split point to maintain connectivity.                                             #
def _rewire_edges_for_split(def_pt, split_key, spef_node,
                            def_edges, def_adj, def_to_spef,
                            point_to_pin, spef_pins, spef_reachable,
                            graph, spef_adj, def_candidates, def_reachable,
                            collapsed_spef_adj=None, verbose=False):

    edges_to_remove = []
    edges_to_add = []

    path_adj = collapsed_spef_adj if collapsed_spef_adj is not None else spef_adj

    # Identify edges in the DEF net that pass through the specified SPEF node #
    # and split them at the given coordinate.                                 #
    for e in list(def_edges):
        p1, p2 = e['p1'], e['p2']
        if p1 not in def_to_spef or p2 not in def_to_spef:
            continue
        n1 = def_to_spef[p1]
        n2 = def_to_spef[p2]
        full_path = find_path_spef(n1, n2, path_adj)
        if full_path is None or spef_node not in full_path:
            continue
        idx = full_path.index(spef_node)
        if idx == 0 or idx == len(full_path) - 1:
            continue

        intermediates = e.get('intermediate', [])
        split_coord = _get_coords(split_key)

        all_points = [p1] + intermediates + [p2]

        split_after = None        
        split_x, split_y = split_coord

        for i in range(len(all_points) - 1):
            ax, ay = _get_coords(all_points[i])
            bx, by = _get_coords(all_points[i + 1])
            if ax == bx and ax == split_x and min(ay, by) <= split_y <= max(ay, by):
                split_after = i
                break
            if ay == by and ay == split_y and min(ax, bx) <= split_x <= max(ax, bx):
                split_after = i
                break

        if split_after is not None:
            intermediates_p1 = [pt for pt in all_points[1:split_after + 1]
                                 if _get_coords(pt) != split_coord]
            intermediates_p2 = [pt for pt in all_points[split_after + 1:-1]
                                 if _get_coords(pt) != split_coord]
        else:
            intermediates_p1 = []
            intermediates_p2 = []

        edges_to_remove.append(e)
        edges_to_add.append({'p1': p1,        'p2': split_key, 'intermediate': intermediates_p1})
        edges_to_add.append({'p1': split_key, 'p2': p2,        'intermediate': intermediates_p2})

    remove_ids = {id(e) for e in edges_to_remove}
    def_edges[:] = [e for e in def_edges if id(e) not in remove_ids]

    for e in edges_to_add:
        def_edges.append(e)
        p1, p2 = e['p1'], e['p2']
        def_adj[p1].append(p2)
        def_adj[p2].append(p1)

    for e in edges_to_remove:
        p1, p2 = e['p1'], e['p2']
        if p2 in def_adj[p1]:
            def_adj[p1].remove(p2)
        if p1 in def_adj[p2]:
            def_adj[p2].remove(p1)

    zero_edge = {'p1': def_pt, 'p2': split_key,
                 'intermediate': [], 'zero_length': True}
    def_edges.append(zero_edge)
    def_adj[def_pt].append(split_key)
    def_adj[split_key].append(def_pt)

# Remove duplicate edges (same end coordinates) of a DEF net. The edge with the most intermediate points is kept, #
# or the non-zero-length one.                                                                                     #
def _dedup_def_edges(def_edges, def_adj):
    seen_pairs = {}
    for e in def_edges:
        p1, p2 = e['p1'], e['p2']
        coord1 = _get_coords(p1)
        coord2 = _get_coords(p2)
        key = (min(coord1, coord2), max(coord1, coord2))
        existing = seen_pairs.get(key)
        if existing is None:
            seen_pairs[key] = e
        else:
            existing_is_zero = existing.get('zero_length', False)
            new_is_zero = e.get('zero_length', False)
            if existing_is_zero and not new_is_zero:
                seen_pairs[key] = e
            elif not existing_is_zero and not new_is_zero:
                if len(e.get('intermediate', [])) > len(existing.get('intermediate', [])):
                    seen_pairs[key] = e

    deduped_edges = list(seen_pairs.values())
    def_adj.clear()
    for e in deduped_edges:
        p1, p2 = e['p1'], e['p2']
        def_adj[p1].append(p2)
        def_adj[p2].append(p1)
    def_edges[:] = deduped_edges

# Compute the correlation between DEF edges and SPEF edges, including metal layers, resistances, and capacitances. #
# This function takes the DEF and SPEF net information, along with the mapping between DEF points and SPEF nodes,  #
# and computes the correlation of edge properties such as resistance and capacitance. It returns a list of raw     #
# entries containing the computed values for each edge in the DEF net.                                             #
def compute_edge_rc_correlation_with_metal(net_name, def_net_info, spef_net_info, def_to_spef, edge_map, dbu_scale, graph, spef_edge_dict=None):
    if spef_edge_dict is None:
        spef_edge_dict = {}
        for e in spef_net_info.get('spef_collapsed_edges', []):
            n1, n2 = e['node1'], e['node2']
            spef_edge_dict[(n1, n2)] = e
            spef_edge_dict[(n2, n1)] = e
 
    point_pair_layer = def_net_info.get('point_pair_layer', {})
    all_def_edges = def_net_info.get('def_edges', [])
    point_to_pin = def_net_info.get('point_to_pin', {})
 
    raw_entries = []         
    groups = defaultdict(list)
    
    # Iterate through all DEF edges and compute the correlation with SPEF edges, #
    # including metal layers, resistances, and capacitances.                     #
    for def_edge in all_def_edges:
        p1, p2 = def_edge['p1'], def_edge['p2']
        if (p1, p2) not in edge_map:
            continue
 
        spef_n1, spef_n2, path_nodes = edge_map[(p1, p2)]
        zero_len_edge = def_edge.get('zero_length', False)

        if '_split_info' in def_edge:
            info = def_edge['_split_info']
            total_len_dbu = info['total_len']
            ratio = info['ratio']
            points = [p1] + def_edge.get('intermediate', []) + [p2]
            length_by_layer_dbu = defaultdict(float)
            total_len_this_dbu = 0
            for i in range(len(points) - 1):
                a, b = points[i], points[i + 1]
                ax, ay = _get_coords(a)
                bx, by = _get_coords(b)
                if (ax, ay) == (bx, by):
                    continue
                seg_len = abs(bx - ax) + abs(by - ay)
                layer = _lookup_layer(point_pair_layer, a, b) or "unknown"
                length_by_layer_dbu[layer] += seg_len
                total_len_this_dbu += seg_len
        else:
            points = [p1] + def_edge.get('intermediate', []) + [p2]
            length_by_layer_dbu = defaultdict(float)
            total_len_this_dbu = 0
            for i in range(len(points) - 1):
                a, b = points[i], points[i + 1]
                ax, ay = _get_coords(a)
                bx, by = _get_coords(b)
                if (ax, ay) == (bx, by):
                    continue
                seg_len = abs(bx - ax) + abs(by - ay)
                layer = _lookup_layer(point_pair_layer, a, b) or "unknown"
                length_by_layer_dbu[layer] += seg_len
                total_len_this_dbu += seg_len
 
        length_by_layer = {lyr: l / dbu_scale
                           for lyr, l in length_by_layer_dbu.items()}
        total_length_um = total_len_this_dbu / dbu_scale
 
        raw_R = 0.0
        raw_C = 0.0
        spef_edge_resistances = []
        for i in range(len(path_nodes) - 1):
            n_a, n_b = path_nodes[i], path_nodes[i + 1]
            se = spef_edge_dict.get((n_a, n_b))
            if se:
                raw_R += se['total_resistance']
                raw_C += se['total_capacitance']
                spef_edge_resistances.append(se['total_resistance'])
            else:
                spef_edge_resistances.append(0.0)
 
        C_path_total = sum(graph[nd]['cap'] for nd in path_nodes if nd in graph)
        C_start_node = graph[spef_n1]['cap'] if spef_n1 in graph else 0.0
        C_end_node = graph[spef_n2]['cap'] if spef_n2 in graph else 0.0
 
        label1 = point_to_pin.get(p1, f"Steiner{p1}")
        label2 = point_to_pin.get(p2, f"Steiner{p2}")
 
        path_key = frozenset(path_nodes)
        path_key = tuple(path_nodes) if path_nodes[0] <= path_nodes[-1] else tuple(reversed(path_nodes))
 
        raw_entries.append({
            'endpoints':            (label1, label2),
            'coords':               (p1, p2),
            'length_by_layer':      dict(length_by_layer),
            'total_length_um':      total_length_um,
            'R_ohms':               raw_R,
            'C_pf':                 raw_C,
            'C_start_node':         C_start_node,
            'C_end_node':           C_end_node,
            'spef_nodes':           (spef_n1, spef_n2),
            'C_path_total':         C_path_total,
            'def_edge':             def_edge,
            'path_edges':           len(path_nodes) - 1,
            'direct_match':         1 if len(path_nodes) == 2 else 0,
            'spef_edge_resistances':spef_edge_resistances,
            'path_key':             path_key,
            'zero_len_edge':        zero_len_edge,
        })

    hop_users = defaultdict(list) 
    for idx, entry in enumerate(raw_entries):
        if entry['zero_len_edge']:
            continue
        path = entry['path_key']
        for i in range(len(path)-1):
            hop = tuple(sorted((path[i], path[i+1])))
            hop_users[hop].append(idx)

    hop_r = {} 
    for idx, entry in enumerate(raw_entries):
        path = entry['path_key']
        for i in range(len(path) - 1):
            nA, nB = path[i], path[i+1]
            hop = (nA, nB) if nA <= nB else (nB, nA)
            if hop not in hop_r:
                se = spef_edge_dict.get((path[i], path[i+1])) or \
                    spef_edge_dict.get((path[i+1], path[i]))
                hop_r[hop] = se['total_resistance'] if se else 0.0

    # Iterate through the raw entries and compute the total resistance for each edge, # 
    # prorating the resistance based on the length of the edge relative to the total  #
    # length of the path.                                                             #
    for idx, entry in enumerate(raw_entries):
        if entry.get('zero_len_edge', False):
            entry['R_ohms'] = 0.0
            entry['C_pf'] = 0.0
            continue

        # Clamp virtual Steiner artifact edges connecting a virtual Steiner node to adjacent routing. #
        # Their true R is negligible                                                                  #
        p1, p2 = entry['coords']
        is_short = entry['total_length_um'] < 0.05
        has_virtual = (
            (isinstance(p1, tuple) and isinstance(p1[0], str) and p1[0] == 'virtual') or
            (isinstance(p2, tuple) and isinstance(p2[0], str) and p2[0] == 'virtual')
        )
        if is_short and has_virtual:
            entry['R_ohms'] = 0.001
            entry['C_pf'] = 0.0
            continue

        path = entry['path_key']
        total_r = 0.0
        for i in range(len(path) - 1):
            nA, nB = path[i], path[i+1]
            hop = (nA, nB) if nA <= nB else (nB, nA)
            users = hop_users[hop]
            if len(users) == 1:
                total_r += hop_r[hop]
            else:
                sorted_users = sorted(
                    users,
                    key=lambda u: (
                        _get_coords(raw_entries[u]['coords'][0]),
                        _get_coords(raw_entries[u]['coords'][1])
                    )
                )
                total_len = sum(
                    raw_entries[u]['total_length_um']
                    for u in sorted_users
                    if not raw_entries[u]['zero_len_edge']
                )
                frac = entry['total_length_um'] / total_len if total_len > 0 else 0.0
                total_r += hop_r[hop] * frac
        entry['R_ohms'] = total_r
        entry.setdefault('stub_relumped', 0)

    # Move pin/via resistance from very short stub edges. A stub shorter than STUB_LEN_UM that is the only user    # 
    # of a SPEF hop may have 5–15 Ohm of pin/via resistance despite having almost no wire. The excess resistance   #
    # is moved to neighbouring edges that share a point with the stub, keeping the total net resistance unchanged. #
    # stub_relumped: 1 = moved, 2 = no neighbour found (kept unchanged).                                           #
    STUB_LEN_UM = 0.15 # um, an edge shorter than this is a stub #
    STUB_R_MIN = 0.5 # Ohm, a stub is only corrected above this resistance #
    R_SHEET_FLOOR = 0.20 # Ohm/um, resistance the stub geometry justifies #
    STUB_R_RATIO = 5.0 # a stub is only corrected if R is at least this many times the geometric resistance #

    _pt_entries = defaultdict(list)
    for _j, _e in enumerate(raw_entries):
        if _e.get('zero_len_edge'):
            continue
        for _pt in _e['coords']:
            _pt_entries[_pt].append(_j)

    for _e in raw_entries:
        if _e.get('zero_len_edge'):
            continue
        _L = _e['total_length_um']
        if _L >= STUB_LEN_UM or _e['R_ohms'] < STUB_R_MIN:
            continue
        _geo = max(_L * R_SHEET_FLOOR, 0.001)
        if _e['R_ohms'] < STUB_R_RATIO * _geo:
            continue
        _excess = _e['R_ohms'] - _geo
        _nbrs = set()
        for _pt in _e['coords']:
            for _k in _pt_entries.get(_pt, ()):
                _n = raw_entries[_k]
                if _n is _e or _n.get('zero_len_edge'):
                    continue
                if _n['total_length_um'] >= STUB_LEN_UM:
                    _nbrs.add(_k)
        _e['R_ohms'] = _geo
        if _nbrs:
            _share = _excess / len(_nbrs)
            for _k in _nbrs:
                raw_entries[_k]['R_ohms'] += _share
            _e['stub_relumped'] = 1
        else:
            _e['R_ohms'] += _excess 
            _e['stub_relumped'] = 2

    results = []
    for entry in raw_entries:
        results.append({k: v for k, v in entry.items()
                        if k not in ('path_key', 'zero_len_edge')})
        path_nodes = entry['path_key']
 
    return results

# Compute total DEF length in microns from DEF edges, skipping zero-length edges #
def compute_total_def_length_from_edges(def_edges, dbu_scale):
    total = 0.0
    for e in def_edges:
        if e.get('zero_length'):
            continue
        points = [e['p1']] + e.get('intermediate', []) + [e['p2']]
        for i in range(len(points) - 1):
            ax, ay = _get_coords(points[i])
            bx, by = _get_coords(points[i + 1])
            total += abs(bx - ax) + abs(by - ay)
    return total / dbu_scale

# Compute edge features for CSV output, including length coverage and resistance checks #
# Returns: (list of edge feature dicts, list of error messages, coverage message)       #
def compute_edge_features_for_csv(
    net_name, def_net_info, spef_net_info, rc_data,
    def_to_spef, edge_map, graph, dbu_scale,
    spef_total_R, spef_total_cap,
    total_length_mapped, total_def_length_um,
    def_adj=None,
    tree_depth=None,
    n_sink_pins=0,
    subtree_n_sinks=None,
    subtree_total_len=None,
    driver_def_point=None,
    driver_spef_node=None,
    r_tol=1e-6
):
    
    if total_def_length_um > 0:
        coverage = total_length_mapped / total_def_length_um
    else:
        return [], [], "zero total DEF length"

    if abs(coverage - 1.0) > 0.01:
        return [], [], (f"length coverage {coverage*100:.2f}% != 100%  "
                        f"(mapped {total_length_mapped:.3f} um / "
                        f"total {total_def_length_um:.3f} um)")

    total_R_mapped = sum(
        item['R_ohms'] for item in rc_data
        if not item['def_edge'].get('zero_length', False)
    )

    if spef_total_R > 1e-9:
        rel_error = abs(total_R_mapped - spef_total_R) / spef_total_R
        abs_error = abs(total_R_mapped - spef_total_R)
        if rel_error > 0.005 and abs_error > 1.0:
            PIN_CONTACT_TOLERANCE = 6.0
            if abs_error > PIN_CONTACT_TOLERANCE:
                return [], [], (f"R mismatch: mapped {total_R_mapped:.6f} Ohm "
                                f"vs SPEF {spef_total_R:.6f} Ohm  "
                                f"(diff {total_R_mapped - spef_total_R:.6f}, "
                                f"rel {rel_error*100:.2f}%)")

    all_layers = set()
    all_via_types = set()
    for seg in def_net_info.get('segments', []):
        all_layers.add(seg['layer'])
        if seg.get('via'):
            all_via_types.add(seg['via'])

    point_to_via = {}
    for seg in def_net_info.get('segments', []):
        if seg.get('via'):
            point_to_via[seg['points'][-1]] = seg['via']

    rows = []

    # Iterate over each edge in rc_data to build feature rows for CSV output #
    for edge_idx, item in enumerate(rc_data):
        p1, p2 = item['coords']
        label1, label2 = item['endpoints']

        def_edge = item['def_edge']
        points = [p1] + def_edge.get('intermediate', []) + [p2]

        length_by_layer = item['length_by_layer']

        point_pairs_set = {(points[i], points[i+1]) for i in range(len(points)-1)}
        point_pairs_set |= {(b, a) for a, b in point_pairs_set}

        contributing_seg_ids = set()
        for seg in def_net_info['segments']:
            pts = seg['points']
            for i in range(len(pts)-1):
                if (pts[i], pts[i+1]) in point_pairs_set:
                    contributing_seg_ids.add(seg['id'])
                    break

        via_counts = defaultdict(int)
        for pt in points:
            if pt in point_to_via:
                via_counts[point_to_via[pt]] += 1

        is_zero_len = item['def_edge'].get('zero_length', False)
        is_short = item['total_length_um'] < 0.05
        has_virtual = (
            (isinstance(p1, tuple) and isinstance(p1[0], str) and p1[0] == 'virtual') or
            (isinstance(p2, tuple) and isinstance(p2[0], str) and p2[0] == 'virtual')
        )
        is_virtual_steiner_flag = int(is_zero_len or (0 and has_virtual))

        row = {
            'net_name': net_name,
            'edge_idx': edge_idx,
            'endpoint_1': label1,
            'endpoint_2': label2,
            'coord_x1': p1[0] if not isinstance(p1[0], str) else _get_coords(p1)[0],
            'coord_y1': p1[1] if not isinstance(p1[0], str) else _get_coords(p1)[1],
            'coord_x2': p2[0] if not isinstance(p2[0], str) else _get_coords(p2)[0],
            'coord_y2': p2[1] if not isinstance(p2[0], str) else _get_coords(p2)[1],
            'R_ohms': item['R_ohms'], # Resistance target #
            'C_edge_pf': item['C_pf'], # Capacitance target #
            'path_edges': item.get('path_edges', 0),
            'direct_match': item.get('direct_match', 0),
            'stub_relumped': item.get('stub_relumped', 0),
            **{f'len_{lyr}': length_by_layer.get(lyr, 0.0) for lyr in sorted(all_layers)}, # Geometry features #
            **{f'n_via_{vt}': via_counts.get(vt, 0) for vt in sorted(all_via_types)}, # Geometry features #
            'total_vias': sum(via_counts.values()),
            'total_len_um': item['total_length_um'],
            'is_virtual_steiner': is_virtual_steiner_flag,
        }

        rows.append(row)

    # Build per-node rows #
    node_rows = []

    # Accumulate incident lengths per SPEF node from rc_data #
    node_incident_lengths = defaultdict(lambda: defaultdict(float))
    node_incident_total = defaultdict(float)
    for item in rc_data:
        if item['def_edge'].get('zero_length'):
            continue
        p1, p2 = item['coords']
        for pt in [p1, p2]:
            spef_node = def_to_spef.get(pt)
            if spef_node is None:
                continue
            for layer, length in item['length_by_layer'].items():
                node_incident_lengths[spef_node][layer] += length / 2.0
            node_incident_total[spef_node] += item['total_length_um'] / 2.0

    all_layers = set()
    for seg in def_net_info.get('segments', []):
        all_layers.add(seg['layer'])

    LAYER_ORDER = ['metal1', 'metal2', 'metal3', 'metal4', 'metal5',
                   'metal6', 'metal7', 'metal8', 'metal9', 'metal10']
    LAYER_IDX = {l: i for i, l in enumerate(LAYER_ORDER)}

    # Build incident via info per SPEF node #
    node_incident_vias = defaultdict(int)
    node_max_via_level = defaultdict(int)
    node_min_via_level = defaultdict(lambda: 99)

    # Iterate over rc_data to count incident vias and their levels for each SPEF node #
    _tv = _global_tech_vias
    for item in rc_data:
        if item['def_edge'].get('zero_length'):
            continue
        p1, p2 = item['coords']
        def_edge = item['def_edge']
        points = [p1] + def_edge.get('intermediate', []) + [p2]
        for pt in points:
            via_name = point_to_via.get(pt)
            if via_name is None:
                continue
            spef_node = def_to_spef.get(pt)
            if spef_node is None:
                continue
            node_incident_vias[spef_node] += 1
            via_layers = [LAYER_IDX[l] for l, _ in _tv.get(via_name, [])
                          if l in LAYER_IDX and not l.startswith('via')]
            if via_layers:
                node_max_via_level[spef_node] = max(node_max_via_level[spef_node], max(via_layers))
                node_min_via_level[spef_node] = min(node_min_via_level[spef_node], min(via_layers))

    # Determine depth offset based on driver SPEF node and tree depth, if available #
    # Rank of a DEF point of a SPEF node, lower is preferred as the representative point: virtual 0, virtual_spf 1, split 2, raw 3. #
    def _def_pt_priority(def_pt):
        if not (isinstance(def_pt, tuple) and isinstance(def_pt[0], str)):
            return 3
        if def_pt[0] == 'virtual':
            return 0
        if def_pt[0] == 'virtual_spf':
            return 1
        if def_pt[0] == 'split':
            return 2
        return 3

    driver_raw_depth = None
    if driver_spef_node is not None and tree_depth is not None:
        driver_candidates = [
            def_pt for def_pt, sn in def_to_spef.items()
            if sn == driver_spef_node
        ]
        driver_candidates.sort(key=_def_pt_priority)  
        for def_pt in driver_candidates:
            d = tree_depth.get(def_pt)
            if d is not None:
                driver_raw_depth = d
                break

    depth_offset = driver_raw_depth if driver_raw_depth is not None else 0

    seen_spef_nodes = set()

    # Iterate over each DEF point and its corresponding SPEF node to build node feature rows for CSV output #
    for def_pt, spef_node in sorted(def_to_spef.items(), key=lambda kv: _def_pt_priority(kv[0])):
        if spef_node in seen_spef_nodes:
            continue
        seen_spef_nodes.add(spef_node)

        coords = _get_coords(def_pt)
        node_data = graph.get(spef_node, {})
        cap = node_data.get('cap', 0.0)
        direction = node_data.get('direction')
        is_pin_flag = int(node_data.get('coords') is not None and direction is not None)

        if driver_spef_node is not None and spef_node == driver_spef_node:
            is_driver_pin = 1
            is_sink_pin = 0
        elif driver_spef_node is not None:
            is_driver_pin = 0
            is_sink_pin = int(is_pin_flag == 1 and direction is not None)
        else:
            is_driver_pin = int(direction == 'O')
            is_sink_pin = int(direction == 'I')

        spef_neighbors = graph.get(spef_node, {}).get('neighbors', {})
        degree = len(def_adj[def_pt]) if (def_adj is not None and def_pt in def_adj) else len(spef_neighbors)
   
        depth = tree_depth.get(def_pt, -1) if tree_depth is not None else -1

        if depth == -1 and tree_depth is not None:
            raw_coords = _get_coords(def_pt)
            depth = tree_depth.get(raw_coords, -1)
            if depth == -1:
                virtual_depth = tree_depth.get(('virtual', raw_coords), -1)
                if virtual_depth != -1:
                    depth = virtual_depth
                else:
                    for k, d in tree_depth.items():
                        if _get_coords(k) == raw_coords:
                            depth = d
                            break
                    if depth == -1 and def_adj is not None:
                        neighbor_depths = [
                            tree_depth.get(nbr, -1)
                            for nbr in def_adj.get(def_pt, [])
                            if tree_depth.get(nbr, -1) != -1
                        ]
                        if neighbor_depths:
                            depth = min(neighbor_depths) + 1

        # Apply offset after all depth resolution is complete #
        if depth != -1 and depth_offset != 0:
            depth = depth - depth_offset

        sub_sinks = subtree_n_sinks.get(def_pt, 0) if subtree_n_sinks is not None else 0
        sub_len = subtree_total_len.get(def_pt, 0.0) if subtree_total_len is not None else 0.0

        inc_lengths = node_incident_lengths[spef_node]
        active_layers = [LAYER_IDX[l] for l in inc_lengths if inc_lengths[l] > 0 and l in LAYER_IDX]
        n_active_layers = len(active_layers)
        max_layer_idx = max(active_layers) if active_layers else 0
        min_layer_idx = min(active_layers) if active_layers else 0
        layer_span = max_layer_idx - min_layer_idx

        inc_vias = node_incident_vias[spef_node]
        max_via_level = node_max_via_level[spef_node]
        min_via_level = node_min_via_level[spef_node] if node_min_via_level[spef_node] != 99 else 0
        via_stack_height = max_via_level - min_via_level

        node_rows.append({
            'net_name':            net_name,
            'node_id':             str(spef_node),
            'coord_x':             coords[0],
            'coord_y':             coords[1],
            'is_pin':              is_pin_flag,
            'is_driver_pin':       is_driver_pin,
            'is_sink_pin':         is_sink_pin,
            'node_degree':         degree,
            'tree_depth':          depth,
            'n_sink_pins':         n_sink_pins,
            'subtree_n_sinks':     sub_sinks,
            'subtree_total_len':   sub_len,
            'n_active_layers':     n_active_layers,
            'max_layer_idx':       max_layer_idx,
            'layer_span':          layer_span,
            'incident_vias':       inc_vias,
            'max_via_level':       max_via_level,
            'via_stack_height':    via_stack_height,
            **{f'len_{lyr}': node_incident_lengths[spef_node].get(lyr, 0.0)
               for lyr in sorted(all_layers)},
            'total_incident_len_um': node_incident_total[spef_node],
            'C_node_pf':                cap,
        })

    return rows, node_rows, ""

# Write the rows to the output CSV, with the fixed columns first and then the length and via columns found in the #
# data. Missing values get defaults.                                                                              #
def write_dataset_csv(output_csv_path, all_rows):
    if not all_rows:
        print("WARNING: No rows to write, CSV not created")
        return

    fixed_prefix = [
        'net_name', 'edge_idx', 'endpoint_1', 'endpoint_2',
        'coord_x1', 'coord_y1', 'coord_x2', 'coord_y2',
        'R_ohms', 'C_edge_pf',
        'path_edges', 'direct_match',
    ]

    all_keys = set()
    for row in all_rows:
        all_keys.update(row.keys())

    len_cols = sorted(k for k in all_keys if k.startswith('len_'))
    via_cols = sorted(k for k in all_keys if k.startswith('n_via_'))

    fieldnames = fixed_prefix + len_cols + via_cols + ['total_vias', 'total_len_um', 'is_virtual_steiner', 'stub_relumped']

    with open(output_csv_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction='ignore')
        writer.writeheader()
        for row in all_rows:
            for col in len_cols + via_cols:
                row.setdefault(col, 0.0)
            row.setdefault('is_virtual_steiner', 0)
            row.setdefault('stub_relumped', 0)
            writer.writerow(row)

    print(f"INFO: Wrote {len(all_rows):,} rows to {output_csv_path}")

# Write a reduced Pi-model SPEF file with new internal node IDs and optional port lines #
# The function takes the output path, the SPEF nets data, the graph of nodes, a mapping #
# from original IDs to names, the original name map lines, and optional raw port lines. #
# It generates a new SPEF file with updated internal node IDs and writes it to the      #
# specified output path.                                                                #
def write_pi_spef(output_path, spef_nets, graph, original_id_to_name, original_name_map_lines, ports_raw_lines=None):
    if ports_raw_lines is None:
        ports_raw_lines = []

    internal_name_map = {}

    for net_name, net_data in spef_nets.items():
        net_spef_id = net_data['spef_id']
        edges = net_data.get('spef_collapsed_edges', [])
        if not edges:
            continue

        net_nodes = set()
        for e in edges:
            net_nodes.update([e['node1'], e['node2']])

        pins = {nid for nid in net_nodes
                if graph[nid].get('def_name') and graph[nid].get('coords')}
        internal_nodes = net_nodes - pins

        new_id_map = {nid: nid for nid in pins}
        for counter, nid in enumerate(sorted(internal_nodes), start=1):
            new_id = f"{net_spef_id}:{counter}"
            new_id_map[nid] = new_id
            internal_name_map[new_id] = f"internal_{net_name}_{counter}"

        net_data['_new_id_map'] = new_id_map

    with open(output_path, 'w') as f:
        f.write("*SPEF \"IEEE 1481-1998\"\n")
        f.write("*DESIGN \"reduced_from_{}\"\n".format(
            next(iter(spef_nets), "design")))
        f.write("*DATE \"{}\"\n".format(datetime.date.today().isoformat()))
        f.write("*VENDOR \"auto\"\n")
        f.write("*PROGRAM \"STEINER TREE - 1 PI-MODEL REDUCED SPEF\"\n")
        f.write("*VERSION \"1.0\"\n")
        f.write("*DIVIDER /\n")
        f.write("*DELIMITER :\n")
        f.write("*BUS_DELIMITER [ ]\n")
        f.write("*T_UNIT 1 NS\n")
        f.write("*C_UNIT 1 PF\n")
        f.write("*R_UNIT 1 OHM\n")
        f.write("*L_UNIT 1 HENRY\n")

        for line in original_name_map_lines:
            f.write(line + "\n")
        for line in ports_raw_lines:
            f.write(line + "\n")

        for net_name, net_data in spef_nets.items():
            net_spef_id = net_data['spef_id']
            edges = net_data.get('spef_collapsed_edges', [])
            if not edges:
                continue

            new_id_map = net_data['_new_id_map']
            net_nodes = set()
            for e in edges:
                net_nodes.update([e['node1'], e['node2']])

            node_total_cap = {}
            for node_id in net_nodes:
                total = graph[node_id]['cap']
                for e in edges:
                    if e['node1'] == node_id or e['node2'] == node_id:
                        total += e['total_capacitance'] / 2.0
                node_total_cap[node_id] = total

            total_net_cap = sum(node_total_cap.values())

            f.write(f"*D_NET {net_spef_id} {total_net_cap:.8f}\n")

            if net_data.get('raw_conn'):
                for line in net_data['raw_conn']:
                    f.write(line + "\n")
            else:
                pins = [nid for nid in net_nodes
                        if graph[nid].get('def_name') and graph[nid].get('coords')]
                if pins:
                    f.write("*CONN\n")
                    for nid in pins:
                        new_id = new_id_map[nid]
                        direction = graph[nid].get('direction', 'I')
                        x, y = graph[nid]['coords']
                        f.write(f"*P {new_id} {direction} *C {x:.3f} {y:.3f} *L 0\n")

            f.write("*CAP\n")
            for cap_idx, node_id in enumerate(sorted(net_nodes), start=1):
                f.write(f"{cap_idx} {new_id_map[node_id]} "
                        f"{node_total_cap[node_id]:.8f}\n")

            f.write("*RES\n")
            # Order of the two resistor ends in the SPEF. Nodes with direction I come first, nodes without direction next, the others last. #
            def priority(d):
                return 0 if d == 'I' else (1 if d is None else 2)

            for res_idx, e in enumerate(edges, start=1):
                o1, o2 = e['node1'], e['node2']
                p1_pri = priority(graph[o1].get('direction'))
                p2_pri = priority(graph[o2].get('direction'))
                if p1_pri < p2_pri or (p1_pri == p2_pri and o1 <= o2):
                    first, second = new_id_map[o1], new_id_map[o2]
                else:
                    first, second = new_id_map[o2], new_id_map[o1]
                f.write(f"{res_idx} {first} {second} {e['total_resistance']:.8f}\n")

            f.write("*END\n\n")

    print(f"INFO: Wrote Pi model SPEF to {output_path}")

# Write node-level dataset CSV with features and targets for each SPEF node #
def write_node_csv(output_csv_path, all_rows):
    if not all_rows:
        print("WARNING: No node rows to write, node CSV not created")
        return

    all_keys = set()
    for row in all_rows:
        all_keys.update(row.keys())

    fixed_prefix = [
        'net_name', 'node_id', 'coord_x', 'coord_y',
        'is_pin', 'is_driver_pin', 'is_sink_pin',
        'node_degree', 'tree_depth', 'n_sink_pins',
        'subtree_n_sinks', 'subtree_total_len',
        'n_active_layers', 'max_layer_idx', 'layer_span',
        'incident_vias', 'max_via_level', 'via_stack_height',
    ]
    len_cols = sorted(k for k in all_keys if k.startswith('len_'))
    fieldnames = fixed_prefix + len_cols + ['total_incident_len_um', 'C_node_pf']

    with open(output_csv_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction='ignore')
        writer.writeheader()
        for row in all_rows:
            for col in len_cols:
                row.setdefault(col, 0.0)
            writer.writerow(row)

    print(f"INFO: Wrote {len(all_rows):,} node rows to {output_csv_path}")

# Command line arguments: LEF (JSON cache or LEF files), DBU, DEF, SPEF, and optional output paths for the edge CSV and the Pi-model SPEF. #
def parse_args():
    p = argparse.ArgumentParser(
        description="Correlate DEF routing topology with SPEF RC parasitics."
    )
    lef_group = p.add_mutually_exclusive_group(required=True)
    lef_group.add_argument("--lef-json", dest="lef_json",
                           help="Path to LEF JSON cache")
    lef_group.add_argument("--lef", dest="lef_path",
                           help="Path to cell LEF file (use with --tech-lef)")
    p.add_argument("--tech-lef", dest="tech_lef_path",
                   help="Path to technology LEF file (required when using --lef)")
    p.add_argument("dbu", type=float, help="DBU multiplier (e.g. 1000)")
    p.add_argument("def_path", help="Path to DEF file")
    p.add_argument("spef_path", help="Path to SPEF file")
    p.add_argument("-v", "--verbose", action="store_true",
                   help="Enable verbose debug output")
    p.add_argument("--output_spef", help="Optional path to write reduced Pi-model SPEF")
    p.add_argument("--output_csv", help="Optional path to write per-edge dataset CSV")
    return p.parse_args()

# Read the LEF, DEF and SPEF files and align the DEF routing tree of every net with the SPEF RC tree. The nets are processed in #
# parallel (process_net). The edge rows (R, C, length, topology features) are written to the CSV with the node rows next to it, #
# and the reduced Pi-model SPEF is written if requested. The summary of dropped and skipped nets is printed at the end.         #
def main():
    args = parse_args()

    # Command line and timer #
    total_start = time.perf_counter()
    verbose = args.verbose

    
    if args.lef_json:
        # load LEF JSON cache (faster than parsing LEF) #
        cells, tech_vias, tech_viarules = load_lef_json(args.lef_json)
    else:
        # parse LEF file (slower, but can be used with --tech-lef) #
        if not args.tech_lef_path:
            raise ValueError("--tech-lef is required when using --lef")
        tech_vias, tech_viarules = parse_tech_lef(args.tech_lef_path, args.dbu)
        
        cells = parse_lef(args.lef_path, args.dbu)

    # Parse the DEF file. Initially parse the DEF to extract components, pins, and nets. # 
    # Then compute pin centers and split wires at vias and pins. After having the pin    #
    # points, build a mapping of DEF pin points and add Steiner points to the DEF nets.  #
    components, top_pins, def_nets = parse_def(args.def_path)
    pin_centers = compute_pin_centers(components, cells, top_pins, args.dbu)
    split_wires_at_vias(def_nets, tech_vias)     
    split_wires_at_pins(def_nets, components, cells, tech_vias, top_pins, verbose)
    def_pin_points, def_point_to_pin_name = build_def_pin_points(def_nets, components, cells, tech_vias, top_pins, tolerance=20000, verbose=verbose)
    add_def_steiner_points(def_nets, def_pin_points)
    find_same_layer_via_sandwiches(def_nets, def_pin_points, verbose)
    find_pin_steiner_conflicts(def_nets, def_pin_points)
    
    # Wire graph and edges of every net. A pin on a junction has a virtual twin that takes over the wire connections, #
    # and the pin hangs off the twin. The edges run between pins and Steiner points                                   #
    for net_name, net_info in def_nets.items():
        pin_points_for_net = set(def_pin_points.get(net_name, {}).values())
        all_steiner_keys = set(net_info.get('steiner_points', {}).keys())
        def_graph = build_def_net_graph(net_info)

        colocated_virtuals = sorted(
            (  (pt, data['coords'])
                for pt, data in net_info.get('steiner_points', {}).items()
                if data.get('virtual') and isinstance(pt, tuple) and pt[0] == 'virtual'
            ),
            key=lambda x: (x[1], str(x[0]))  
        )

        for vkey, coords in colocated_virtuals:
            old_neighbors = list(def_graph.get(coords, []))
            def_graph[vkey] = old_neighbors[:]
            def_graph[coords] = [vkey]
            for n in old_neighbors:
                def_graph[n] = [vkey if x == coords else x
                                for x in def_graph.get(n, [])]
            if coords not in def_graph[vkey]:
                def_graph[vkey].append(coords)

        interest_points = pin_points_for_net | all_steiner_keys
        for pt, data in net_info.get('steiner_points', {}).items():
            if data.get('virtual') and isinstance(pt, tuple) and pt[0] == 'virtual':
                phys = data['coords']
                if phys in interest_points:
                    interest_points = (interest_points - {phys}) | {pt}

        net_info['def_edges'] = extract_def_edges_between_interest(
            def_graph, interest_points)

        # Layer of every wire piece, in both directions #
        point_pair_layer = {}
        for seg in net_info['segments']:
            layer = seg['layer']
            pts = seg['points']
            for i in range(len(pts) - 1):
                point_pair_layer[(pts[i], pts[i + 1])] = layer
                point_pair_layer[(pts[i + 1], pts[i])] = layer
        net_info['point_pair_layer'] = point_pair_layer

    # Parse the SPEF file and build a graph representation of the SPEF nets. # 
    # Then, for each net, collapse the SPEF edges into a simplified          #
    # representation. Finally, process each net in parallel to compute       #
    # features and generate CSV rows.                                        #
    spef_mapping, spef_reverse, spef_name_map_lines = parse_spef_name_map(args.spef_path)    
    spef_ports_lines = parse_spef_ports(args.spef_path)
    spef_nets = parse_spef_nets(args.spef_path, spef_mapping, spef_reverse)    
    graph = build_spef_graph(spef_nets, spef_mapping, spef_reverse, verbose)
    
    # Index the SPEF graph by net, for the workers: all nodes, pin nodes, and pin name to node #
    spef_nodes_by_net = defaultdict(dict)
    spef_pins_by_net = defaultdict(set)
    spef_pin_name_to_node_by_net = defaultdict(dict)

    for nid, ndata in graph.items():
        net = ndata.get("net")
        if net is None:
            continue

        spef_nodes_by_net[net][nid] = ndata

        is_pin = (
            ndata.get("coords") is not None
            and ndata.get("direction") is not None
        )

        if is_pin:
            spef_pins_by_net[net].add(nid)

            pin_name = ndata.get("def_name")
            if pin_name:
                spef_pin_name_to_node_by_net[net][pin_name] = nid

    # Branching points and collapsed edges of every SPEF net #
    add_spef_steiner_points(spef_nets, spef_nodes_by_net)
    for net_name, net_info in spef_nets.items():
        net_info['spef_collapsed_edges'] = collapse_spef_net_to_edges(
            spef_nodes_by_net.get(net_name, {}))

    # Lookup of the collapsed SPEF edge by its two end nodes, in both directions #
    spef_edge_dict = {}
    for net_name, net_info in spef_nets.items():
        for e in net_info.get('spef_collapsed_edges', []):
            n1, n2 = e['node1'], e['node2']
            spef_edge_dict[(n1, n2)] = e
            spef_edge_dict[(n2, n1)] = e

    # Counters and result lists #
    net_mappings = {}
    all_csv_rows = []
    all_node_rows = []
    mapped_count = 0
    csv_nets_count = 0

    # Choose the nets to process. A net without SPEF entry or without pin points is dropped #
    net_args = []
    no_spef_count = 0
    no_pins_count = 0
    for net_name, def_net_info in def_nets.items():
        if net_name not in spef_nets:
            no_spef_count += 1
            print(f"WARNING: {net_name}: no SPEF entry, dropped")
            continue
        spef_net_info = spef_nets[net_name]
        def_pin_points_for_net = def_pin_points.get(net_name, {})
        if not def_pin_points_for_net:
            no_pins_count += 1
            print(f"WARNING: {net_name}: no pin points found in the DEF routing, dropped")
            continue
        net_args.append((net_name, def_net_info, spef_net_info, def_pin_points_for_net))

    _n_workers = min(8, cpu_count() or 8)
    
    none_count = 0

    # Use multiprocessing Pool to process nets in parallel, passing necessary data to each worker. #
    # This can improve performance when dealing with a large number of nets.                       #
    with Pool(processes=_n_workers,
          initializer=init_worker,
          initargs=(graph, cells, tech_vias, top_pins, components,
                    args.dbu, args.verbose, spef_edge_dict, def_point_to_pin_name,
                    spef_nodes_by_net, spef_pins_by_net, spef_pin_name_to_node_by_net)) as pool:

        skip_reasons = []
        all_results = []

        for result in pool.imap_unordered(_process_net_wrapper, net_args, chunksize=32):
            if result is None:
                none_count += 1
            else:
                mapped_count += 1
                all_results.append(result)
                net_name = result['net_name']
                csv_rows = result['csv_rows']
                skip_reason = result['skip_reason']
                net_mappings[net_name] = (result['def_to_spef'], result['edge_map'])
                if csv_rows:
                    all_csv_rows.extend(csv_rows)
                    all_node_rows.extend(result.get('node_rows', []))  # ADD
                    csv_nets_count += 1
                else:
                    skip_reasons.append((net_name, skip_reason))

    # Sort the skipped nets by reason #
    r_mismatches = [(n, r) for n, r in skip_reasons if r and 'R mismatch' in r]
    len_mismatches = [(n, r) for n, r in skip_reasons if r and 'length coverage' in r]
    other_skips = [(n, r) for n, r in skip_reasons
                     if r and 'R mismatch' not in r and 'length coverage' not in r]
    
    pass_pct = 100.0 * csv_nets_count / mapped_count if mapped_count else 0.0
    
    print(f"INFO: DEF nets {len(def_nets):,}: no SPEF entry {no_spef_count:,}, no pin points {no_pins_count:,}, sent to workers {len(net_args):,}")
    print(f"INFO: Workers: mapped {mapped_count:,}, unmapped {none_count:,}")
    print(f"INFO: Mapped nets: {csv_nets_count:,} passing ({pass_pct:.1f}%), {len(skip_reasons):,} skipped "
          f"(R mismatch {len(r_mismatches):,}, length mismatch {len(len_mismatches):,}, other {len(other_skips):,})")
    accounted = no_spef_count + no_pins_count + none_count + mapped_count
    print(f"INFO: Accounted for {accounted:,} / {len(def_nets):,} DEF nets")

    if r_mismatches:
        print(f"INFO: R mismatch details ({len(r_mismatches):,} nets)")
        def _extract_diff(reason):
            try:
                return abs(float(reason.split('diff')[1].split(',')[0].strip()))
            except (IndexError, ValueError):
                return 0
        for net_name, reason in sorted(r_mismatches, key=lambda x: _extract_diff(x[1]), reverse=True):
            print(f"  {net_name}: {reason}")

    if len_mismatches:
        print(f"INFO: Length mismatch details ({len(len_mismatches):,} nets)")
        for net_name, reason in len_mismatches:
            print(f"  {net_name}: {reason}")

    if other_skips:
        print(f"INFO: Other skip details ({len(other_skips):,} nets)")
        for net_name, reason in other_skips:
            print(f"  {net_name}: {reason}")

    passing_results = [r for r in all_results if r['csv_rows']]
    if passing_results:
        c_errors = [r['c_err_pct'] for r in passing_results]

        print(f"INFO: C reconstruction error over {len(c_errors):,} passing nets: "
              f"mean {np.mean(c_errors):.6f} %  median {np.median(c_errors):.6f} %  "
              f"p95 {np.percentile(c_errors, 95):.6f} %  max {np.max(c_errors):.6f} %")

    if args.output_csv:
        write_dataset_csv(args.output_csv, all_csv_rows)
        node_csv_path = args.output_csv.replace('.csv', '_nodes.csv')
        write_node_csv(node_csv_path, all_node_rows)
        print(f"INFO: Wrote {len(all_csv_rows):,} edge rows from "
              f"{csv_nets_count:,} / {len(net_args):,} nets to {args.output_csv}")


    if args.output_spef:
        write_pi_spef(
            args.output_spef, spef_nets, graph,
            spef_reverse, spef_name_map_lines, spef_ports_lines,
        )

    print(f"INFO: Total execution time {time.perf_counter() - total_start:.1f}s")

if __name__ == "__main__":
    main()
