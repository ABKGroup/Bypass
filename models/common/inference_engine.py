import gc
import os
import sys
import time
from collections import defaultdict
from pathlib import Path

import numpy as np
import pandas as pd
import torch
from torch.utils.data import DataLoader

_HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(_HERE))

import graph_builder as GB
import spef_writer_ports as SPEFW   

INTERNAL_TOKEN = "INTERNAL"
BATCH_SIZE = 256
PLACEHOLDER_R = 1.5e-3
_ALL = {}      # the full test CSVs, read once and sliced per design


def _env_path(name):
    v = os.environ.get(name)
    if not v:
        sys.exit(f"ERROR: environment variable {name} is not set")
    return Path(v)

class Config:
    def __init__(self, default_out):
        self.model_ckpt = _env_path("MODEL_CKPT")
        self.test_seg = _env_path("TEST_SEG")
        self.test_node = _env_path("TEST_NODE")
        self.pairs_base = Path(os.environ.get("PAIRS_BASE", ""))
        self.out = Path(os.environ.get("PRED_OUT", str(default_out)))
        self.designs = [d.strip() for d in os.environ.get("EVAL_DESIGNS", "").split(",") if d.strip()]
        self.skip_done = os.environ.get("SKIP_DONE", "1") == "1"


def load_checkpoint_meta(cfg):
    ck = torch.load(cfg.model_ckpt, map_location="cpu")
    return ck

# Build the test graphs for a list of designs. Returns the graphs, precomputed Elmore structures, # 
# graph metadata, node metadata, and a dict of node residual capacitances by net.                 #
def build_test(cfg, source, ck, designs):
    NF, EF = ck["node_feat_cols"], ck["edge_feat_cols"]
    MC, VC = ck["metal_cols"], ck["via_cols"]
    CV, drv = ck["cell_vocab"], ck["driver_feat_idx"]

    if "seg" not in _ALL:
        _ALL["seg"] = pd.read_csv(cfg.test_seg, low_memory=False)
        _ALL["node"] = pd.read_csv(cfg.test_node, low_memory=False)
        _ALL["seg_d"] = _ALL["seg"]["net_key"].str.split("/").str[0]
        _ALL["node_d"] = _ALL["node"]["net_key"].str.split("/").str[0]
    seg = _ALL["seg"][_ALL["seg_d"].isin(designs)].reset_index(drop=True)
    node = _ALL["node"][_ALL["node_d"].isin(designs)].reset_index(drop=True)
    print(f"INFO: Test features: {len(seg):,} segments, {len(node):,} nodes")

    # No labels exist. graph_builder.process_net() DROPS every net whose R_gt has a value <= 0 (a ground-truth
    # sanity check), so R_ohms must be a positive DUMMY here, not zero. The dummy is never used as a label or a feature.
    if "R_ohms" not in seg.columns: seg["R_ohms"] = 1.0
    if "C_edge_pf" not in seg.columns: seg["C_edge_pf"] = 0.0
    for c in ("C_node_pf", "elmore_gt_ps", "C_pin_liberty_pf"):
        if c not in node.columns: node[c] = 0.0
    if "has_elmore" not in node.columns: node["has_elmore"] = False
    for c in EF + MC + VC:
        if c not in seg.columns: seg[c] = 0.0
    for c in NF:
        if c not in node.columns: node[c] = 0.0
    node["cell_base_type"] = node["cell_base_type"].fillna(INTERNAL_TOKEN)
    node["cell_strength"] = node["cell_strength"].fillna(0)
    node = node.fillna(0)
    node["cell_base_type"] = node["cell_base_type"].replace(0, INTERNAL_TOKEN)
    has_lib = "C_pin_liberty_pf" in node.columns

    cnode = pd.to_numeric(node["C_node_pf"], errors="coerce").fillna(0.0).to_numpy(np.float64)
    ng = node.groupby("net_key").indices
    node_residual_by_net = {nk: cnode[i] for nk, i in ng.items()}

    source.setup(seg, dict(metal_cols=MC, via_cols=VC, ckpt=ck))

    graphs = GB.build_graph_list_parallel(seg, node, EF, NF, MC, VC, CV, has_lib, n_workers=8)
    es = GB.precompute_elmore_structures(graphs, drv, n_workers=8)
    gmeta = {g["net_name"]: (g["node_ids"], g["endpoint_1"], g["endpoint_2"]) for g in graphs}

    # SPEF pin metadata #
    node_meta = {}
    for row in node.itertuples(index=False):
        nid = str(row.node_id_def)
        if "/" not in nid and ":" not in nid:
            continue
        node_meta[nid] = {
            "is_driver_pin": int(getattr(row, "is_driver_pin", 0)),
            "cell_type": GB._build_cell_type(str(getattr(row, "cell_base_type", "UNKNOWN")),
                                              getattr(row, "cell_strength", 0)),
            "x": float(getattr(row, "coord_x", 0.0)), "y": float(getattr(row, "coord_y", 0.0)),
        }
    return graphs, es, gmeta, node_meta, node_residual_by_net

# Run inference for a single design. Builds the test graphs, runs the model, computes Elmore delays, # 
# and writes SPEF and prediction CSVs. Re
def run_design(cfg, source, ck, design):
    t0 = time.time()
    out = cfg.out
    name = source.name
    (out / "predictions" / name).mkdir(parents=True, exist_ok=True)
    print("INFO: Building test graphs")
    graphs, es, gmeta, node_meta, node_residual_by_net = build_test(cfg, source, ck, [design])

    idx = [i for i, g in enumerate(graphs) if g["net_name"].split("/")[0] == design]
    if not idx:
        raise RuntimeError("no graphs were built for this design (every net skipped) - check the input CSVs")

    spef_edge = defaultdict(list)   # net, ep1, ep2, Ce, R #
    spef_node = defaultdict(list)   # net, node_id, C_node #
    el_all = defaultdict(list)   # net, node_id, predicted internal Elmore (ps) #
    ctot_rows = []                  # net, C_total #

    loader = DataLoader(GB.InferDataset([graphs[i] for i in idx], [es[i] for i in idx]), batch_size=BATCH_SIZE, shuffle=False, collate_fn=GB.collate_graphs, num_workers=0)
    n_batches = len(loader)
    infer_seconds = 0.0
    print(f"INFO: Running {name} on {design}")
    for bi, batch in enumerate(loader):
        ge = batch["graph_ids_edge"].numpy()
        gn = batch["graph_ids_node"].numpy()
        cpin = batch["C_pin_liberty"].numpy().astype(np.float64)
        Rgt = batch["R_gt"].numpy().astype(np.float64)

        Cn = np.zeros(len(gn), np.float64)
        for lg, net in enumerate(batch["net_names"]):
            nb = node_residual_by_net.get(net)
            if nb is not None:
                nm_ = np.where(gn == lg)[0]
                Cn[nm_] = nb[:len(nm_)]

        t_inf = time.time()
        R, Ce = source.edge_rc(batch)
        infer_seconds += time.time() - t_inf
        ph = (Rgt > 0) & (Rgt <= PLACEHOLDER_R)
        R[ph] = 0.001
        Ce[ph] = 0.0

        el = GB.compute_elmore(
            torch.from_numpy(R), torch.from_numpy(Cn + cpin), torch.from_numpy(Ce),
            batch["edge_index"], batch, torch.device("cpu")).numpy()

        ei_np = batch["edge_index"].numpy()
        for lg, net in enumerate(batch["net_names"]):
            d = net.split("/")[0]
            nidl, ep1l, ep2l = gmeta[net]
            em = np.where(ge == lg)[0]; nm = np.where(gn == lg)[0]
            ctot_rows.append((net, float(Ce[em].sum() + Cn[nm].sum())))
            g2l = {int(g): j for j, g in enumerate(nm)}

            def _endp(g_idx, k, fallback):
                j = g2l.get(int(g_idx))
                if j is not None and j < len(nidl):
                    return nidl[j]
                return fallback[k] if k < len(fallback) else f"n{k}"
            for k, i in enumerate(em):
                spef_edge[d].append((net, _endp(ei_np[0, i], k, ep1l), _endp(ei_np[1, i], k, ep2l),
                                     float(Ce[i]), float(R[i])))
            for k, i in enumerate(nm):
                nid = nidl[k] if k < len(nidl) else f"node_{k}"
                el_all[d].append((net, nid, float(el[i])))
                spef_node[d].append((net, nid, float(Cn[i])))
        if (bi + 1) % 50 == 0:
            print(f"INFO: [{design}] batch {bi + 1}/{n_batches}", flush=True)

    print(f"INFO: [{design}] {name} inference: {n_batches} batches, {len(idx):,} nets "
          f"[{infer_seconds:.2f}s, {1000 * infer_seconds / len(idx):.2f} ms/net]", flush=True)
    pd.DataFrame([dict(design=design, n_nets=len(idx), n_batches=n_batches, inference_seconds=infer_seconds)]).to_csv(
        out / f"{name}_inference_timing_{design}.csv", index=False)

    t_spef0 = time.time()
    base = GB._design_base(design)
    dd = out / "spef_src" / name / design
    dd.mkdir(parents=True, exist_ok=True)
    edf = pd.DataFrame(spef_edge[design], columns=["net_name", "endpoint_1", "endpoint_2", "C_edge_eff_pf", "R_eff_ohm"])
    ndf = pd.DataFrame(spef_node[design], columns=["net_name", "node_id", "C_node_eff_pf"])
    ndf["is_driver_pin"] = [node_meta.get(x, {}).get("is_driver_pin", 0) for x in ndf["node_id"]]
    ndf["cell_type"] = [node_meta.get(x, {}).get("cell_type", "UNKNOWN") for x in ndf["node_id"]]
    ndf["x_um"] = [node_meta.get(x, {}).get("x", 0.0) for x in ndf["node_id"]]
    ndf["y_um"] = [node_meta.get(x, {}).get("y", 0.0) for x in ndf["node_id"]]
    def_ports = {}
    cand = sorted(cfg.pairs_base.glob(f"{design}/*.def")) if str(cfg.pairs_base) != "." else []
    if cand:
        try:
            def_ports = GB.parse_def_ports(str(cand[0]))
        except Exception:             
            pass
    SPEFW.write_spef_ports(ndf, edf, dd / f"{base}.spef", base, def_ports=def_ports)
    edf.rename(columns={"R_eff_ohm": "R_ohm", "C_edge_eff_pf": "C_edge_pf"}).to_csv(
        out / "predictions" / name / f"{design}_edges.csv", index=False)
    ndf[["net_name", "node_id", "C_node_eff_pf"]].rename(columns={"C_node_eff_pf": "C_node_pf"}).to_csv(
        out / "predictions" / name / f"{design}_nodes.csv", index=False)
    pd.DataFrame(ctot_rows, columns=["net_key", "C_total_pf_pred"]).to_csv(
        out / "predictions" / name / f"{design}_net_ctot.csv", index=False)
    # the Elmore file is written last: main() treats it as the "design complete" marker
    pd.DataFrame(el_all[design], columns=["net_key", "node_id", "elmore_pred_ps"]).to_csv(
        out / "predictions" / name / f"{design}_elmore.csv", index=False)
    print(f"INFO: [{design}] wrote SPEF and predictions [{time.time() - t_spef0:.1f}s]")
    print(f"INFO: Done in {(time.time() - t0) / 60:.1f} min")
    print(f"  predicted SPEF : {dd / (base + '.spef')}")
    print(f"  per-edge R/C   : {out / 'predictions' / name / (design + '_edges.csv')}")


def main(source, default_out):
    cfg = Config(default_out)
    ck = load_checkpoint_meta(cfg)
    designs = cfg.designs
    if not designs:
        designs = sorted(pd.read_csv(cfg.test_seg, usecols=["net_key"])["net_key"].str.split("/").str[0].unique())
    done, failed = [], []
    for k, d in enumerate(designs, 1):
        marker = cfg.out / "predictions" / source.name / f"{d}_elmore.csv"  
        if cfg.skip_done and marker.exists():
            print(f"\n##### [{k}/{len(designs)}] {d}: predictions exist, skipping (SKIP_DONE=0 to redo)")
            done.append(d); continue
        print(f"\n##### [{k}/{len(designs)}] {d}")
        try:
            run_design(cfg, source, ck, d)
            done.append(d)
        except Exception:                       
            import traceback; traceback.print_exc()
            failed.append(d)
        gc.collect()
    print(f"\nINFO: Finished: {len(done)}/{len(designs)} designs OK" + (f"  FAILED: {failed}" if failed else ""))
    if failed:
        sys.exit(1)
