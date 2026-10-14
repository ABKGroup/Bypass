import argparse
import pandas as pd
import numpy as np
from collections import defaultdict, deque
from scipy.spatial.distance import cdist

MAX_DIST_DBU = 500

# Parse the *NAME_MAP section of the SPEF #
def parse_spef_name_map(spef_path):
    mapping = {}
    in_name_map = False
    with open(spef_path, 'r') as f:
        for line in f:
            line = line.rstrip()
            if not line or line.startswith('//'):
                continue
            if line.startswith('*NAME_MAP'):
                in_name_map = True
                continue
            if in_name_map:
                if ' ' in line:
                    parts = line.split(maxsplit=1)
                    if len(parts) == 2:
                        mapping[parts[0]] = parts[1]
                else:
                    break
    return mapping

def add_node_id_def(nodes_df, spef_path):
    spef_to_def = parse_spef_name_map(spef_path)
    print(f"INFO: Loaded {len(spef_to_def):,} SPEF name mappings and {len(nodes_df):,} nodes")

    # DEF name of a SPEF node id. "*12:3" becomes "<name of *12>/3" #
    def to_def_name(spef_id):
        if ':' in spef_id:                
            base, suffix = spef_id.split(':', 1)
        else:
            base, suffix = spef_id, None
        if base in spef_to_def:
            base_name = spef_to_def[base]
            return f"{base_name}/{suffix}" if suffix is not None else base_name
        return spef_id

    nodes_df['node_id_def'] = nodes_df['node_id'].apply(to_def_name)
    cols = nodes_df.columns.tolist()   # node_id_def right after node_id
    cols.insert(cols.index('node_id') + 1, cols.pop(cols.index('node_id_def')))
    return nodes_df[cols]

def manhattan_distance(x1, y1, x2, y2):
    return abs(x1 - x2) + abs(y1 - y2)

def normalize_name(name):
    if not isinstance(name, str):
        return name
    return name.replace(r'\[', '[').replace(r'\]', ']')

def is_steiner_endpoint(name):
    if not isinstance(name, str):
        return False
    return name.startswith("Steiner(") or name.startswith("Steiner('")

# Add the topology features of one net. A graph of the nodes is built from the edge table, then a breadth-first search from the       #
# driver gives distance_to_driver_um and the number of sinks behind every node (downstream_sink_count). A search from all sinks gives #
# distance_to_nearest_sink_um. For every edge, sinks_beyond_edge is the number of sinks behind its end that is farther from the       #
# driver. A net without a driver in the graph is returned unchanged. Returns (node table, edge table) of the net.                     #
def process_net(net_name, net_edges, net_nodes):

    # 1. Build lookup structures from node CSV #
    net_nodes = net_nodes.copy().reset_index(drop=True)

    # Name to node_id_def (for pins) #
    pin_rows = net_nodes[
        (net_nodes['is_driver_pin'] == 1) | (net_nodes['is_sink_pin'] == 1)
    ]
    pin_map = {
        normalize_name(row['node_id_def']): row['node_id_def']
        for _, row in pin_rows.iterrows()
    }

    # Coordinate to node_id_def (for all nodes: Steiner + pins) #
    coord_map = {}
    node_coords = []
    node_ids = []
    for _, row in net_nodes.iterrows():
        if pd.notna(row['coord_x']) and pd.notna(row['coord_y']):
            coord = (int(round(row['coord_x'])), int(round(row['coord_y'])))
            coord_map[coord] = row['node_id_def']
            node_coords.append([row['coord_x'], row['coord_y']])
            node_ids.append(row['node_id_def'])

    node_coords_arr = np.array(node_coords, dtype=float) if node_coords else None
    
    # 2. Resolve endpoint string to node_id_def
    # Pins   : matched by name
    # Steiner: matched by coordinate 
    #          A virtual Steiner co-located with a pin resolves to that pin's
    #          node_id_def, so the zero-length edge becomes a self-loop (u==v)
    #          and is skipped when building the graph.
    
    # Node name (node_id_def) of an edge end point. A pin is matched by name. A Steiner end point is matched by coordinates, exact #
    # first and then the nearest node within MAX_DIST_DBU. None if nothing matches.                                                #
    def resolve(endpoint_name, coord_x, coord_y):
        if not is_steiner_endpoint(endpoint_name):
            norm = normalize_name(endpoint_name)
            return pin_map.get(norm, norm)

        if pd.isna(coord_x) or pd.isna(coord_y):
            return None

        coord = (int(round(coord_x)), int(round(coord_y)))
        if coord in coord_map:
            return coord_map[coord]

        if node_coords_arr is not None and len(node_coords_arr) > 0:
            dists = cdist([(coord_x, coord_y)], node_coords_arr).flatten()
            min_dist = dists.min()
            if min_dist <= MAX_DIST_DBU:
                return node_ids[dists.argmin()]

        return None
    
    # 3. Build graph using node_id_def as keys
    adj = defaultdict(list)
    edge_weights = {}

    for _, row in net_edges.iterrows():
        u = resolve(row['endpoint_1'], row['coord_x1'], row['coord_y1'])
        v = resolve(row['endpoint_2'], row['coord_x2'], row['coord_y2'])

        # Skip unresolved or self-loops (zero-length virtual Steiner <-- > pin edges)
        if u is None or v is None or u == v:
            continue

        dist = manhattan_distance(
            row['coord_x1'], row['coord_y1'],
            row['coord_x2'], row['coord_y2']
        )

        if (u, v) not in edge_weights:
            adj[u].append(v)
            adj[v].append(u)
        edge_weights[(u, v)] = dist
        edge_weights[(v, u)] = dist

    
    # 4. Find driver and sinks directly from node CSV
    driver_key = None
    sink_set = set()

    for _, row in net_nodes.iterrows():
        key = row['node_id_def']
        if row['is_driver_pin'] == 1:
            driver_key = key
        if row['is_sink_pin'] == 1:
            sink_set.add(key)

    if not driver_key or driver_key not in adj:
        return net_nodes, net_edges

    
    # 5. BFS from driver — distance to driver
    dist_driver = {driver_key: 0.0}
    parent = {driver_key: None}
    order = []
    queue = deque([driver_key])
    while queue:
        u = queue.popleft()
        order.append(u)
        for v in adj[u]:
            if v not in dist_driver:
                dist_driver[v] = dist_driver[u] + edge_weights[(u, v)]
                parent[v] = u
                queue.append(v)

    
    # 6. Downstream sink count (bottom-up pass)
    downstream = {node: (1 if node in sink_set else 0) for node in adj}
    for u in reversed(order):
        if parent[u] is not None:
            downstream[parent[u]] += downstream[u]

    
    # 7. BFS from all sinks — distance to nearest sink
    dist_sink = {s: 0.0 for s in sink_set if s in adj}
    queue = deque(list(dist_sink.keys()))
    visited = set(dist_sink.keys())
    while queue:
        u = queue.popleft()
        for v in adj[u]:
            if v not in visited:
                visited.add(v)
                dist_sink[v] = dist_sink[u] + edge_weights[(u, v)]
                queue.append(v)

    
    # 8. Write topo features back to node rows — always by node_id_def
    node_rows = []
    for _, row in net_nodes.iterrows():
        new_row = row.to_dict()
        key = row['node_id_def']
        new_row['distance_to_driver_um'] = dist_driver.get(key, np.nan)
        new_row['distance_to_nearest_sink_um'] = dist_sink.get(key, np.nan)
        new_row['downstream_sink_count'] = float(downstream.get(key, 0))
        node_rows.append(new_row)

    
    # 9. sinks_beyond_edge — resolve endpoints then look up downstream child
    edge_rows = []
    for _, row in net_edges.iterrows():
        u = resolve(row['endpoint_1'], row['coord_x1'], row['coord_y1'])
        v = resolve(row['endpoint_2'], row['coord_x2'], row['coord_y2'])
        new_row = row.to_dict()
        if u in dist_driver and v in dist_driver:
            child = v if dist_driver[u] < dist_driver[v] else u
            new_row['sinks_beyond_edge'] = int(downstream.get(child, 0))
        edge_rows.append(new_row)

    return pd.DataFrame(node_rows), pd.DataFrame(edge_rows)


# Read the edge and node CSV, add the topology features net by net and write both tables. Prints how many nodes have no distance #
# or sink count (NaN) and how many edges have no sinks_beyond_edge.                                                              #
def main():
    parser = argparse.ArgumentParser(
        description='Add topological features to edge and node CSVs. With --spef the node_id_def column '
                    '(DEF name of each node) is added first, from the SPEF name map.'
    )
    parser.add_argument('--edge_csv',    required=True, help='Input edge CSV')
    parser.add_argument('--node_csv',    required=True, help='Input node CSV (must have node_id_def unless --spef is given)')
    parser.add_argument('--spef',        default=None, help='Golden SPEF; adds node_id_def to the node CSV')
    parser.add_argument('--output_edge', required=True, help='Output edge CSV with topo features')
    parser.add_argument('--output_node', required=True, help='Output node CSV with topo features')
    args = parser.parse_args()

    edges_df = pd.read_csv(args.edge_csv)
    nodes_df = pd.read_csv(args.node_csv)
    if args.spef:
        nodes_df = add_node_id_def(nodes_df, args.spef)

    # Check that the required columns exist #
    required_edge_cols = [
        'net_name', 'endpoint_1', 'endpoint_2',
        'coord_x1', 'coord_y1', 'coord_x2', 'coord_y2'
    ]
    required_node_cols = [
        'net_name', 'node_id_def', 'is_driver_pin', 'is_sink_pin'
    ]
    for col in required_edge_cols:
        if col not in edges_df.columns:
            raise ValueError(f"Edge CSV missing required column: {col}")
    for col in required_node_cols:
        if col not in nodes_df.columns:
            raise ValueError(f"Node CSV missing required column: {col}")

    # Process every net #
    all_node_dfs = []
    all_edge_dfs = []
    skipped_nets = []

    net_names = edges_df['net_name'].unique()
    for net in net_names:
        net_edges = edges_df[edges_df['net_name'] == net]
        net_nodes = nodes_df[nodes_df['net_name'] == net]

        if net_edges.empty or net_nodes.empty:
            skipped_nets.append((net, 'no edges or nodes'))
            continue

        new_nodes, new_edges = process_net(net, net_edges, net_nodes)
        all_node_dfs.append(new_nodes)
        all_edge_dfs.append(new_edges)

    # Merge the nets and report how many values are missing #
    final_nodes = pd.concat(all_node_dfs, ignore_index=True)
    final_edges = pd.concat(all_edge_dfs, ignore_index=True)

    nan_topo = final_nodes[
        final_nodes[['distance_to_driver_um',
                      'distance_to_nearest_sink_um',
                      'downstream_sink_count']].isna().any(axis=1)
    ]
    print(f"INFO: {len(final_nodes):,} nodes, {len(nan_topo):,} without topology features "
          f"({100 * len(nan_topo) / len(final_nodes):.2f}%)")
    if len(nan_topo) > 0:
        print("WARNING: sample of nodes without topology features:")
        print(nan_topo[['net_name', 'node_id_def', 'coord_x', 'coord_y',
                         'is_driver_pin', 'is_sink_pin',
                         'distance_to_driver_um']].head(10).to_string(index=False))

    missing_sinks_beyond = final_edges['sinks_beyond_edge'].isna().sum() \
        if 'sinks_beyond_edge' in final_edges.columns else len(final_edges)
    print(f"INFO: {len(final_edges):,} edges, {missing_sinks_beyond:,} without sinks_beyond_edge "
          f"({100 * missing_sinks_beyond / len(final_edges):.2f}%)")

    if skipped_nets:
        print(f"WARNING: skipped {len(skipped_nets):,} nets, the first {min(10, len(skipped_nets))}:")
        for net, reason in skipped_nets[:10]:
            print(f"  {net}: {reason}")

    # Write the outputs #
    final_nodes.to_csv(args.output_node, index=False)
    final_edges.to_csv(args.output_edge, index=False)
    print(f"INFO: Wrote {args.output_node} and {args.output_edge}")


if __name__ == '__main__':
    main()