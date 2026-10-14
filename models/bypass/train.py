import json
import multiprocessing as _mp
import os
import sys
import time
from collections import defaultdict, deque
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import DataLoader, Dataset
import re as _re
_COORD_RE = _re.compile(r"\((\d+)\s*,\s*(\d+)\)")
_RESOLVE_STATS = {"by_coord": 0, "extra": 0, "nets_with_extra": 0}

torch.multiprocessing.set_sharing_strategy("file_system")

# hyperparameters #
EMBED_DIM = 256
CELL_EMBED_DIM = 32
MP_ROUNDS = 3
HUBER_DELTA = 0.5
EPOCHS = 300
LR_PHYSICS = 1e-4
LR_MLP = 1e-3
R_L_FLOOR = 1e-2
WEIGHT_DECAY = 1e-4
PATIENCE = 60
BATCH_SIZE = 256
GRAD_ACCUM_STEPS = 2
LAMBDA_R = 1.0
LAMBDA_C_EDGE = 1.0
C_EDGE_BIAS = -9.0
LAMBDA_TIMING = 0.15
LAMBDA_RHO = 0.01
LAMBDA_RHO_VAR = 0.05
RHO_TARGET_STD = 0.1
MOE_NUM_EXPERTS = 3
LAMBDA_C_TOTAL = 0.5

_BUILD_STATE = {}
_ELMORE_STATE = {}

# Optionally parallel per net graph construction.  The CSV -> graph + Elmore-BFS # 
# build is a one-time cost, so this can be parallelized                          #
_WORKER_CAP = 48
GRAPH_BUILD_WORKERS = min(_WORKER_CAP, int(os.environ.get(
    "GRAPH_BUILD_WORKERS", min(32, os.cpu_count() or 1))))

# paths #
# TRAINING_WORK is the --work folder of scripts/data_processing/build_training_dataset/build_training_dataset.sh
# (default: ./training_work in the repository root). SEG_CSV, NODE_CSV and OUTPUT_DIR can be overridden directly.
REPO = Path(__file__).resolve().parents[2]
TRAINING_WORK = Path(os.environ.get("TRAINING_WORK", REPO / "training_work"))
SEG_CSV = Path(os.environ.get("SEG_CSV",  TRAINING_WORK / "collapsed" / "collapsed_segments.csv"))
NODE_CSV = Path(os.environ.get("NODE_CSV", TRAINING_WORK / "collapsed" / "collapsed_nodes.csv"))
OUTPUT_DIR = Path(os.environ.get("OUTPUT_DIR", REPO / "results" / "model"))
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

R_L_CSV = TRAINING_WORK / "processed" / "r_L_warmstart.csv"
R_VIA_CSV = TRAINING_WORK / "processed" / "r_via_warmstart.csv"

# Validation runs, named <design>_<tcp>_<util>_<ar> as written by scripts/invs_scripts/run_sweep.sh. #
VAL_RUNS = {
    "aes_cipher_top_10_0.7_1.2", "ibex_core_10_0.7_1.2", "jpeg_encoder_10_0.7_1.2",
    "aes_cipher_top_0.65_0.6_1.0", "ibex_core_1.0_0.6_1.0", "jpeg_encoder_0.65_0.6_1.0",
}

SPLIT_SEED = 42

# feature-column vocabulary #
BINARY_EDGE = {"is_steiner", "is_via_dominated", "via_dom_metal2", "via_dom_metal3plus", "is_virtual_steiner"}
BINARY_NODE = {"is_pin", "is_driver_pin", "is_sink_pin"}
INTERNAL_TOKEN = "INTERNAL"
UNK_TOKEN = "<UNK>"

def normalize_escaping(s):
    return s.replace("\\\\", "\\") if isinstance(s, str) else s

# Returns a tuple of integers (x, y) from the given coordinates, rounding to the nearest integer. #
def _ckey(x, y):
    try:
        if x is None or y is None or x != x or y != y:      # None / NaN
            return None
        return (int(round(float(x))), int(round(float(y))))
    except (TypeError, ValueError):
        return None

def _label_ckey(s):
    m = _COORD_RE.search(s if isinstance(s, str) else str(s))
    return (int(m.group(1)), int(m.group(2))) if m else None

# log(1 + x) of the non-binary columns, with NaN and infinite values set to 0. #
def log_transform(arr, binary_cols, all_cols):
    arr = arr.copy().astype(np.float32)
    for i, col in enumerate(all_cols):
        if col not in binary_cols:
            arr[:, i] = np.log1p(np.clip(arr[:, i], 0, None))
    return np.nan_to_num(arr, nan=0.0, posinf=0.0, neginf=0.0)

def _stack_cols(arr_dict, cols):
    return np.stack([arr_dict[c] for c in cols], axis=1)

# Map every cell type to an integer index, from 2 on. The indices 0 and 1 are the unknown and internal tokens. #
def build_cell_vocab(node_df):
    uniq = sorted(str(t) for t in node_df["cell_base_type"].dropna().unique()
                  if str(t) not in (INTERNAL_TOKEN, UNK_TOKEN))
    vocab = {UNK_TOKEN: 0, INTERNAL_TOKEN: 1}
    for i, t in enumerate(uniq, start=2):
        vocab[t] = i
    return vocab

# Processes the segment and node data for a single net, returning a dictionary of graph features and labels. #      
# This function handles the resolution of endpoints to node indices, feature extraction, and log             #
# transformation of features. It also manages cases where endpoints do not match known nodes by using        #
# coordinates or creating extra nodes as needed.                                                             #
def process_net_core(net_key, net_segs, net_nodes, ctx, net_edge_arr=None, net_node_arr=None):

    edge_feat_cols = ctx["edge_feat_cols"]
    node_feat_cols = ctx["node_feat_cols"]
    metal_cols = ctx["metal_cols"]
    via_cols = ctx["via_cols"]
    cell_vocab = ctx["cell_vocab"]
    has_liberty = ctx["has_liberty"]
    unk_idx = ctx["unk_idx"]

    if net_nodes is None or len(net_nodes["node_id_def"]) == 0 or len(net_segs["endpoint_1"]) == 0:
        return None

    name_to_pos = {name: pos for pos, name in enumerate(net_nodes["node_id_def"])}
    ep1 = net_segs["endpoint_1"]
    ep2 = net_segs["endpoint_2"]
    local_src = np.fromiter((name_to_pos.get(n, -1) for n in ep1), dtype=np.int64, count=len(ep1))
    local_dst = np.fromiter((name_to_pos.get(n, -1) for n in ep2), dtype=np.int64, count=len(ep2))

    if (local_src == -1).any() or (local_dst == -1).any():
        ncx, ncy = net_nodes.get("coord_x"), net_nodes.get("coord_y")
        if ncx is not None and ncy is not None:
            coord_to_pos = {}
            for pos in range(len(ncx)):
                k = _ckey(ncx[pos], ncy[pos])
                if k is not None:
                    coord_to_pos.setdefault(k, pos)     
            sx1, sy1 = net_segs.get("coord_x1"), net_segs.get("coord_y1")
            sx2, sy2 = net_segs.get("coord_x2"), net_segs.get("coord_y2")
            for i in np.where(local_src == -1)[0]:
                k = _ckey(sx1[i], sy1[i]) if sx1 is not None else None
                if k is None:
                    k = _label_ckey(ep1[i])
                p = coord_to_pos.get(k)
                if p is not None:
                    local_src[i] = p
                    _RESOLVE_STATS["by_coord"] += 1
            for i in np.where(local_dst == -1)[0]:
                k = _ckey(sx2[i], sy2[i]) if sx2 is not None else None
                if k is None:
                    k = _label_ckey(ep2[i])
                p = coord_to_pos.get(k)
                if p is not None:
                    local_dst[i] = p
                    _RESOLVE_STATS["by_coord"] += 1

    if (local_src == -1).any() or (local_dst == -1).any():
        n_known = len(net_nodes["node_id_def"])
        unresolved = sorted(
            {ep1[i] for i in np.where(local_src == -1)[0]}
            | {ep2[i] for i in np.where(local_dst == -1)[0]}
        )
        extra_pos = {ep: n_known + j for j, ep in enumerate(unresolved)}
        n_extra = len(unresolved)
        _RESOLVE_STATS["extra"] += n_extra
        _RESOLVE_STATS["nets_with_extra"] += 1
        for i in np.where(local_src == -1)[0]:
            local_src[i] = extra_pos[ep1[i]]
        for i in np.where(local_dst == -1)[0]:
            local_dst[i] = extra_pos[ep2[i]]
        if (local_src == -1).any() or (local_dst == -1).any():
            return None

        known_arr = (net_node_arr if net_node_arr is not None
                     else log_transform(_stack_cols(net_nodes, node_feat_cols),
                                        BINARY_NODE, node_feat_cols))
        node_arr = np.vstack([known_arr, np.zeros((n_extra, len(node_feat_cols)), dtype=np.float32)])

        pt_delay_gt = np.concatenate([net_nodes["elmore_gt_ps"].astype(np.float32),
                                      np.full(n_extra, -1.0, dtype=np.float32)])
        timing_mask = np.concatenate([net_nodes["has_elmore"].astype(bool),
                                      np.zeros(n_extra, dtype=bool)])
        lib_known = (net_nodes["C_pin_liberty_pf"].astype(np.float32)
                     if has_liberty else np.zeros(n_known, dtype=np.float32))
        C_pin_liberty = np.concatenate([lib_known, np.zeros(n_extra, dtype=np.float32)])
        cell_types = np.concatenate([net_nodes["cell_base_type"].astype(str),
                                     np.array(["INTERNAL"] * n_extra, dtype=str)])
    else:
        n_all = len(net_nodes["node_id_def"])
        node_arr = (net_node_arr if net_node_arr is not None
                    else log_transform(_stack_cols(net_nodes, node_feat_cols),
                                       BINARY_NODE, node_feat_cols))
        pt_delay_gt = net_nodes["elmore_gt_ps"].astype(np.float32)
        timing_mask = net_nodes["has_elmore"].astype(bool)
        C_pin_liberty = (net_nodes["C_pin_liberty_pf"].astype(np.float32)
                         if has_liberty else np.zeros(n_all, dtype=np.float32))
        cell_types = net_nodes["cell_base_type"].astype(str)

    edge_arr = (net_edge_arr if net_edge_arr is not None
                  else log_transform(_stack_cols(net_segs, edge_feat_cols),
                                     BINARY_EDGE, edge_feat_cols))
    metal_lens = _stack_cols(net_segs, metal_cols).astype(np.float32)
    via_counts = _stack_cols(net_segs, via_cols).astype(np.float32)
    R_gt = net_segs["R_ohms"].astype(np.float32)
    C_edge_gt = net_segs["C_edge_pf"].astype(np.float32)

    if (R_gt <= 0).any():
        return None
    if np.isnan(metal_lens).any() or np.isnan(via_counts).any():
        return None

    n_edges = len(local_src)
    edge_index = np.empty((n_edges, 2), dtype=np.int64)
    edge_index[:, 0] = local_src
    edge_index[:, 1] = local_dst
    cell_type_idx = np.array([cell_vocab.get(t, unk_idx) for t in cell_types], dtype=np.int64)

    return {
        "net_name": net_key, "node_feats": node_arr, "edge_feats": edge_arr,
        "edge_index": edge_index.T, "metal_lens": metal_lens, "via_counts": via_counts,
        "R_gt": R_gt, "C_edge_gt": C_edge_gt,
        "pt_delay_gt": pt_delay_gt, "timing_mask": timing_mask,
        "C_pin_liberty": C_pin_liberty, "cell_type_idx": cell_type_idx,
    }

# returns a dict containing the graph data for one net, with all arrays converted to torch tensors. #
def _to_graph(r):
    g = {"net_name": r["net_name"]}
    for k in ("node_feats", "edge_feats", "metal_lens", "via_counts",
              "R_gt", "C_edge_gt", "pt_delay_gt", "C_pin_liberty"):
        g[k] = torch.from_numpy(np.ascontiguousarray(r[k], dtype=np.float32))
    g["edge_index"] = torch.from_numpy(np.ascontiguousarray(r["edge_index"], dtype=np.int64))
    g["cell_type_idx"] = torch.from_numpy(np.ascontiguousarray(r["cell_type_idx"], dtype=np.int64))
    g["timing_mask"] = torch.from_numpy(np.ascontiguousarray(r["timing_mask"], dtype=bool))
    return g


# returns a dict containing the graph data for one net, or None if the net is invalid. #
def _build_one(nk):
    st = _BUILD_STATE
    s_idx = st["seg_groups"][nk]
    n_idx = st["node_groups"].get(nk)
    net_segs = {k: v[s_idx] for k, v in st["seg_arrays"].items()}
    net_nodes = ({k: v[n_idx] for k, v in st["node_arrays"].items()}
                 if n_idx is not None else None)
    net_edge_arr = st["edge_feat_full"][s_idx]
    net_node_arr = st["node_feat_full"][n_idx] if n_idx is not None else None
    return process_net_core(nk, net_segs, net_nodes, st["ctx"],
                            net_edge_arr, net_node_arr)

# returns a tuple (graph_idx, elmore_dict) for one graph, where elmore_dict contains the precomputed Elmore BFS structure. #
def _elmore_one(i):
    g = _ELMORE_STATE["graphs"][i]
    dfi = _ELMORE_STATE["dfi"]
    ei = g["edge_index"].numpy()
    dcol = g["node_feats"][:, dfi].numpy()
    _, s = _precompute_single_core(
        i, list(zip(ei[0].tolist(), ei[1].tolist())),
        dcol.tolist(), dcol.shape[0], ei.shape[1])
    return i, s

# returns a dict mapping each unique key value to the row indices in the original array where that key occurs. # 
# This is used as a replacement for DataFrame.groupby(col).indices, which can be slow for large numbers of     #
# groups. The function uses factorization and argsort to achieve O(n log n) performance with small constants.  #
def _group_row_indices(key_values):
    codes, uniques = pd.factorize(key_values, sort=False)     
    order = np.argsort(codes, kind="stable")                  
    sc = codes[order]
    lo = int(np.searchsorted(sc, 0, side="left"))             
    sc, order = sc[lo:], order[lo:]
    if sc.size == 0:
        return {}
    change = np.flatnonzero(np.diff(sc)) + 1
    starts = np.concatenate(([0], change))
    ends = np.concatenate((change, [sc.size]))
    return {uniques[sc[s]]: order[s:e]
            for s, e in zip(starts.tolist(), ends.tolist())}

# Builds the full list of graph dicts and the meta dict from the segment and node DataFrames.#
# The edge features and node features are log-transformed, and the endpoint resolution is    # 
# performed to ensure that all edges connect to valid nodes. Builds the cell vocabulary from #
# the node DataFrame, and store it in the meta dict. The function returns a list of graph    #
# dicts and a meta dict containing feature column information and cell vocabulary.           #
def build_graphs(seg, node):
    _t = [time.time()]
    def _lap(msg):
        now = time.time()
        print(f"  [prep] {msg}: {now - _t[0]:.1f}s", flush=True)
        _t[0] = now

    for col in ("endpoint_1", "endpoint_2"):
        seg[col] = seg[col].map(normalize_escaping) # avoid double-escaping in the CSV #
    node["node_id_def"] = node["node_id_def"].map(normalize_escaping)
    node["cell_base_type"] = node["cell_base_type"].fillna(INTERNAL_TOKEN)
    _lap("normalize escaping")

    via_cols_all = [c for c in seg.columns if c.startswith("n_via_")]
    for c in via_cols_all:                      
        seg[c] = pd.to_numeric(seg[c], errors="coerce").fillna(0)  
    _lap(f"via to_numeric ({len(via_cols_all)} cols)")

    has_liberty = "C_pin_liberty_pf" in node.columns

    metal_cols = sorted((c for c in seg.columns if c.startswith("len_metal") and not c.endswith("_ratio")), key=lambda c: int(c.replace("len_metal", "")),)
    via_cols = [c for c in seg.columns if c.startswith("n_via_") and seg[c].sum() > 0]

    edge_feat_cols = (
        metal_cols + via_cols
        + ["total_vias", "total_len_um", "n_active_layers", "max_layer_idx",
           "via_density", "seg_len_fraction", "is_steiner", "is_via_dominated",
           "via_dom_metal2", "via_dom_metal3plus", "steiner_via_ratio",
           "steiner_layer", "steiner_len", "sinks_beyond_edge", "is_virtual_steiner"]
        + [f"{c}_ratio" for c in metal_cols]
    )
    node_len_cols = [c for c in node.columns
                     if c.startswith("len_metal") and not c.endswith("_ratio")]
    node_feat_cols = (
        ["is_pin", "is_driver_pin", "is_sink_pin", "node_degree", "tree_depth",
         "n_sink_pins", "subtree_n_sinks", "subtree_total_len", "n_active_layers",
         "max_layer_idx", "layer_span", "incident_vias", "max_via_level",
         "via_stack_height", "total_incident_len_um", "net_total_len",
         "net_n_segments", "net_total_vias", "net_max_sinks", "distance_to_driver_um",
         "distance_to_nearest_sink_um", "downstream_sink_count", "cell_strength"]
        + node_len_cols
    )
    edge_feat_cols = [c for c in edge_feat_cols if c in seg.columns]
    node_feat_cols = [c for c in node_feat_cols if c in node.columns]
    _lap("feature-column setup")

    seg_num = set(edge_feat_cols) | set(metal_cols) | set(via_cols) | {"R_ohms", "C_edge_pf"}
    for c in seg_num:
        if seg[c].dtype == object:
            seg[c] = pd.to_numeric(seg[c], errors="coerce")
    seg[edge_feat_cols] = seg[edge_feat_cols].fillna(0.0)
    _lap(f"seg to_numeric ({len(seg_num)} cols)")

    node_num = set(node_feat_cols) | {"elmore_gt_ps", "has_elmore"} | (
        {"C_pin_liberty_pf"} if has_liberty else set())
    for c in node_num:
        if node[c].dtype == object:
            node[c] = pd.to_numeric(node[c], errors="coerce")
    node[node_feat_cols] = node[node_feat_cols].fillna(0.0)
    node["elmore_gt_ps"] = node["elmore_gt_ps"].fillna(-1.0)
    node["has_elmore"] = node["has_elmore"].fillna(0).astype(int)
    if has_liberty:
        node["C_pin_liberty_pf"] = node["C_pin_liberty_pf"].fillna(0.0)
    node["cell_base_type"] = node["cell_base_type"].replace(0, INTERNAL_TOKEN).astype(str)
    _lap(f"node to_numeric ({len(node_num)} cols)")

    cell_vocab = build_cell_vocab(node)
    ctx = dict(edge_feat_cols=edge_feat_cols, node_feat_cols=node_feat_cols,
               metal_cols=metal_cols, via_cols=via_cols, cell_vocab=cell_vocab,
               has_liberty=has_liberty, unk_idx=cell_vocab[UNK_TOKEN])

    seg_cols = seg_num | {"net_key", "endpoint_1", "endpoint_2"} | {
        c for c in ("coord_x1", "coord_y1", "coord_x2", "coord_y2") if c in seg.columns}
    node_cols = node_num | {"net_key", "node_id_def", "cell_base_type"} | {
        c for c in ("coord_x", "coord_y") if c in node.columns}
    seg_arrays = {c: seg[c].values  for c in seg_cols}
    node_arrays = {c: node[c].values for c in node_cols}
    for c in ("coord_x1", "coord_y1", "coord_x2", "coord_y2"):
        if c in seg_arrays:
            seg_arrays[c] = pd.to_numeric(pd.Series(seg_arrays[c]), errors="coerce").to_numpy()
    for c in ("coord_x", "coord_y"):
        if c in node_arrays:
            node_arrays[c] = pd.to_numeric(pd.Series(node_arrays[c]), errors="coerce").to_numpy()
    _lap("array extraction")

    _RESOLVE_STATS.update(by_coord=0, extra=0, nets_with_extra=0)

    seg_groups = _group_row_indices(seg["net_key"].to_numpy())
    _lap(f"group seg rows ({len(seg_groups):,} nets)")
    node_groups = _group_row_indices(node["net_key"].to_numpy())
    _lap(f"group node rows ({len(node_groups):,} nets)")

    # log-transform the whole feature tables, then slice per net #
    edge_feat_full = log_transform(
        np.stack([np.asarray(seg_arrays[c], dtype=np.float64) for c in edge_feat_cols], axis=1),
        BINARY_EDGE, edge_feat_cols)
    node_feat_full = log_transform(
        np.stack([np.asarray(node_arrays[c], dtype=np.float64) for c in node_feat_cols], axis=1),
        BINARY_NODE, node_feat_cols)
    _lap("log_transform full tables")

    _BUILD_STATE.update(seg_arrays=seg_arrays, node_arrays=node_arrays, seg_groups=seg_groups, node_groups=node_groups, edge_feat_full=edge_feat_full, node_feat_full=node_feat_full, ctx=ctx)
    keys = list(seg_groups.keys())
    graphs, skipped = [], 0
    if GRAPH_BUILD_WORKERS > 1 and len(keys) > 1000:
        chunk = max(1, min(400, len(keys) // (GRAPH_BUILD_WORKERS * 8)))
        with _mp.get_context("fork").Pool(GRAPH_BUILD_WORKERS) as pool:
            for i, r in enumerate(pool.imap_unordered(_build_one, keys, chunksize=chunk)):
                if r is None:
                    skipped += 1
                else:
                    graphs.append(_to_graph(r))
                if (i + 1) % 100_000 == 0:
                    print(f"  [build] {i + 1:,}/{len(keys):,}  "
                          f"({time.time() - _t[0]:.0f}s)", flush=True)
        resolve_tracked = False
    else:
        for nk in keys:
            r = _build_one(nk)
            if r is None:
                skipped += 1
            else:
                graphs.append(_to_graph(r))
        resolve_tracked = True
    _BUILD_STATE.clear()
    _lap("graph build")

    graphs.sort(key=lambda g: g["net_name"])

    meta = dict(edge_feat_cols=edge_feat_cols, node_feat_cols=node_feat_cols, metal_cols=metal_cols, via_cols=via_cols, cell_vocab=cell_vocab, cell_vocab_size=len(cell_vocab))
    print(f"INFO: built {len(graphs):,} graphs from {len(keys):,} nets; skipped {skipped:,} nets", flush=True)
    return graphs, meta


# returns a dict containing the precomputed Elmore BFS structure for a single graph. #
def _precompute_single_core(g_idx, edge_index_list, driver_values, n_nodes, n_edges):
    empty = {"valid": False, "n_nodes": n_nodes, "n_edges": n_edges}
    if n_nodes == 0 or n_edges == 0:
        return g_idx, empty
    driver_candidates = [i for i in range(n_nodes) if driver_values[i] > 0.3]
    if not driver_candidates:
        return g_idx, empty
    driver_local = driver_candidates[0]

    adj = defaultdict(list)
    for ei, (u, v) in enumerate(edge_index_list):
        adj[u].append((v, ei))
        adj[v].append((u, ei))
    for node in adj:
        adj[node].sort()

    parent = [-1] * n_nodes
    parent_ei = [-1] * n_nodes
    levels = []
    visited = [False] * n_nodes
    depth_arr = [-1] * n_nodes
    queue = deque([driver_local])
    visited[driver_local] = True
    depth_arr[driver_local] = 0
    while queue:
        node = queue.popleft()
        d = depth_arr[node]
        if d >= len(levels):
            levels.append([])
        levels[d].append(node)
        for nbr, ei in adj[node]:
            if not visited[nbr]:
                visited[nbr] = True
                parent[nbr] = node
                parent_ei[nbr] = ei
                depth_arr[nbr] = d + 1
                queue.append(nbr)
    return g_idx, {
        "valid": True,
        "parent_loc_np": np.array(parent, dtype=np.int64),
        "parent_ei_loc_np": np.array(parent_ei, dtype=np.int64),
        "levels_np": [np.array(lv, dtype=np.int64) for lv in levels],
        "n_nodes": n_nodes, "n_edges": n_edges,
    }

# returns a list of dicts, one per graph, containing the precomputed Elmore BFS structure #
def precompute_elmore_structures(graphs, driver_feat_idx):
    out = [None] * len(graphs)
    if GRAPH_BUILD_WORKERS > 1 and len(graphs) > 1000:
        _ELMORE_STATE["graphs"] = graphs 
        _ELMORE_STATE["dfi"] = driver_feat_idx
        chunk = max(1, len(graphs) // (GRAPH_BUILD_WORKERS * 64))
        with _mp.get_context("fork").Pool(GRAPH_BUILD_WORKERS) as pool:
            for i, s in pool.imap_unordered(_elmore_one, range(len(graphs)),
                                            chunksize=chunk):
                out[i] = s
        _ELMORE_STATE.clear()
    else:
        for i, g in enumerate(graphs):
            ei = g["edge_index"].numpy()
            dcol = g["node_feats"][:, driver_feat_idx].numpy()
            _, s = _precompute_single_core(
                i, list(zip(ei[0].tolist(), ei[1].tolist())),
                dcol.tolist(), dcol.shape[0], ei.shape[1])
            out[i] = s
    n_valid = sum(s["valid"] for s in out)
    print(f"    {n_valid}/{len(graphs)} graphs have valid Elmore structure", flush=True)
    return out

# Precomputed Elmore BFS structures (parents, levels, node and edge counts) of a batch of graphs. #
class ElmoreStructs:
    def __init__(self, results, n_graphs):
        self.valid = np.array([r["valid"] for r in results], dtype=bool)
        self.n_nodes = np.array([r["n_nodes"] for r in results], dtype=np.int64)
        self.node_offsets = np.zeros(n_graphs + 1, dtype=np.int64)
        self.node_offsets[1:] = np.cumsum(np.where(self.valid, self.n_nodes, 0))
        pc, pec = [], []
        self.levels_per_graph = [None] * n_graphs
        for i, r in enumerate(results):
            if r["valid"]:
                pc.append(r["parent_loc_np"])
                pec.append(r["parent_ei_loc_np"])
                self.levels_per_graph[i] = r["levels_np"]
            else:
                self.levels_per_graph[i] = []
        self.parent_loc_np = np.concatenate(pc)  if pc  else np.array([], dtype=np.int64)
        self.parent_ei_loc_np = np.concatenate(pec) if pec else np.array([], dtype=np.int64)

    def __len__(self):
        return len(self.valid)

    def __getitem__(self, i):
        if not self.valid[i]:
            return {"valid": False, "n_nodes": int(self.n_nodes[i]), "n_edges": 0}
        ns, ne = self.node_offsets[i], self.node_offsets[i + 1]
        return {
            "valid": True,
            "parent_loc_np": self.parent_loc_np[ns:ne],
            "parent_ei_loc_np": self.parent_ei_loc_np[ns:ne],
            "levels_np": self.levels_per_graph[i],
            "n_nodes": int(self.n_nodes[i]),
        }

# Returns the Elmore delay for each node in the graph, given the effective resistance and # 
# capacitance values. This is a batched implementation that uses the precomputed parent   #
# and level information from the Elmore BFS structure.                                    #
def compute_elmore(R_eff, C_node_eff, C_edge_eff, edge_index, batch, device):
    n_nodes = C_node_eff.shape[0]
    src, dst = edge_index[0], edge_index[1]
    C_half = torch.zeros(n_nodes, device=device, dtype=R_eff.dtype)
    C_half.scatter_add_(0, src, C_edge_eff * 0.5)
    C_half.scatter_add_(0, dst, C_edge_eff * 0.5)
    C_total = C_node_eff + C_half

    parent_glob = batch["parent_glob"].to(device)
    parent_ei_glob = batch["parent_ei_glob"].to(device)
    levels_cat = {d: t.to(device) for d, t in batch["levels_cat"].items()}
    max_depth = max(levels_cat.keys()) + 1 if levels_cat else 0

    sc = C_total.clone()
    for d in range(max_depth - 1, 0, -1):
        if d not in levels_cat:
            continue
        children = levels_cat[d]
        parents = parent_glob[children]
        sc.scatter_add_(0, parents, sc[children])

    dl = torch.zeros(n_nodes, device=device, dtype=R_eff.dtype)
    for d in range(1, max_depth):
        if d not in levels_cat:
            continue
        children = levels_cat[d]
        parents = parent_glob[children]
        edge_idxs = parent_ei_glob[children]
        dl[children] = dl[parents] + R_eff[edge_idxs] * sc[children]
    return dl


# Collate function for batching graphs.  Returns a dict of tensors, with node and edge features #
# concatenated, and edge indices adjusted for the new node indices in the batch.  Also returns  #
# the parent and level information for the Elmore BFS structure, as well as the graph IDs for   #
# each node and edge in the batch. This is used in the DataLoader for batching graphs together. #
def collate_graphs(batch):
    node_offset = 0
    (all_node_feats, all_edge_feats, all_edge_index, all_metal_lens, all_via_counts,
     all_R_gt, all_C_edge_gt, all_pt_delay_gt,
     all_timing_mask, all_C_pin_liberty, all_cell_type_idx, all_design_ids) = (
        [], [], [], [], [], [], [], [], [], [], [], [])
    node_counts, edge_counts = [], []

    for g in batch:
        n_nodes = g["node_feats"].shape[0]
        n_edges = g["edge_feats"].shape[0]
        all_node_feats.append(g["node_feats"])
        all_edge_feats.append(g["edge_feats"])
        all_edge_index.append(g["edge_index"] + node_offset)
        all_metal_lens.append(g["metal_lens"])
        all_via_counts.append(g["via_counts"])
        all_R_gt.append(g["R_gt"])
        all_C_edge_gt.append(g["C_edge_gt"])
        all_pt_delay_gt.append(g["pt_delay_gt"])
        all_timing_mask.append(g["timing_mask"])
        all_C_pin_liberty.append(g["C_pin_liberty"])
        all_cell_type_idx.append(g["cell_type_idx"])
        all_design_ids.append(g.get("design_id", "unknown"))
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
    ns_arr = node_offsets.numpy(); es_arr = edge_offsets.numpy()
    nc_arr = node_counts_t.numpy(); ec_arr = edge_counts_t.numpy()

    # Populate parent and level information for each graph in the batch, adjusting for the node offsets. #
    for i, g in enumerate(batch):
        s = g.get("elmore_struct", {"valid": False})
        if not s["valid"]:
            continue
        ns, nc = int(ns_arr[i]), int(nc_arr[i])
        es, ec = int(es_arr[i]), int(ec_arr[i])
        if nc == 0 or ec == 0:
            continue
        parent_loc = torch.from_numpy(s["parent_loc_np"])
        parent_ei_loc = torch.from_numpy(s["parent_ei_loc_np"])
        valid_mask = parent_loc >= 0
        local_idx = torch.where(valid_mask)[0]
        global_idx = local_idx + ns
        parent_glob_cpu[global_idx] = parent_loc[local_idx] + ns
        parent_ei_glob_cpu[global_idx] = parent_ei_loc[local_idx] + es
        for d, lv_np in enumerate(s["levels_np"]):
            levels_by_depth[d].append(torch.from_numpy(lv_np) + ns)

    levels_cat_cpu = {d: torch.cat(ts) for d, ts in levels_by_depth.items()}

    return {
        "node_feats"    : torch.cat(all_node_feats, dim=0).float(),
        "edge_feats"    : torch.cat(all_edge_feats, dim=0).float(),
        "n_graphs"      : len(batch),
        "edge_index"    : torch.cat(all_edge_index, dim=1).long(),
        "metal_lens"    : torch.cat(all_metal_lens, dim=0).float(),
        "design_ids"    : all_design_ids,
        "via_counts"    : torch.cat(all_via_counts, dim=0).float(),
        "R_gt"          : torch.cat(all_R_gt, dim=0).float(),
        "C_edge_gt"     : torch.cat(all_C_edge_gt, dim=0).float(),
        "pt_delay_gt"   : torch.cat(all_pt_delay_gt, dim=0).float(),
        "timing_mask"   : torch.cat(all_timing_mask, dim=0).bool(),
        "C_pin_liberty" : torch.cat(all_C_pin_liberty, dim=0).float(),
        "cell_type_idx" : torch.cat(all_cell_type_idx, dim=0).long(),
        "graph_ids_node": torch.repeat_interleave(
            torch.arange(len(batch), dtype=torch.long), node_counts_t),
        "graph_ids_edge": torch.repeat_interleave(
            torch.arange(len(batch), dtype=torch.long), edge_counts_t),
        "parent_glob"   : parent_glob_cpu,
        "parent_ei_glob": parent_ei_glob_cpu,
        "levels_cat"    : levels_cat_cpu,
    }

def make_residual_head(in_dim):
    return nn.Sequential(
        nn.Linear(in_dim, 64), nn.GELU(), nn.Dropout(0.1),
        nn.Linear(64, 32), nn.GELU(), nn.Linear(32, 1),
    )

# Gating network of the mixture of experts. A linear layer and a softmax give the weight of each expert. #
class MoEGatingNetwork(nn.Module):
    def __init__(self, input_dim, num_experts, dropout=0.1):
        super().__init__()
        self.gate = nn.Linear(input_dim, num_experts)
        self.dropout = nn.Dropout(dropout)
        nn.init.xavier_uniform_(self.gate.weight)
        nn.init.uniform_(self.gate.bias, -0.1, 0.1)

    def forward(self, x):
        return F.softmax(self.gate(self.dropout(x)), dim=-1)

# Expert of the mixture of experts: four linear layers with ReLU and dropout. #
class MoEExpert(nn.Module):
    def __init__(self, input_dim, hidden_dim, output_dim, dropout=0.1):
        super().__init__()
        self.fc1 = nn.Linear(input_dim, hidden_dim // 2)
        self.fc2 = nn.Linear(hidden_dim // 2, hidden_dim // 4)
        self.fc3 = nn.Linear(hidden_dim // 4, hidden_dim // 8)
        self.fc4 = nn.Linear(hidden_dim // 8, output_dim)
        self.dropout = nn.Dropout(dropout)

    def forward(self, x):
        x = F.relu(self.fc1(x)); x = self.dropout(x)
        x = F.relu(self.fc2(x)); x = self.dropout(x)
        x = F.relu(self.fc3(x)); x = self.dropout(x)
        return self.fc4(x)

# Mixture of experts that predicts log(C_total) per net, as the gate-weighted sum of the expert outputs. #
class CTotalMoELayer(nn.Module):
    def __init__(self, input_dim, num_experts, hidden_dim, output_dim=1, dropout=0.1):
        super().__init__()
        self.gating_network = MoEGatingNetwork(input_dim, num_experts, dropout)
        self.experts = nn.ModuleList([
            MoEExpert(input_dim, hidden_dim, output_dim, dropout) for _ in range(num_experts)
        ])

    def forward(self, x):
        gate_scores = self.gating_network(x)
        expert_outputs = torch.stack([e(x) for e in self.experts], dim=1)
        return torch.sum(gate_scores.unsqueeze(-1) * expert_outputs, dim=1)

# NodeEncoder encodes node features into a fixed-size embedding. It consists of a two-layer         #
# feedforward neural network with layer normalization and GELU activation, followed by dropout      #
# for regularization. The forward method takes node features as input and returns their embeddings. #
class NodeEncoder(nn.Module):
    def __init__(self, input_dim):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(input_dim, EMBED_DIM), nn.LayerNorm(EMBED_DIM), nn.GELU(), nn.Dropout(0.1),
            nn.Linear(EMBED_DIM, EMBED_DIM), nn.LayerNorm(EMBED_DIM), nn.GELU(),
        )

    def forward(self, x):
        return self.net(x)

# EdgeEncoder encodes edge features into a fixed-size embedding. It consists of a two-layer         # 
# feedforward neural network with layer normalization and GELU activation, followed by dropout      #
# for regularization. The forward method takes edge features as input and returns their embeddings. #
class EdgeEncoder(nn.Module):
    def __init__(self, edge_feat_dim):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(edge_feat_dim, EMBED_DIM), nn.LayerNorm(EMBED_DIM), nn.GELU(), nn.Dropout(0.1),
            nn.Linear(EMBED_DIM, EMBED_DIM), nn.LayerNorm(EMBED_DIM), nn.GELU(),
        )

    def forward(self, x):
        return self.net(x)

# One round of message passing. Edge messages are summed into the nodes (scatter_add), then node messages update #
# the edges, each followed by normalization.                                                                     #
class MessagePassingRound(nn.Module):
    def __init__(self):
        super().__init__()
        self.edge_to_node_msg = nn.Sequential(nn.Linear(EMBED_DIM * 2, EMBED_DIM), nn.GELU())
        self.edge_to_node_upd = nn.Sequential(nn.Linear(EMBED_DIM, EMBED_DIM), nn.GELU())
        self.node_norm = nn.LayerNorm(EMBED_DIM)
        self.node_to_edge_msg = nn.Sequential(nn.Linear(EMBED_DIM * 3, EMBED_DIM), nn.GELU())
        self.node_to_edge_upd = nn.Sequential(nn.Linear(EMBED_DIM, EMBED_DIM), nn.GELU())
        self.edge_norm = nn.LayerNorm(EMBED_DIM)

    def forward(self, node_emb, edge_emb, edge_index):
        src, dst = edge_index[0], edge_index[1]
        n_nodes = node_emb.shape[0]
        msg_to_src = self.edge_to_node_msg(torch.cat([edge_emb, node_emb[dst]], dim=1))
        msg_to_dst = self.edge_to_node_msg(torch.cat([edge_emb, node_emb[src]], dim=1))
        agg = torch.zeros(n_nodes, EMBED_DIM, device=node_emb.device, dtype=msg_to_src.dtype)
        deg = torch.zeros(n_nodes, 1, device=node_emb.device, dtype=msg_to_src.dtype)
        agg.scatter_add_(0, src.unsqueeze(1).expand_as(msg_to_src), msg_to_src)
        agg.scatter_add_(0, dst.unsqueeze(1).expand_as(msg_to_dst), msg_to_dst)
        deg.scatter_add_(0, src.unsqueeze(1), torch.ones_like(src, dtype=msg_to_src.dtype).unsqueeze(1))
        deg.scatter_add_(0, dst.unsqueeze(1), torch.ones_like(dst, dtype=msg_to_dst.dtype).unsqueeze(1))
        agg = agg / deg.clamp(min=1.0)
        node_emb = self.node_norm(node_emb + self.edge_to_node_upd(agg))
        msg_edge = self.node_to_edge_msg(torch.cat([node_emb[src], node_emb[dst], edge_emb], dim=1))
        edge_emb = self.edge_norm(edge_emb + self.node_to_edge_upd(msg_edge))
        return node_emb, edge_emb

# Bypass: Predicts per-edge R and C_edge only, without a node-capacitance head.                 #
# __init__() initializes the model with node and edge feature dimensions, number of metals,     #
# number of via types, and cell vocabulary size. It sets up learnable parameters for metal      # 
# and via resistances, embedding layers for cell types, encoders for node and edge features,    # 
# message passing rounds, and heads for predicting delta R, C_edge, and residuals.              #
# The forward() method processes input features through the encoders and message passing rounds #
# to produce predictions for R and C_edge, as well as effective values considering residuals.   #
# It also includes a MoE layer for predicting total capacitance per net.                        #
# forward() returns a tuple containing predicted R, C_edge, log C_edge, effective R, effective  #
# C_edge, residuals for R and C_edge, and predicted log C_total.                                #
class Bypass(nn.Module):
    def __init__(self, node_feat_dim, edge_feat_dim, n_metals, n_via_types, cell_vocab_size):
        super().__init__()
        self.r_L = nn.Parameter(torch.ones(n_metals))
        self.r_via = nn.Parameter(torch.ones(n_via_types))

        self.cell_embedding = nn.Embedding(cell_vocab_size, CELL_EMBED_DIM, padding_idx=0)
        self.node_encoder = NodeEncoder(node_feat_dim + CELL_EMBED_DIM)
        self.edge_encoder = EdgeEncoder(edge_feat_dim)
        self.mp_rounds = nn.ModuleList([MessagePassingRound() for _ in range(MP_ROUNDS)])

        self.delta_r_head = nn.Sequential(
            nn.Linear(EMBED_DIM, 128), nn.GELU(), nn.Dropout(0.1),
            nn.Linear(128, 64), nn.GELU(), nn.Linear(64, 1),
        )
        self.c_edge_head = nn.Sequential(
            nn.Linear(EMBED_DIM, 128), nn.GELU(), nn.Dropout(0.1),
            nn.Linear(128, 64), nn.GELU(), nn.Linear(64, 1),
        )
        self.rho_r_head = make_residual_head(EMBED_DIM)
        self.rho_cedge_head = make_residual_head(EMBED_DIM)

        self.ctotal_moe = CTotalMoELayer(EMBED_DIM, MOE_NUM_EXPERTS, EMBED_DIM, output_dim=1)

    def forward(self, node_feats, edge_feats, edge_index, metal_lens, via_counts, cell_type_idx, graph_ids_node=None, graph_ids_edge=None, n_graphs=None):
        cell_emb = self.cell_embedding(cell_type_idx)
        node_emb = self.node_encoder(torch.cat([node_feats, cell_emb], dim=1))
        edge_emb = self.edge_encoder(edge_feats)

        for mp in self.mp_rounds:
            node_emb, edge_emb = mp(node_emb, edge_emb, edge_index)

        R_base = (metal_lens * self.r_L).sum(dim=1) + (via_counts * self.r_via).sum(dim=1)
        R_base = R_base.clamp(min=1e-6)
        delta_r = torch.clamp(self.delta_r_head(edge_emb).squeeze(1), -5.0, 5.0)
        R_pred = R_base * torch.exp(delta_r)

        # absolute C_edge head: log C_edge = head + C_EDGE_BIAS (bias warm-started) #
        log_C_edge = torch.clamp(self.c_edge_head(edge_emb).squeeze(1) + C_EDGE_BIAS, -20.0, -2.0)
        C_edge_pred = torch.exp(log_C_edge)

        # net-level C_total MoE: predict one total per net, then rescale C_edge_pred    #
        # so it sums exactly to that total, keeping the per-edge head's shape unchanged.#
        log_C_total_pred = None
        if graph_ids_edge is not None and graph_ids_edge.numel():
            if n_graphs is None:
                n_graphs = int(graph_ids_edge.max().item()) + 1
            pooled = torch.zeros(n_graphs, edge_emb.shape[1],
                                 device=edge_emb.device, dtype=edge_emb.dtype)
            counts = torch.zeros(n_graphs, device=edge_emb.device, dtype=edge_emb.dtype)
            pooled.scatter_add_(0, graph_ids_edge.unsqueeze(1).expand_as(edge_emb), edge_emb)
            counts.scatter_add_(0, graph_ids_edge,
                                torch.ones_like(graph_ids_edge, dtype=edge_emb.dtype))
            pooled = pooled / counts.clamp(min=1.0).unsqueeze(1)
            log_C_total_pred = self.ctotal_moe(pooled).squeeze(1)
            C_total_pred = torch.exp(log_C_total_pred.clamp(min=-25.0, max=5.0))

            per_net_sum = torch.zeros(n_graphs, device=edge_emb.device, dtype=C_edge_pred.dtype)
            per_net_sum.scatter_add_(0, graph_ids_edge, C_edge_pred)
            scale = C_total_pred / per_net_sum.clamp(min=1e-12)
            C_edge_pred = C_edge_pred * scale[graph_ids_edge]
            log_C_edge = torch.log(C_edge_pred + 1e-12)

        rho_R = torch.clamp(self.rho_r_head(edge_emb).squeeze(1),     -3.0, 3.0)
        rho_Cedge = torch.clamp(self.rho_cedge_head(edge_emb).squeeze(1), -3.0, 3.0)
        R_eff = R_pred      * torch.exp(rho_R)
        C_edge_eff = C_edge_pred * torch.exp(rho_Cedge)

        return (R_pred, C_edge_pred, log_C_edge, R_eff, C_edge_eff, rho_R, rho_Cedge,
                log_C_total_pred)


def huber_log_loss(pred, gt, delta=HUBER_DELTA):
    diff = torch.log(pred + 1e-12) - torch.log(gt + 1e-12)
    return F.huber_loss(diff, torch.zeros_like(diff), delta=delta, reduction="none").mean()

# Returns total loss and individual components: (total, l_R, l_C_edge, l_timing, l_rho_reg, l_c_total) #
# total loss = LAMBDA_R * l_R + LAMBDA_C_EDGE * l_C_edge + LAMBDA_TIMING * l_timing 
#             + LAMBDA_RHO * l_rho_reg + LAMBDA_RHO_VAR * l_rho_var + LAMBDA_C_TOTAL * l_c_total
def total_loss(batch, preds, device, tree_depth_idx=None):
    (R_pred, C_edge_pred, log_C_edge, R_eff, C_edge_eff, rho_R, rho_Cedge, log_C_total_pred) = preds

    R_gt = batch["R_gt"].to(device)
    C_edge_gt = batch["C_edge_gt"].to(device)
    pt_delay_gt = batch["pt_delay_gt"].to(device)
    timing_mask = batch["timing_mask"].to(device)
    edge_index = batch["edge_index"].to(device)
    node_feats = batch["node_feats"].to(device)
    gid_e = batch["graph_ids_edge"].to(device)
    nb = int(gid_e.max().item()) + 1 if gid_e.numel() else 1

    # placeholder / sentinel edges: R hard-coded to 0.001 Ohm in the extraction   #
    # flow, zero geometry, no physical capacitance.                               #
    # They carry no  learnable signal (a constant target), so we  exclude them.   #
    # They stay in the graph for connectivity.                                    #
    placeholder = (R_gt > 0) & (R_gt <= 1.5e-3)

    r_mask = (torch.isfinite(R_gt) & torch.isfinite(R_pred) & (R_gt > 0) & (R_pred > 0) & ~placeholder)
    ce_mask = (torch.isfinite(C_edge_gt) & torch.isfinite(C_edge_pred) & (C_edge_gt > 0) & (C_edge_pred > 0) & ~placeholder)

    l_R = huber_log_loss(R_pred[r_mask], R_gt[r_mask]) if r_mask.any() \
        else torch.tensor(0.0, device=device)
    l_C_edge = huber_log_loss(C_edge_pred[ce_mask], C_edge_gt[ce_mask]) \
        if ce_mask.any() else torch.tensor(0.0, device=device)

    l_timing = torch.tensor(0.0, device=device)
    if timing_mask.any():
        C_pin_liberty = batch["C_pin_liberty"].to(device)
        elmore_pred = compute_elmore(
            R_eff, C_pin_liberty, C_edge_eff, edge_index, batch, device)
        valid = timing_mask & (pt_delay_gt > 0) & (elmore_pred > 0)
        if valid.any():
            log_diff_t = (torch.log(elmore_pred[valid] + 1e-12)
                          - torch.log(pt_delay_gt[valid] + 1e-12))
            if tree_depth_idx is not None:
                depth = node_feats[valid, tree_depth_idx].clamp(0, 20)
                dw = 1.0 + 0.1 * depth
                dw = dw / dw.mean().clamp(min=1e-8)
            else:
                dw = torch.ones(int(valid.sum()), device=device)
            per_node = F.huber_loss(log_diff_t, torch.zeros_like(log_diff_t),
                                    delta=HUBER_DELTA, reduction="none")
            l_timing = (dw * per_node).mean()

    l_rho_reg = (rho_R ** 2).mean() + (rho_Cedge ** 2).mean()

    def rho_var_penalty(rho):
        return F.relu(RHO_TARGET_STD - rho.std()) ** 2

    l_rho_var = rho_var_penalty(rho_R) + rho_var_penalty(rho_Cedge)

    # net-level C_total MoE: direct huber loss against sum(C_edge_gt) per net #
    l_c_total = torch.tensor(0.0, device=device)
    if log_C_total_pred is not None and ce_mask.any():
        sg_direct = torch.zeros(nb, device=device).scatter_add_(0, gid_e[ce_mask], C_edge_gt[ce_mask])
        valid_nets = sg_direct > 0
        if valid_nets.any():
            C_total_pred_direct = torch.exp(log_C_total_pred.clamp(min=-25.0, max=5.0))
            l_c_total = huber_log_loss(C_total_pred_direct[valid_nets], sg_direct[valid_nets])

    total = (LAMBDA_R * l_R + LAMBDA_C_EDGE * l_C_edge + LAMBDA_TIMING * l_timing + LAMBDA_RHO * l_rho_reg + LAMBDA_RHO_VAR * l_rho_var + LAMBDA_C_TOTAL * l_c_total)
    return total, l_R, l_C_edge, l_timing, l_rho_reg, l_c_total

# Returns a dictionary of regression metrics (R^2, MAE, RMSE, MAPE, median APE, 90th percentile APE, log-MAE) #
def regression_metrics(y_true, y_pred, eps=1e-12):
    y_true = np.asarray(y_true, dtype=np.float64)
    y_pred = np.asarray(y_pred, dtype=np.float64)
    mask = np.isfinite(y_true) & np.isfinite(y_pred) & (y_true > 0) & (y_pred > 0)
    y_true, y_pred = y_true[mask], y_pred[mask]
    if len(y_true) == 0:
        return {k: np.nan for k in
                ["r2", "mae", "rmse", "mape_pct", "median_ape_pct", "p90_ape_pct", "log_mae"]}
    err = y_pred - y_true
    ape = np.abs(err) / np.maximum(np.abs(y_true), eps)
    log_e = np.abs(np.log(y_pred + eps) - np.log(y_true + eps))
    ss_res = np.sum((y_true - y_pred) ** 2)
    ss_tot = np.sum((y_true - np.mean(y_true)) ** 2)
    return {
        "r2": 1.0 - ss_res / ss_tot if ss_tot > 0 else np.nan,
        "mae": np.mean(np.abs(err)), "rmse": np.sqrt(np.mean(err ** 2)),
        "mape_pct": 100.0 * np.mean(ape), "median_ape_pct": 100.0 * np.median(ape),
        "p90_ape_pct": 100.0 * np.percentile(ape, 90), "log_mae": np.mean(log_e),
    }

# Returns a composite validation score that combines log-MAE, R^2 penalty, and optional bias penalties. #
def composite_val_score(Rm, Cem, Tm=None, bias=None):
    
    r2_penalty = max(0.0, 0.95 - Rm["r2"]) if not np.isnan(Rm["r2"]) else 1.0
    t_lm = Tm["log_mae"] if (Tm is not None and not np.isnan(Tm["log_mae"])) else 0.0
    b = 0.0
    if bias is not None:
        b = abs(bias.get("R", 0.0)) + abs(bias.get("Ce", 0.0)) + abs(bias.get("T", 0.0))
    return (0.5 * Cem["log_mae"] + 0.4 * Rm["log_mae"] + 0.4 * t_lm + 4.0 * r2_penalty + 1.0 * b)


# GraphDataset is a PyTorch Dataset that holds a list of graphs and their corresponding Elmore structures. #
# It concatenates the node and edge features, as well as other relevant data, into single arrays.          #
# The __getitem__ method retrieves the data for a specific graph, including its node and edge features,    #
# ground truth values, and Elmore structure.                                                               #
class GraphDataset(Dataset):
    def __init__(self, graphs, elmore_structs):
        n = len(graphs)
        nc = np.array([g["node_feats"].shape[0] for g in graphs], dtype=np.int64)
        ec = np.array([g["edge_feats"].shape[0] for g in graphs], dtype=np.int64)
        self.node_offsets = np.zeros(n + 1, dtype=np.int64); self.node_offsets[1:] = np.cumsum(nc)
        self.edge_offsets = np.zeros(n + 1, dtype=np.int64); self.edge_offsets[1:] = np.cumsum(ec)
        cat = lambda k, ax=0: np.concatenate([g[k].numpy() for g in graphs], axis=ax)
        self.node_feats = cat("node_feats")
        self.pt_delay_gt = cat("pt_delay_gt")
        self.timing_mask = cat("timing_mask")
        self.C_pin_liberty = cat("C_pin_liberty")
        self.cell_type_idx = cat("cell_type_idx")
        self.edge_feats = cat("edge_feats")
        self.edge_index = cat("edge_index", ax=1)
        self.metal_lens = cat("metal_lens")
        self.via_counts = cat("via_counts")
        self.R_gt = cat("R_gt")
        self.C_edge_gt = cat("C_edge_gt")
        self.net_names = [g["net_name"] for g in graphs]
        self.design_ids = [g.get("design_id", "unknown") for g in graphs]
        self.s = elmore_structs

    def __len__(self):
        return len(self.net_names)

    def __getitem__(self, i):
        ns, ne = self.node_offsets[i], self.node_offsets[i + 1]
        es, ee = self.edge_offsets[i], self.edge_offsets[i + 1]
        return {
            "node_feats": torch.from_numpy(self.node_feats[ns:ne]),
            "pt_delay_gt": torch.from_numpy(self.pt_delay_gt[ns:ne]),
            "timing_mask": torch.from_numpy(self.timing_mask[ns:ne]),
            "C_pin_liberty": torch.from_numpy(self.C_pin_liberty[ns:ne]),
            "cell_type_idx": torch.from_numpy(self.cell_type_idx[ns:ne]),
            "edge_feats": torch.from_numpy(self.edge_feats[es:ee]),
            "edge_index": torch.from_numpy(self.edge_index[:, es:ee]),
            "metal_lens": torch.from_numpy(self.metal_lens[es:ee]),
            "via_counts": torch.from_numpy(self.via_counts[es:ee]),
            "R_gt": torch.from_numpy(self.R_gt[es:ee]),
            "C_edge_gt": torch.from_numpy(self.C_edge_gt[es:ee]),
            "net_name": self.net_names[i],
            "design_id": self.design_ids[i],
            "elmore_struct": self.s[i],
        }

# Apply NNLS warm-start to r_L and r_via, and initialize the C_edge head bias to C_EDGE_BIAS #
# such that the initial C_edge predictions are roughly the median of the training data.       #
def warm_start(model, metal_cols, via_cols):
    
    if R_L_CSV.exists():
        r_L_df = pd.read_csv(R_L_CSV).set_index("metal_layer")
        for i, col in enumerate(metal_cols):
            val = float(r_L_df.loc[col, "r_L_ohm_per_um"]) if col in r_L_df.index else 1.5
            model.r_L.data[i] = torch.tensor(max(val, 0.1), dtype=torch.float32)
    else:
        print(f"[WARN] r_L CSV not found: {R_L_CSV}")
    if R_VIA_CSV.exists():
        r_via_df = pd.read_csv(R_VIA_CSV).set_index("via_type")
        for i, col in enumerate(via_cols):
            val = float(r_via_df.loc[col, "r_via_ohm"]) if col in r_via_df.index else 3.0
            model.r_via.data[i] = torch.tensor(max(val, 0.1), dtype=torch.float32)
    else:
        print(f"[WARN] r_via CSV not found: {R_VIA_CSV}")

    # absolute C_edge head: bias -> C_edge starts at exp(C_EDGE_BIAS) ~= data median #
    nn.init.zeros_(model.c_edge_head[-1].weight)
    nn.init.constant_(model.c_edge_head[-1].bias, C_EDGE_BIAS)

    for head in (model.delta_r_head, model.rho_r_head, model.rho_cedge_head):
        nn.init.zeros_(head[-1].weight)
        nn.init.zeros_(head[-1].bias)
    print(f"  warm start done (r_L / r_via loaded; c_edge head = absolute bias {C_EDGE_BIAS})")


# Save the best plots to a PNG file for later analysis or reporting #
def save_best_plots(r_preds, r_gts, ce_preds, ce_gts, t_preds, t_gts, epoch, path):
    has_t = len(t_preds) > 0 and len(t_gts) > 0
    n = 3 if has_t else 2
    fig, axes = plt.subplots(1, n, figsize=(6 * n, 5))
    data = [
        (r_gts,  r_preds,  f"Resistance (Epoch {epoch})", "Ohms", "blue"),
        (ce_gts, ce_preds, f"C_edge (Epoch {epoch})",     "pF",   "orange"),
    ]
    if has_t:
        data.append((t_gts, t_preds, f"Elmore Delay (Epoch {epoch})", "ps", "red"))
    for ax, (gts, preds, title, unit, color) in zip(np.atleast_1d(axes), data):
        g = np.asarray(gts, np.float64); p = np.asarray(preds, np.float64)
        m = (g > 0) & (p > 0) & np.isfinite(g) & np.isfinite(p)
        if m.sum() > 0:
            g, p = g[m], p[m]
            ax.scatter(g, p, alpha=0.3, s=5, color=color, rasterized=True)
            lo, hi = min(g.min(), p.min()), max(g.max(), p.max())
            ax.plot([lo, hi], [lo, hi], "k--", lw=1)
            r2 = 1.0 - np.sum((g - p) ** 2) / np.sum((g - g.mean()) ** 2)
            mape = 100.0 * np.mean(np.abs(g - p) / np.maximum(np.abs(g), 1e-12))
            ax.set_title(f"{title}\nR2={r2:.4f}  MAPE={mape:.2f}%", fontsize=9)
        else:
            ax.set_title(f"{title}\n(no valid data)", fontsize=9)
        ax.set_xscale("log"); ax.set_yscale("log")
        ax.set_xlabel(f"Ground Truth ({unit})"); ax.set_ylabel(f"Predicted ({unit})")
        ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(path, dpi=150, bbox_inches="tight")
    plt.close()

# Save the best metrics to a JSON file for later analysis or reporting #
def save_best_metrics(epoch, avg_v, Rm, Cem, Tm, path):
    m = {"epoch": epoch, "val_loss": avg_v["loss"],
         "val_R": avg_v["R"], "val_C_edge": avg_v["C_edge"], "val_timing": avg_v["timing"],
         "R_r2": Rm["r2"], "R_mae": Rm["mae"], "R_rmse": Rm["rmse"], "R_mape_pct": Rm["mape_pct"],
         "R_median_ape": Rm["median_ape_pct"], "R_p90_ape": Rm["p90_ape_pct"], "R_log_mae": Rm["log_mae"],
         "Ce_r2": Cem["r2"], "Ce_mae": Cem["mae"], "Ce_rmse": Cem["rmse"], "Ce_mape_pct": Cem["mape_pct"],
         "Ce_median_ape": Cem["median_ape_pct"], "Ce_p90_ape": Cem["p90_ape_pct"], "Ce_log_mae": Cem["log_mae"],
         "T_r2": Tm["r2"], "T_mae": Tm["mae"], "T_rmse": Tm["rmse"], "T_mape_pct": Tm["mape_pct"],
         "T_median_ape": Tm["median_ape_pct"], "T_p90_ape": Tm["p90_ape_pct"], "T_log_mae": Tm["log_mae"]}
    with open(path.with_suffix(".json"), "w") as f:
        json.dump(m, f, indent=2,
                  default=lambda x: None if (isinstance(x, float) and np.isnan(x)) else float(x))
    return m

# Print the epoch stats to the console in a readable format for every epoch during the training #
def print_epoch_stats(epoch, avg_t, avg_v, Rm, Cem, Tm, model, status, elapsed, per_design=None, bias=None):
    print(f"INFO: Epoch {epoch:3d}/{EPOCHS} [{elapsed:.1f}s]  train loss {avg_t:.4f}  val loss {avg_v['loss']:.4f}  ({status})")
    print(f"INFO: Val loss terms: R {avg_v['R']:.4f}  C_edge {avg_v['C_edge']:.4f}  timing {avg_v['timing']:.4f}  rho {avg_v['rho']:.4f}  ctot_moe {avg_v['ctot_moe']:.4f}")
    if bias is not None:
        print(f"INFO: Signed bias (median log pred/gt on val): R {bias['R']:+.4f}  C_edge {bias['Ce']:+.4f}  timing {bias['T']:+.4f}")
    print(f"INFO: Val metrics")
    print(f"  {'Target':<8} | {'R2':>8} | {'MAE':>10} | {'RMSE':>10} | {'MAPE%':>8} | {'MedAPE%':>8} | {'P90APE%':>8} | {'LogMAE':>8}")
    print(f"  {'-' * 86}")

    def row(name, mm):
        f = lambda v, s: (s % v) if not np.isnan(v) else "nan"
        print(f"  {name:<8} | {f(mm['r2'], '%.4f'):>8} | {f(mm['mae'], '%.3e'):>10} | {f(mm['rmse'], '%.3e'):>10} | {f(mm['mape_pct'], '%.2f'):>8} | {f(mm['median_ape_pct'], '%.2f'):>8} | {f(mm['p90_ape_pct'], '%.2f'):>8} | {f(mm['log_mae'], '%.4f'):>8}")

    row("R_edge", Rm); row("C_edge", Cem); row("Timing", Tm)
    print(f"INFO: r_L [{', '.join(f'{v:.4f}' for v in model.r_L.data.tolist())}]")
    print(f"INFO: r_via [{', '.join(f'{v:.4f}' for v in model.r_via.data.tolist()[:5])}, ...]")
    if per_design:
        print(f"INFO: Val metrics per design")
        print(f"  {'Design':<28} | {'R R2':>8} | {'Ce R2':>8} | {'R MAPE%':>9} | {'Ce MAPE%':>9} | {'Ce LogMAE':>10} | {'T R2':>8}")
        print(f"  {'-' * 96}")
        g4 = lambda v: f"{v:.4f}" if not np.isnan(v) else "nan"
        g2 = lambda v: f"{v:.2f}" if not np.isnan(v) else "nan"
        for d, dm in sorted(per_design.items()):
            print(f"  {d:<28} | {g4(dm['R']['r2']):>8} | {g4(dm['Ce']['r2']):>8} | {g2(dm['R']['mape_pct']):>9} | {g2(dm['Ce']['mape_pct']):>9} | {g4(dm['Ce']['log_mae']):>10} | {g4(dm['T']['r2']):>8}")


# Evaluate the model #
def evaluate_model(model, loader, device, tree_depth_idx=None):
    model.eval()
    val_m = {k: 0.0 for k in ["loss", "R", "C_edge", "timing", "rho", "ctot_moe"]}
    P = {k: [] for k in ["rp", "rg", "cep", "ceg", "tp", "tg"]}
    dP = defaultdict(lambda: {k: [] for k in ["rp", "rg", "cep", "ceg", "tp", "tg"]})

    with torch.no_grad():
        for batch in loader:
            nf = batch["node_feats"].to(device); ef = batch["edge_feats"].to(device)
            ei = batch["edge_index"].to(device); ml = batch["metal_lens"].to(device)
            vc = batch["via_counts"].to(device); ct = batch["cell_type_idx"].to(device)
            gn = batch["graph_ids_node"].to(device); ge = batch["graph_ids_edge"].to(device)

            out = model(nf, ef, ei, ml, vc, ct, gn, ge, n_graphs=batch["n_graphs"])
            (R_pred, C_edge_pred, log_C_edge, R_eff, C_edge_eff, rho_R, rho_Cedge, _log_c_total) = out
            l, lr, lce, lt, lrho, lctdir = total_loss(batch, out, device, tree_depth_idx=tree_depth_idx)
            val_m["loss"] += l.item(); val_m["R"] += lr.item()
            val_m["C_edge"] += lce.item(); val_m["timing"] += lt.item(); val_m["rho"] += lrho.item()
            val_m["ctot_moe"] += lctdir.item()

            R_np = R_pred.cpu().numpy();     Rg = batch["R_gt"].numpy()
            Ce_np = C_edge_pred.cpu().numpy(); Ceg = batch["C_edge_gt"].numpy()
            keep = (Rg > 1.5e-3)    # drop placeholder edges from metrics #
            P["rp"].extend(R_np[keep]);   P["rg"].extend(Rg[keep])
            P["cep"].extend(Ce_np[keep]); P["ceg"].extend(Ceg[keep])

            gn_cpu = gn.cpu(); ge_cpu = ge.cpu()
            for lg, design in enumerate(batch["design_ids"]):
                em = (ge_cpu == lg).numpy() & keep
                dP[design]["rp"].extend(R_np[em]);   dP[design]["rg"].extend(Rg[em])
                dP[design]["cep"].extend(Ce_np[em]); dP[design]["ceg"].extend(Ceg[em])

            tm = batch["timing_mask"]; ptg = batch["pt_delay_gt"]
            if tm.any():
                cpl = batch["C_pin_liberty"].to(device)
                ep = compute_elmore(R_eff, cpl, C_edge_eff, ei, batch, device).cpu()
                valid = tm & (ptg > 0) & (ep > 0)
                if valid.any():
                    P["tp"].extend(ep[valid].numpy()); P["tg"].extend(ptg[valid].numpy())
                    for lg, design in enumerate(batch["design_ids"]):
                        nm = (gn_cpu == lg)
                        dv = nm & tm & (ptg > 0) & (ep > 0)
                        if dv.any():
                            dP[design]["tp"].extend(ep[dv].numpy())
                            dP[design]["tg"].extend(ptg[dv].numpy())

    n = len(loader)
    avg_v = {k: v / n for k, v in val_m.items()}
    per_design = {d: {"R": regression_metrics(x["rg"], x["rp"]),
                      "Ce": regression_metrics(x["ceg"], x["cep"]),
                      "T": regression_metrics(x["tg"], x["tp"])}
                  for d, x in dP.items()}

    def _med_lr(pred, gt):  # signed bias on val
        p = np.asarray(pred, np.float64); g = np.asarray(gt, np.float64)
        m = np.isfinite(p) & np.isfinite(g) & (p > 0) & (g > 0)
        return float(np.median(np.log(p[m]) - np.log(g[m]))) if m.any() else 0.0
    bias = {"R": _med_lr(P["rp"], P["rg"]),
            "Ce": _med_lr(P["cep"], P["ceg"]),
            "T": _med_lr(P["tp"], P["tg"])}

    return {
        "losses": avg_v,
        "R_metrics": regression_metrics(P["rg"], P["rp"]),
        "C_edge_metrics": regression_metrics(P["ceg"], P["cep"]),
        "T_metrics": regression_metrics(P["tg"], P["tp"]),
        "per_design": per_design,
        "bias": bias,
        "preds": P,
    }

# Return (graphs, meta, elmore_raw), built from the CSVs on every run #
def build_dataset():
    t0 = time.time()
    seg = pd.read_csv(SEG_CSV, low_memory=False)
    node = pd.read_csv(NODE_CSV, low_memory=False)
    print(f"INFO: Loaded edges and nodes [{time.time() - t0:.0f}s]", flush=True)

    
    t0 = time.time()
    graphs, meta = build_graphs(seg, node)
    del seg, node
    print(f"INFO: Built graphs [{time.time() - t0:.0f}s]", flush=True)
    if not graphs:
        return graphs, meta, []

    driver_feat_idx = meta["node_feat_cols"].index("is_driver_pin")
    t0 = time.time()
    elmore_raw = precompute_elmore_structures(graphs, driver_feat_idx)
    print(f"INFO: Precomputed Elmore [{time.time() - t0:.0f}s]", flush=True)

    return graphs, meta, elmore_raw

def main():
    t_all = time.time()

    graphs, meta, elmore_raw = build_dataset()
    if not graphs:
        raise RuntimeError("no graphs built")

    NODE_FEAT_COLS = meta["node_feat_cols"]
    EDGE_FEAT_COLS = meta["edge_feat_cols"]
    METAL_COLS = meta["metal_cols"]
    VIA_COLS = meta["via_cols"]
    CELL_VOCAB = meta["cell_vocab"]
    CELL_VOCAB_SIZE = meta["cell_vocab_size"]
    NODE_DIM = graphs[0]["node_feats"].shape[1]
    EDGE_DIM = graphs[0]["edge_feats"].shape[1]
    print(f"INFO: Nodes dimensions: {NODE_DIM}, Edges dimensions: {EDGE_DIM}, Number of metals: {len(METAL_COLS)}, Number of vias: {len(VIA_COLS)}, Cell vocab size: {CELL_VOCAB_SIZE}")

    for req in ("is_driver_pin", "is_pin"):
        if req not in NODE_FEAT_COLS:
            raise ValueError(f"Missing node feature '{req}'")
    driver_feat_idx = NODE_FEAT_COLS.index("is_driver_pin")
    tree_depth_idx = NODE_FEAT_COLS.index("tree_depth") if "tree_depth" in NODE_FEAT_COLS else None

    for g in graphs:
        g["design_id"] = g["net_name"].split("/")[0].rsplit("_", 3)[0]

    # split by whole P&R run #
    run_to_idx = defaultdict(list)
    for i, g in enumerate(graphs):
        run_to_idx[g["net_name"].split("/")[0]].append(i)
    run_ids = sorted(run_to_idx)
    if VAL_RUNS:
        val_runs = {r for r in run_ids if r in VAL_RUNS}
        if not val_runs:
            raise ValueError(
                f"None of the validation runs in VAL_RUNS were found in the dataset.\n"
                f"  VAL_RUNS:      {sorted(VAL_RUNS)}\n"
                f"  Runs in data:  {run_ids}\n")
    else:
        rng = np.random.RandomState(SPLIT_SEED); rng.shuffle(run_ids)
        val_runs = {run_ids[0]}
    train_runs = [r for r in run_ids if r not in val_runs]
    train_idx = [i for r in train_runs for i in run_to_idx[r]]
    val_idx = [i for r in val_runs for i in run_to_idx[r]]
    train_graphs = [graphs[i] for i in train_idx]
    val_graphs = [graphs[i] for i in val_idx]
    
    tr_es = ElmoreStructs([elmore_raw[i] for i in train_idx], len(train_idx))
    va_es = ElmoreStructs([elmore_raw[i] for i in val_idx],   len(val_idx))
    del graphs, elmore_raw
    
    print(f"INFO: Dataset split: {len(train_graphs):,} train nets, {len(val_graphs):,} val nets")
    
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    pin = device.type == "cuda"
    print(f"Device: {device}")

    train_loader = DataLoader(GraphDataset(train_graphs, tr_es), batch_size=BATCH_SIZE,
                              shuffle=True, collate_fn=collate_graphs, pin_memory=pin,
                              num_workers=4, persistent_workers=True, prefetch_factor=4)
    val_loader = DataLoader(GraphDataset(val_graphs, va_es), batch_size=BATCH_SIZE,
                            shuffle=False, collate_fn=collate_graphs, pin_memory=pin,
                            num_workers=2, persistent_workers=True)

    model = Bypass(NODE_DIM, EDGE_DIM, len(METAL_COLS), len(VIA_COLS),
                        CELL_VOCAB_SIZE).to(device)

    param_groups = [
        {"params": [model.r_L, model.r_via],           "lr": LR_PHYSICS},
        {"params": model.cell_embedding.parameters(),  "lr": LR_MLP},
        {"params": model.node_encoder.parameters(),    "lr": LR_MLP},
        {"params": model.edge_encoder.parameters(),    "lr": LR_MLP},
        {"params": model.mp_rounds.parameters(),       "lr": LR_MLP},
        {"params": model.delta_r_head.parameters(),    "lr": LR_MLP / 10},
        {"params": model.c_edge_head.parameters(),     "lr": LR_MLP},
        {"params": model.rho_r_head.parameters(),      "lr": LR_MLP / 10},
        {"params": model.rho_cedge_head.parameters(),  "lr": LR_MLP / 10},
        {"params": model.ctotal_moe.parameters(),      "lr": LR_MLP},
    ]
    optimizer = torch.optim.Adam(param_groups, weight_decay=WEIGHT_DECAY)
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode="min",
                                                           factor=0.5, patience=20)

    warm_start(model, METAL_COLS, VIA_COLS)

    # ctotal_moe warm start: bias each expert's output to the mean log(C_total) #
    # over real training nets, so the MoE starts near the right scale           #
    _logs = []
    for _i, _b in enumerate(train_loader):
        _m = _b["R_gt"] > 1.5e-3
        _ge = _b["graph_ids_edge"]
        _nb = int(_ge.max().item()) + 1 if _ge.numel() else 0
        if _nb:
            _sg = torch.zeros(_nb).scatter_add_(0, _ge[_m], _b["C_edge_gt"][_m])
            _v = _sg > 0
            if _v.any():
                _logs.append(torch.log(_sg[_v] + 1e-12))
        if _i >= 30:
            break
    _log_c_total_mean = float(torch.cat(_logs).mean()) if _logs else -9.0
    for _expert in model.ctotal_moe.experts:
        nn.init.zeros_(_expert.fc4.weight)
        nn.init.constant_(_expert.fc4.bias, _log_c_total_mean)
    print(f"INFO: C_total MoE warm start: log_C_total bias = {_log_c_total_mean:.3f}  "
          f"(C_total ~= {np.exp(_log_c_total_mean):.4g} pF)")

    best = float("inf")
    no_improve = 0
    history = []

    def _checkpoint(epoch):
        return {
            "model_state": model.state_dict(),
            "epoch": epoch,
            "node_dim": NODE_DIM, "edge_dim": EDGE_DIM,
            "node_feat_cols": NODE_FEAT_COLS, "edge_feat_cols": EDGE_FEAT_COLS,
            "metal_cols": METAL_COLS, "via_cols": VIA_COLS,
            "cell_vocab": CELL_VOCAB, "cell_vocab_size": CELL_VOCAB_SIZE,
            "driver_feat_idx": driver_feat_idx,
            "val_runs": sorted(val_runs),
            "mp_rounds": MP_ROUNDS,
        }

    n_train_batches = len(train_loader)
    for epoch in range(1, EPOCHS + 1):
        t0 = time.time()
        model.train()
        train_loss = 0.0
        optimizer.zero_grad()
        for step, batch in enumerate(train_loader):
            if step % 200 == 0:
                el = time.time() - t0
                rate = (step + 1) / el if el > 0 else 0.0
                eta = (n_train_batches - step - 1) / rate if rate > 0 else float("nan")
                print(f"    [train] step {step:5d}/{n_train_batches}  "
                      f"{el:7.1f}s elapsed  {rate:5.2f} it/s  ETA {eta:7.1f}s", flush=True)
            nf = batch["node_feats"].to(device, non_blocking=True)
            ef = batch["edge_feats"].to(device, non_blocking=True)
            ei = batch["edge_index"].to(device, non_blocking=True)
            ml = batch["metal_lens"].to(device, non_blocking=True)
            vc = batch["via_counts"].to(device, non_blocking=True)
            ct = batch["cell_type_idx"].to(device, non_blocking=True)
            gn = batch["graph_ids_node"].to(device, non_blocking=True)
            ge = batch["graph_ids_edge"].to(device, non_blocking=True)

            out = model(nf, ef, ei, ml, vc, ct, gn, ge, n_graphs=batch["n_graphs"])
            loss, *_ = total_loss(batch, out, device, tree_depth_idx=tree_depth_idx)
            if not torch.isfinite(loss):
                raise RuntimeError(f"non-finite loss epoch {epoch} step {step}")
            (loss / GRAD_ACCUM_STEPS).backward()
            train_loss += loss.item()
            if (step + 1) % GRAD_ACCUM_STEPS == 0 or (step + 1) == len(train_loader):
                torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
                optimizer.step()
                optimizer.zero_grad()
                with torch.no_grad():
                    model.r_L.clamp_(min=R_L_FLOOR)
                    model.r_via.clamp_(min=R_L_FLOOR)

        eo = evaluate_model(model, val_loader, device, tree_depth_idx=tree_depth_idx)
        avg_v = eo["losses"]; Rm = eo["R_metrics"]; Cem = eo["C_edge_metrics"]; Tm = eo["T_metrics"]
        avg_t = train_loss / max(len(train_loader), 1)
        comp = composite_val_score(Rm, Cem, Tm, eo["bias"])
        scheduler.step(comp)

        if comp < best:
            best, no_improve, status = comp, 0, "*"
            torch.save(_checkpoint(epoch), OUTPUT_DIR / "bypass.pt")
            save_best_plots(eo["preds"]["rp"], eo["preds"]["rg"], eo["preds"]["cep"], eo["preds"]["ceg"], eo["preds"]["tp"], eo["preds"]["tg"], epoch, OUTPUT_DIR / f"best_epoch_{epoch}.png")
            save_best_metrics(epoch, avg_v, Rm, Cem, Tm, OUTPUT_DIR / "best_model_metrics")
        else:
            no_improve += 1
            status = f"no imp {no_improve}"

        torch.save(_checkpoint(epoch), OUTPUT_DIR / "bypass_latest.pt")

        print_epoch_stats(epoch, avg_t, avg_v, Rm, Cem, Tm, model, status, time.time() - t0, per_design=eo["per_design"], bias=eo["bias"])
        history.append({
            "epoch": epoch, "train_loss": avg_t, "val_loss": avg_v["loss"],
            "val_R": avg_v["R"], "val_C_edge": avg_v["C_edge"], "val_timing": avg_v["timing"],
            "val_ctot_moe": avg_v["ctot_moe"],
            "R_r2": Rm["r2"], "R_logmae": Rm["log_mae"], "bias_R": eo["bias"]["R"],
            "Ce_r2": Cem["r2"], "Ce_logmae": Cem["log_mae"], "bias_Ce": eo["bias"]["Ce"],
            "T_r2": Tm["r2"], "T_logmae": Tm["log_mae"], "bias_T": eo["bias"]["T"],
            "composite": comp,
        })
        pd.DataFrame(history).to_csv(OUTPUT_DIR / "training_history.csv", index=False)

        if no_improve >= PATIENCE:
            print("\nEarly stopping.")
            break

    print(f"\nDone in {(time.time() - t_all) / 60:.1f} min   best composite {best:.6f}")


if __name__ == "__main__":
    main()
