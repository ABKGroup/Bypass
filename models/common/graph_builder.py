import json
import os
import re
import resource
from collections import defaultdict, deque
from multiprocessing import Pool, cpu_count
import numpy as np
import pandas as pd
import torch
from torch.utils.data import Dataset

torch.multiprocessing.set_sharing_strategy('file_system')

soft, hard = resource.getrlimit(resource.RLIMIT_NOFILE)
resource.setrlimit(resource.RLIMIT_NOFILE, (min(65536, hard), hard))

BINARY_EDGE = {"is_steiner", "is_via_dominated", "via_dom_metal2", "via_dom_metal3plus", "is_virtual_steiner"}
NOLOG_EDGE = {"dens_same", "dens_above", "dens_below", "dens_total"}  
BINARY_NODE = {"is_pin", "is_driver_pin", "is_sink_pin"}
INTERNAL_TOKEN = "INTERNAL"
UNK_TOKEN = "<UNK>"

# Library pin capacitances (data/configs/ng45_pin_capacitance.json. Override with LIBERTY_CAPS_JSON). #
_LIBERTY_CAPS_PATH = os.environ.get("LIBERTY_CAPS_JSON") or os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "configs", "ng45_pin_capacitance.json")
try:
    with open(_LIBERTY_CAPS_PATH) as _f:
        LIBERTY_CAPS = json.load(_f)
    print(f"  Loaded liberty pin caps: {len(LIBERTY_CAPS)} cell types")
except FileNotFoundError:
    LIBERTY_CAPS = {}
    print(f"  WARNING: liberty pin capacitance file not found: {_LIBERTY_CAPS_PATH} (set LIBERTY_CAPS_JSON); "
          f"pin capacitances will be 0")

# Parse a DEF file to extract port information. Returns a dictionary mapping port #
# names to their direction and coordinates in microns. The DEF file is expected   #
# to contain a PINS section with placement information. The units for distance    #
# are extracted from the DEF file, defaulting to 1000 microns if not specified.   #
def parse_def_ports(def_path: str, design_name: str = None):
    ports = {}
    units = 1000
    current_pin = None
    current_dir = None

    with open(def_path) as f:
        in_pins = False
        for line in f:
            line = line.strip()
            if line.startswith('UNITS DISTANCE MICRONS'):
                try:
                    units = int(line.split()[-2])
                except (ValueError, IndexError):
                    pass
            if line.startswith('PINS '):
                in_pins = True
                continue
            if line.startswith('END PINS'):
                break
            if not in_pins:
                continue

            if line.startswith('- '):
                parts = line.split()
                current_pin = parts[1]
                current_dir = None

            if current_pin and '+ DIRECTION' in line:
                current_dir = 'I' if 'INPUT' in line else 'O'

            if current_pin and current_dir and ('+ PLACED' in line or '+ FIXED' in line):
                parts = line.split()
                try:
                    idx = parts.index('(')
                    x = round(int(parts[idx + 1]) / units, 6)
                    y = round(int(parts[idx + 2]) / units, 6)
                    ports[current_pin] = {'direction': current_dir, 'x_um': x, 'y_um': y}
                except (ValueError, IndexError):
                    pass

    return ports


def get_liberty_pin_cap(cell_type: str, pin: str):
    return LIBERTY_CAPS.get(cell_type, {}).get(pin, None)

# Cell type string '<base>_X<strength>'. The base is returned unchanged for internal and unknown types or an #
# invalid strength.                                                                                          #
def _build_cell_type(base: str, strength) -> str:
    if base in (INTERNAL_TOKEN, 'UNKNOWN', '0', ''):
        return base
    try:
        s = int(float(strength))
    except (ValueError, TypeError):
        return base
    return f'{base}_X{s}' if s > 0 else base

# Design name of a case name <design>_<tcp>_<util>_<ar>[-blockages]. It names the predicted SPEF. #
def _design_base(case_dir: str) -> str:
    m = re.match(r'^(.+)_[0-9.]+_[0-9.]+_[0-9.]+(-blockages)?$', case_dir)
    return m.group(1) if m else case_dir

def log_transform(arr, binary_cols, all_cols):
    arr = arr.copy().astype(np.float32)
    for i, col in enumerate(all_cols):
        if col not in binary_cols:
            arr[:, i] = np.log1p(np.clip(arr[:, i], 0, None))
    return np.nan_to_num(arr, nan=0.0, posinf=0.0, neginf=0.0)

# Processes a single net's segments and nodes to construct a graph representation.  #
# It maps node names to positions, resolves unmatched endpoints, computes node and  #
# edge features, and returns a dictionary containing the graph's data. If any       #
# issues arise (e.g., missing nodes or invalid values), it returns None.            #
def process_net(args):
    net_key, net_segs, net_nodes, edge_feat_cols, node_feat_cols, \
    metal_cols, via_cols, cell_vocab, has_liberty, unk_idx = args

    if net_nodes is None or net_nodes.empty or net_segs.empty:
        return None

    name_to_pos = {name: pos for pos, name in enumerate(net_nodes['node_id_def'].values)}
    ep1 = net_segs['endpoint_1'].values
    ep2 = net_segs['endpoint_2'].values
    local_src = np.fromiter((name_to_pos.get(n, -1) for n in ep1), dtype=np.int64, count=len(ep1))
    local_dst = np.fromiter((name_to_pos.get(n, -1) for n in ep2), dtype=np.int64, count=len(ep2))

    # Steiner(x,y) / Steiner('split',...) endpoints do not match node_id_def by
    # name. Resolve them by integer DBU coordinate so they carry real features.
    if (local_src == -1).any() or (local_dst == -1).any():
        _cre = re.compile(r"\((\d+)\s*,\s*(\d+)\)")

        def _ck(x, y):
            try:
                if x is None or y is None or x != x or y != y:
                    return None
                return (int(round(float(x))), int(round(float(y))))
            except (TypeError, ValueError):
                return None

        def _lk(s):
            m = _cre.search(s if isinstance(s, str) else str(s))
            return (int(m.group(1)), int(m.group(2))) if m else None

        if 'coord_x' in net_nodes.columns and 'coord_y' in net_nodes.columns:
            ncx = pd.to_numeric(net_nodes['coord_x'], errors='coerce').values
            ncy = pd.to_numeric(net_nodes['coord_y'], errors='coerce').values
            c2p = {}
            for pos in range(len(ncx)):
                k = _ck(ncx[pos], ncy[pos])
                if k is not None:
                    c2p.setdefault(k, pos)
            sx1 = pd.to_numeric(net_segs['coord_x1'], errors='coerce').values if 'coord_x1' in net_segs.columns else None
            sy1 = pd.to_numeric(net_segs['coord_y1'], errors='coerce').values if 'coord_y1' in net_segs.columns else None
            sx2 = pd.to_numeric(net_segs['coord_x2'], errors='coerce').values if 'coord_x2' in net_segs.columns else None
            sy2 = pd.to_numeric(net_segs['coord_y2'], errors='coerce').values if 'coord_y2' in net_segs.columns else None
            for i in np.where(local_src == -1)[0]:
                k = _ck(sx1[i], sy1[i]) if sx1 is not None else None
                if k is None:
                    k = _lk(ep1[i])
                p = c2p.get(k)
                if p is not None:
                    local_src[i] = p
            for i in np.where(local_dst == -1)[0]:
                k = _ck(sx2[i], sy2[i]) if sx2 is not None else None
                if k is None:
                    k = _lk(ep2[i])
                p = c2p.get(k)
                if p is not None:
                    local_dst[i] = p

    if (local_src == -1).any() or (local_dst == -1).any():
        known_nodes = list(net_nodes['node_id_def'].values)
        n_known = len(known_nodes)
        unresolved = sorted(
            {ep1[i] for i in np.where(local_src == -1)[0]}
            | {ep2[i] for i in np.where(local_dst == -1)[0]}
        )
        extra_pos = {ep: n_known + j for j, ep in enumerate(unresolved)}
        n_extra = len(unresolved)
        for i in np.where(local_src == -1)[0]:
            local_src[i] = extra_pos[ep1[i]]
        for i in np.where(local_dst == -1)[0]:
            local_dst[i] = extra_pos[ep2[i]]
        if (local_src == -1).any() or (local_dst == -1).any():
            return None

        known_arr = log_transform(net_nodes[node_feat_cols].values, BINARY_NODE, node_feat_cols)
        node_arr = np.vstack([known_arr,
                               np.zeros((n_extra, len(node_feat_cols)), dtype=np.float32)])
        C_node_gt = np.concatenate([net_nodes['C_node_pf'].values.astype(np.float32),
                                        np.zeros(n_extra, dtype=np.float32)])
        pt_delay_gt = np.concatenate([net_nodes['elmore_gt_ps'].values.astype(np.float32),
                                        np.full(n_extra, -1.0, dtype=np.float32)])
        timing_mask = np.concatenate([net_nodes['has_elmore'].values.astype(bool),
                                        np.zeros(n_extra, dtype=bool)])
        lib_known = net_nodes['C_pin_liberty_pf'].values.astype(np.float32) \
            if has_liberty else np.zeros(n_known, dtype=np.float32)
        lib_known[net_nodes['is_driver_pin'].values.astype(bool)] = 0.0  # driver output cap is not a load
        C_pin_liberty = np.concatenate([lib_known, np.zeros(n_extra, dtype=np.float32)])
        cell_types = np.concatenate([net_nodes['cell_base_type'].values.astype(str),
                                        np.array([INTERNAL_TOKEN] * n_extra)])
        node_ids_out = known_nodes + unresolved
    else:
        node_arr = log_transform(net_nodes[node_feat_cols].values, BINARY_NODE, node_feat_cols)
        C_node_gt = net_nodes['C_node_pf'].values.astype(np.float32)
        pt_delay_gt = net_nodes['elmore_gt_ps'].values.astype(np.float32)
        timing_mask = net_nodes['has_elmore'].values.astype(bool)
        lib_vals = net_nodes['C_pin_liberty_pf'].values.astype(np.float32) \
           if has_liberty else np.zeros(len(net_nodes), dtype=np.float32)
        lib_vals[net_nodes['is_driver_pin'].values.astype(bool)] = 0.0  # driver output cap is not a load
        C_pin_liberty = lib_vals
        cell_types = net_nodes['cell_base_type'].values.astype(str)
        node_ids_out = list(net_nodes['node_id_def'].values)

    edge_arr = log_transform(net_segs[edge_feat_cols].values, BINARY_EDGE | NOLOG_EDGE, edge_feat_cols)
    metal_lens = net_segs[metal_cols].values.astype(np.float32)
    via_counts = net_segs[via_cols].values.astype(np.float32)
    seg_lens = net_segs['total_len_um'].values.astype(np.float32)
    R_gt = net_segs['R_ohms'].values.astype(np.float32)
    C_edge_gt = net_segs['C_edge_pf'].values.astype(np.float32)

    if (R_gt <= 0).any() or (C_node_gt < 0).any():
        return None
    if np.isnan(metal_lens).any() or np.isnan(via_counts).any():
        return None

    n_edges = len(local_src)
    edge_index = np.empty((n_edges, 2), dtype=np.int64)
    edge_index[:, 0] = local_src
    edge_index[:, 1] = local_dst

    cell_type_idx = np.array([cell_vocab.get(t, unk_idx) for t in cell_types], dtype=np.int64)

    return {
        'net_name'      : net_key,
        'node_ids'      : node_ids_out,
        'endpoint_1'    : list(ep1),
        'endpoint_2'    : list(ep2),
        'node_feats'    : node_arr,
        'edge_feats'    : edge_arr,
        'edge_index'    : edge_index.T,
        'metal_lens'    : metal_lens,
        'via_counts'    : via_counts,
        'seg_lens'      : seg_lens,
        'C_node_gt'     : C_node_gt,
        'R_gt'          : R_gt,
        'C_edge_gt'     : C_edge_gt,
        'pt_delay_gt'   : pt_delay_gt,
        'timing_mask'   : timing_mask,
        'C_pin_liberty' : C_pin_liberty,
        'cell_type_idx' : cell_type_idx,
    }

# Build the graph of every net in parallel (one worker per net) and return the list of graph dicts. #
def build_graph_list_parallel(seg_df, node_df, edge_feat_cols, node_feat_cols, metal_cols, via_cols, cell_vocab, has_liberty, n_workers=None):
    if n_workers is None:
        n_workers = min(16, cpu_count())

    unk_idx = cell_vocab[UNK_TOKEN]
    node_groups = {k: g.reset_index(drop=True) for k, g in node_df.groupby('net_key')}

    args_list = [
        (net_key, net_segs.reset_index(drop=True), node_groups.get(net_key),
         edge_feat_cols, node_feat_cols, metal_cols, via_cols,
         cell_vocab, has_liberty, unk_idx)
        for net_key, net_segs in seg_df.groupby('net_key')
    ]

    with Pool(n_workers) as pool:
        results = pool.map(process_net, args_list)

    NUMPY_KEYS = {'node_feats', 'edge_feats', 'metal_lens', 'via_counts', 'seg_lens',
                  'C_node_gt', 'R_gt', 'C_edge_gt', 'pt_delay_gt', 'C_pin_liberty',
                  'edge_index', 'cell_type_idx', 'timing_mask'}
    META_KEYS = {'net_name', 'node_ids', 'endpoint_1', 'endpoint_2'}

    graphs = []
    skipped = 0
    for r in results:
        if r is None:
            skipped += 1
            continue
        g = {k: r[k] for k in META_KEYS | NUMPY_KEYS}
        graphs.append(g)

    n_unk = sum(int((g['cell_type_idx'] == 0).sum()) for g in graphs)
    if n_unk > 0:
        print(f"  [WARN] {n_unk:,} nodes mapped to <UNK> cell type (unseen during training)")

    print(f"  Built {len(graphs):,} graphs  (skipped {skipped:,})")
    return graphs


# BFS from the first driver node of a graph. Returns the parent indices, edge indices and levels, or an empty #
# structure if there is no driver.                                                                            #
def _bfs_worker(args):
    g_idx, ei_list, nf_list, n_nodes, n_edges, drv_idx = args
    empty = {'valid': False}
    if n_nodes == 0 or n_edges == 0: return g_idx, empty
    drivers = [i for i in range(n_nodes) if nf_list[i][drv_idx] > 0.3]
    if not drivers: return g_idx, empty
    adj = defaultdict(list)
    for ei, (u, v) in enumerate(ei_list):
        adj[u].append((v, ei)); adj[v].append((u, ei))
    for node in adj:
        adj[node].sort()
    parent = [-1]*n_nodes; parent_ei = [-1]*n_nodes
    levels = []; visited = [False]*n_nodes
    queue = deque([drivers[0]]); visited[drivers[0]] = True
    depth = [-1]*n_nodes; depth[drivers[0]] = 0
    while queue:
        nd = queue.popleft(); d = depth[nd]
        if d >= len(levels): levels.append([])
        levels[d].append(nd)
        for nbr, ei in adj[nd]:
            if not visited[nbr]:
                visited[nbr] = True; parent[nbr] = nd
                parent_ei[nbr] = ei; depth[nbr] = d+1; queue.append(nbr)
    return g_idx, {
        'valid'           : True,
        'parent_loc_np'   : np.array(parent,    dtype=np.int64),
        'parent_ei_loc_np': np.array(parent_ei, dtype=np.int64),
        'levels_np'       : [np.array(lv, dtype=np.int64) for lv in levels],
        'n_nodes'         : n_nodes,
        'n_edges'         : n_edges,
    }

# Precompute Elmore BFS structures for a list of graphs in parallel using multiprocessing. #
# Returns a list of structures, each containing parent indices, edge indices, and levels   #
# for the BFS traversal.                                                                   #
def precompute_elmore_structures(graphs, driver_feat_idx, n_workers=None):
    if n_workers is None:
        n_workers = min(16, cpu_count())
    args_list = []
    for g_idx, g in enumerate(graphs):
        ei = g['edge_index']
        nf = g['node_feats']
        args_list.append((g_idx,
                          list(zip(ei[0].tolist(), ei[1].tolist())),
                          nf.tolist(), nf.shape[0], ei.shape[1], driver_feat_idx))
    with Pool(n_workers) as pool:
        results = pool.map(_bfs_worker, args_list)
    results.sort(key=lambda x: x[0])
    structs = [r[1] for r in results]
    n_valid = sum(s['valid'] for s in structs)
    print(f"  {n_valid}/{len(graphs)} graphs have valid Elmore BFS structure")
    return structs

# Computes the Elmore delay for each node in a graph given the effective  # 
# resistances and capacitances. Returns a tensor of delays for each node. #
def compute_elmore(R_eff, C_node_eff, C_edge_eff, edge_index, batch, device):
    n_nodes = C_node_eff.shape[0]
    src, dst = edge_index[0], edge_index[1]
    C_half = torch.zeros(n_nodes, device=device, dtype=R_eff.dtype)
    C_half.scatter_add_(0, src, C_edge_eff * 0.5)
    C_half.scatter_add_(0, dst, C_edge_eff * 0.5)
    C_total = C_node_eff + C_half
    parent_glob = batch['parent_glob'].to(device)
    parent_ei_glob = batch['parent_ei_glob'].to(device)
    levels_cat = {d: t.to(device) for d, t in batch['levels_cat'].items()}
    max_depth = max(levels_cat.keys()) + 1 if levels_cat else 0
    sc = C_total.clone()
    for d in range(max_depth - 1, 0, -1):
        if d not in levels_cat: continue
        ch = levels_cat[d]; sc.scatter_add_(0, parent_glob[ch], sc[ch])
    dl = torch.zeros(n_nodes, device=device, dtype=R_eff.dtype)
    for d in range(1, max_depth):
        if d not in levels_cat: continue
        ch = levels_cat[d]
        dl[ch] = dl[parent_glob[ch]] + R_eff[parent_ei_glob[ch]] * sc[ch]
    return dl


# Returns a single batch dict with all graphs concatenated, and graph_ids for nodes and edges.   #
# Iterates over the batch and offsets node/edge indices to create a single graph representation. #
def collate_graphs(batch):
    node_offset = 0
    all_node_feats, all_edge_feats, all_edge_index = [], [], []
    all_metal_lens, all_via_counts, all_seg_lens = [], [], []
    all_R_gt, all_C_node_gt, all_C_edge_gt = [], [], []
    all_pt_delay_gt, all_timing_mask = [], []
    all_C_pin_liberty, all_cell_type_idx = [], []
    all_net_names = []
    node_counts, edge_counts = [], []

    for g in batch:
        n_nodes = g['node_feats'].shape[0]
        n_edges = g['edge_feats'].shape[0]
        all_node_feats.append(torch.from_numpy(g['node_feats']))
        all_edge_feats.append(torch.from_numpy(g['edge_feats']))
        all_edge_index.append(torch.from_numpy(g['edge_index']) + node_offset)
        all_metal_lens.append(torch.from_numpy(g['metal_lens']))
        all_via_counts.append(torch.from_numpy(g['via_counts']))
        all_seg_lens.append(torch.from_numpy(g['seg_lens']))
        all_R_gt.append(torch.from_numpy(g['R_gt']))
        all_C_node_gt.append(torch.from_numpy(g['C_node_gt']))
        all_C_edge_gt.append(torch.from_numpy(g['C_edge_gt']))
        all_pt_delay_gt.append(torch.from_numpy(g['pt_delay_gt']))
        all_timing_mask.append(torch.from_numpy(g['timing_mask']))
        all_C_pin_liberty.append(torch.from_numpy(g['C_pin_liberty']))
        all_cell_type_idx.append(torch.from_numpy(g['cell_type_idx']))
        all_net_names.append(g['net_name'])
        node_counts.append(n_nodes)
        edge_counts.append(n_edges)
        node_offset += n_nodes

    node_counts_t = torch.tensor(node_counts, dtype=torch.long)
    edge_counts_t = torch.tensor(edge_counts, dtype=torch.long)
    node_offsets = torch.zeros(len(batch), dtype=torch.long)
    edge_offsets = torch.zeros(len(batch), dtype=torch.long)
    node_offsets[1:] = node_counts_t[:-1].cumsum(0)
    edge_offsets[1:] = edge_counts_t[:-1].cumsum(0)

    n_total_nodes = int(node_counts_t.sum().item())
    parent_glob_cpu = torch.full((n_total_nodes,), -1, dtype=torch.long)
    parent_ei_glob_cpu = torch.full((n_total_nodes,), -1, dtype=torch.long)
    levels_by_depth = defaultdict(list)

    ns_arr = node_offsets.numpy()
    es_arr = edge_offsets.numpy()
    nc_arr = node_counts_t.numpy()
    ec_arr = edge_counts_t.numpy()

    for i, g in enumerate(batch):
        s = g.get('elmore_struct', {'valid': False})
        if not s['valid']: continue
        ns = int(ns_arr[i]); nc = int(nc_arr[i])
        es = int(es_arr[i]); ec = int(ec_arr[i])
        if nc == 0 or ec == 0: continue
        parent_loc = torch.from_numpy(s['parent_loc_np'])
        parent_ei_loc = torch.from_numpy(s['parent_ei_loc_np'])
        valid_mask = parent_loc >= 0
        local_idx = torch.where(valid_mask)[0]
        global_idx = local_idx + ns
        parent_glob_cpu[global_idx] = parent_loc[local_idx] + ns
        parent_ei_glob_cpu[global_idx] = parent_ei_loc[local_idx] + es
        for d, lv_np in enumerate(s['levels_np']):
            levels_by_depth[d].append(torch.from_numpy(lv_np) + ns)

    return {
        'node_feats'    : torch.cat(all_node_feats,    dim=0).float(),
        'edge_feats'    : torch.cat(all_edge_feats,    dim=0).float(),
        'edge_index'    : torch.cat(all_edge_index,    dim=1).long(),
        'metal_lens'    : torch.cat(all_metal_lens,    dim=0).float(),
        'via_counts'    : torch.cat(all_via_counts,    dim=0).float(),
        'seg_lens'      : torch.cat(all_seg_lens,      dim=0).float(),
        'R_gt'          : torch.cat(all_R_gt,          dim=0).float(),
        'C_node_gt'     : torch.cat(all_C_node_gt,     dim=0).float(),
        'C_edge_gt'     : torch.cat(all_C_edge_gt,     dim=0).float(),
        'pt_delay_gt'   : torch.cat(all_pt_delay_gt,   dim=0).float(),
        'timing_mask'   : torch.cat(all_timing_mask,   dim=0).bool(),
        'C_pin_liberty' : torch.cat(all_C_pin_liberty, dim=0).float(),
        'cell_type_idx' : torch.cat(all_cell_type_idx, dim=0).long(),
        'net_names'     : all_net_names,
        'graph_ids_node': torch.repeat_interleave(
                              torch.arange(len(batch), dtype=torch.long), node_counts_t),
        'graph_ids_edge': torch.repeat_interleave(
                              torch.arange(len(batch), dtype=torch.long), edge_counts_t),
        'parent_glob'   : parent_glob_cpu,
        'parent_ei_glob': parent_ei_glob_cpu,
        'levels_cat'    : {d: torch.cat(ts) for d, ts in levels_by_depth.items()},
    }

# InferDataset holds the graphs and their corresponding Elmore structures for inference. #
# It provides methods to get the length of the dataset and to retrieve individual items  #
# (graphs and their Elmore structures) by index.                                         #
class InferDataset(Dataset):
    def __init__(self, graphs, elmore_structs):
        self.graphs = graphs
        self.structs = elmore_structs

    def __len__(self): return len(self.graphs)

    def __getitem__(self, i):
        item = dict(self.graphs[i])
        item['elmore_struct'] = self.structs[i]
        return item
