#!/usr/bin/env python3
"""
fold_node_capacitance.py  --  "Option 1" dataset builder.

The processed CSVs are ALREADY the collapsed representation (degree-2 SPEF RC
nodes folded into edges; only pins + Steiner points survive as nodes).  This
script does the extra "Option 1" step:

    for every surviving node v:
        share = C_node_pf[v] / (# collapsed edges incident to v)
        add `share` onto C_edge_pf of each incident edge
        set C_node_pf[v] -> 0

After this, the only capacitance left on a node is the Liberty gate cap
(C_pin_liberty_pf), which the model/Elmore code already handles separately.
Total net capacitance is preserved exactly (equal-by-degree split).

Inputs  (full, multi-design):
    scripts/processed/processed_segments.csv          (~19 GB)
    train/annotated_nodes_with_elmore.csv                (~16 GB)

Outputs (in --out-dir, default ./):
    collapsed_segments.csv   every original seg column; C_edge_pf overwritten,
                             C_edge_pf_orig added
    collapsed_nodes.csv      every original node column; C_node_pf zeroed
                             (except deg-0 residual), C_node_pf_orig added
    run_summary.json            runs used, row counts, conservation + resolution stats

Only the 5 P&R runs in RUNS are kept.  A "run" is the substring of net_key
before the first '/'  (the `design` column in the CSV is corrupted and is NOT
used for filtering).
"""

import argparse
import json
import time
from collections import Counter, defaultdict
from pathlib import Path

import numpy as np
import pandas as pd


# 5 P&R runs, spread across base designs.  A missing run is auto-swapped for a
# sibling corner of the same family (warned loudly in the run summary).
RUNS = [
    "aes_cipher_top_10_0.7_1.2",
    "ibex_core_10_0.7_1.2",
    "jpeg_encoder_10_0.7_1.2",
    "aes_cipher_top_0.8_0.6_1.0",
    "jpeg_encoder_0.8_0.8_1.0",
]

CHUNK = 500_000

# columns we do arithmetic on -- force numeric after the (chunked) read
SEG_NUMERIC = ["C_edge_pf", "R_ohms", "total_len_um",
                "coord_x1", "coord_y1", "coord_x2", "coord_y2"]
NODE_NUMERIC = ["C_node_pf", "C_pin_liberty_pf", "coord_x", "coord_y",
                "local_node_idx", "elmore_gt_ps", "has_elmore"]


def normalize_escaping(s):
    if not isinstance(s, str):
        return s
    return s.replace("\\\\", "\\")


def run_of(net_key):
    return str(net_key).split("/", 1)[0]


def family_stem(run):
    """`ibex_core_10_0.7_1.2` -> `ibex_core_10`  (drop the 3 trailing _<param>)."""
    parts = str(run).rsplit("_", 3)
    return parts[0] if len(parts) == 4 else str(run)


def filter_csv(path, runs_set, label):
    """Single streaming pass: keep rows whose run is in `runs_set`, and build a
    histogram of every run seen (so we can report / auto-substitute)."""
    print(f"INFO: {label}: reading {path} ({path.stat().st_size / 1e9:.1f} GB), keeping the requested runs", flush=True)
    hist = Counter()
    kept = []
    t0 = time.time()
    n_rows = 0
    for ci, chunk in enumerate(pd.read_csv(path, chunksize=CHUNK, low_memory=False)):
        n_rows += len(chunk)
        runs = chunk["net_key"].map(run_of)
        hist.update(runs.value_counts().to_dict())
        m = runs.isin(runs_set)
        if m.any():
            kept.append(chunk.loc[m].copy())
        if (ci + 1) % 10 == 0:
            print(f"INFO: {label}: {n_rows:,} rows scanned in {time.time() - t0:.0f}s, "
                  f"{sum(len(k) for k in kept):,} kept so far", flush=True)
    df = (pd.concat(kept, ignore_index=True) if kept
          else pd.DataFrame(columns=chunk.columns))
    print(f"INFO: {label}: {n_rows:,} rows scanned, {len(df):,} kept, "
          f"{len(hist):,} distinct runs ({time.time() - t0:.0f}s)", flush=True)
    return df, hist


def resolve_runs(requested, seg_hist, node_hist):
    """Return (final_runs, substitutions).  Fail loudly if a family is absent."""
    seg_ok = {r for r, c in seg_hist.items()  if c > 0}
    node_ok = {r for r, c in node_hist.items() if c > 0}
    both_ok = seg_ok & node_ok

    final, subs = [], {}
    for r in requested:
        if r in both_ok:
            final.append(r)
            continue
        stem = family_stem(r)
        cands = sorted(
            (x for x in both_ok if family_stem(x) == stem),
            key=lambda x: -(min(seg_hist[x], node_hist[x])),
        )
        if cands:
            subs[r] = cands[0]
            final.append(cands[0])
            print(f"WARNING: run '{r}' not present in both CSVs, substituting "
                  f"sibling '{cands[0]}'", flush=True)
        else:
            avail = sorted(both_ok)
            raise SystemExit(
                f"[FATAL] run '{r}' absent and no sibling of family '{stem}' "
                f"found in both CSVs.\nRuns available in BOTH CSVs:\n  "
                + "\n  ".join(avail)
            )
    if len(set(final)) != len(final):
        raise SystemExit(f"[FATAL] duplicate runs after substitution: {final}")
    return final, subs


def _xy(x, y):
    """Integer DBU coordinate key, or None if missing."""
    try:
        if x is None or y is None or (x != x) or (y != y):   # NaN
            return None
        return (int(round(float(x))), int(round(float(y))))
    except (TypeError, ValueError):
        return None


def fold_net(ep1, ep2, ep1_xy, ep2_xy, c_edge,
             node_names, node_xy, c_node):
    """Equal-by-degree redistribution for one net.

    ep1, ep2         : (E,) object arrays of edge endpoint names
    ep1_xy, ep2_xy   : (E,) lists of (x, y) int tuples or None  (endpoint coords)
    c_edge           : (E,) float, original C_edge_pf
    node_names       : (N,) object array of node_id_def
    node_xy          : (N,) list of (x, y) int tuples or None    (node coords)
    c_node           : (N,) float, original C_node_pf

    Endpoints are resolved to node rows by exact node_id_def first, then by
    coordinate (handles `Steiner(x, y)` labels that never match by name).

    Returns (new_c_edge (E,), new_c_node (N,), stats dict).
    """
    E = len(c_edge)
    N = len(c_node)

    pos_by_name = {}
    for i, nm in enumerate(node_names):
        pos_by_name.setdefault(nm, i)          # keep first on dup
    pos_by_xy = defaultdict(list)
    for i, xy in enumerate(node_xy):
        if xy is not None:
            pos_by_xy[xy].append(i)

    n_by_name = 0
    n_by_coord = 0
    n_multi_coord = 0
    n_unresolved = 0

    # Row index of a node for an edge end point. First by name, then by coordinates. -1 if it cannot be found. #
    def resolve(nm, xy):
        nonlocal n_by_name, n_by_coord, n_multi_coord, n_unresolved
        i = pos_by_name.get(nm)
        if i is not None:
            n_by_name += 1
            return i
        if xy is not None:
            lst = pos_by_xy.get(xy)
            if lst:
                if len(lst) > 1:
                    n_multi_coord += 1
                n_by_coord += 1
                return lst[0]
        n_unresolved += 1
        return -1

    incident = defaultdict(list)               # node row idx -> list of edge positions
    for e in range(E):
        a = resolve(ep1[e], ep1_xy[e])
        b = resolve(ep2[e], ep2_xy[e])
        if a >= 0:
            incident[a].append(e)
        if b >= 0:
            incident[b].append(e)

    new_c_edge = np.array(c_edge, dtype=np.float64, copy=True)
    new_c_node = np.array(c_node, dtype=np.float64, copy=True)
    new_c_edge[~np.isfinite(new_c_edge)] = 0.0

    folded_total = 0.0
    residual_total = 0.0
    n_deg0 = 0
    n_folded_nodes = 0

    for i in range(N):
        c = new_c_node[i]
        if not np.isfinite(c):
            new_c_node[i] = 0.0
            continue
        if c == 0.0:
            continue
        lst = incident.get(i)
        if not lst:                            # node carries cap but has no collapsed edge
            n_deg0 += 1
            residual_total += c
            continue                           # keep c on the node
        share = c / len(lst)
        for e in lst:
            new_c_edge[e] += share
        new_c_node[i] = 0.0
        folded_total += c
        n_folded_nodes += 1

    orig_edge_sum = float(np.nansum(np.array(c_edge, dtype=np.float64)))
    new_edge_sum = float(new_c_edge.sum())
    cons_err = abs(new_edge_sum - (orig_edge_sum + folded_total))

    stats = dict(
        n_edges=E, n_nodes=N,
        n_folded_nodes=n_folded_nodes, n_deg0_nodes=n_deg0,
        n_endpoints_by_name=n_by_name, n_endpoints_by_coord=n_by_coord,
        n_endpoints_unresolved=n_unresolved, n_multi_coord=n_multi_coord,
        folded_pf=folded_total, residual_pf=residual_total,
        orig_edge_sum_pf=orig_edge_sum, new_edge_sum_pf=new_edge_sum,
        conservation_abs_err_pf=cons_err,
    )
    return new_c_edge.astype(np.float64), new_c_node.astype(np.float64), stats


# Fold the node capacitance onto the edges for the selected runs. Reads the (large) segment and node CSV in chunks and keeps only #
# the requested runs, then redistributes the capacitance net by net (fold_net) and writes collapsed_segments.csv,                 #
# collapsed_nodes.csv and run_summary.json. The original capacitances stay in C_edge_pf_orig and C_node_pf_orig.                  #
# With --from-filtered the filtered tables of a previous run are reloaded and only the fold is repeated.                          #
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seg-csv",  type=Path, required=True, help="segment CSV (processed_segments_scaled.csv)")
    ap.add_argument("--node-csv", type=Path, required=True, help="node CSV (annotated_nodes_with_elmore_scaled.csv)")
    ap.add_argument("--out-dir",  type=Path, required=True, help="output folder")
    ap.add_argument("--runs", nargs="*", default=None,
                    help="override the 5 P&R runs (net_key prefixes)")
    ap.add_argument("--from-filtered", action="store_true",
                    help="skip the 37 GB streaming pass: reload the already-filtered "
                         "collapsed_*.csv in --out-dir, restore raw C from the *_orig "
                         "columns, and just re-run the fold")
    args = ap.parse_args()

    # Runs to keep: --runs, else the list at the top of this file #
    requested = args.runs if args.runs else RUNS
    args.out_dir.mkdir(parents=True, exist_ok=True)
    t_start = time.time()

    # Either reload the filtered tables of a previous run, or stream the large CSVs and keep the requested runs #
    if args.from_filtered:
        seg_out_p = args.out_dir / "collapsed_segments.csv"
        node_out_p = args.out_dir / "collapsed_nodes.csv"
        print(f"INFO: Reloading {seg_out_p} and {node_out_p}", flush=True)
        seg_df = pd.read_csv(seg_out_p,  low_memory=False)
        node_df = pd.read_csv(node_out_p, low_memory=False)
        if "C_edge_pf_orig" in seg_df.columns:
            seg_df["C_edge_pf"] = seg_df.pop("C_edge_pf_orig")
        if "C_node_pf_orig" in node_df.columns:
            node_df["C_node_pf"] = node_df.pop("C_node_pf_orig")
        final_runs = sorted(seg_df["net_key"].map(run_of).unique())
        subs = {}
        print(f"INFO: Runs: {final_runs}")
    else:
        seg_df,  seg_hist = filter_csv(args.seg_csv,  set(requested), "seg")
        node_df, node_hist = filter_csv(args.node_csv, set(requested), "node")

        print("INFO: Runs present in both CSVs (top 40 by segment rows):")
        for r, c in sorted(((r, seg_hist[r]) for r in (set(seg_hist) & set(node_hist))),
                           key=lambda x: -x[1])[:40]:
            print(f"  {r:<40} seg={c:>9,}  node={node_hist[r]:>9,}")

        final_runs, subs = resolve_runs(requested, seg_hist, node_hist)
        if subs:
            keep = set(final_runs)
            seg_df = seg_df[seg_df["net_key"].map(run_of).isin(keep)].copy()
            node_df = node_df[node_df["net_key"].map(run_of).isin(keep)].copy()
        print(f"INFO: Final runs: {final_runs}")
        if subs:
            print(f"INFO: Substitutions: {subs}")

    # Normalise the names and coerce the numeric columns #
    for col in ("endpoint_1", "endpoint_2"):
        seg_df[col] = seg_df[col].map(normalize_escaping)
    node_df["node_id_def"] = node_df["node_id_def"].map(normalize_escaping)

    for c in SEG_NUMERIC:
        if c in seg_df.columns:
            seg_df[c] = pd.to_numeric(seg_df[c], errors="coerce")
    for c in NODE_NUMERIC:
        if c in node_df.columns:
            node_df[c] = pd.to_numeric(node_df[c], errors="coerce")
    seg_df["C_edge_pf"] = seg_df["C_edge_pf"].fillna(0.0)
    node_df["C_node_pf"] = node_df["C_node_pf"].fillna(0.0)

    seg_df = seg_df.sort_values("net_key").reset_index(drop=True)
    node_df = node_df.sort_values("net_key").reset_index(drop=True)

    # Per-net redistribution #
    seg_new = seg_df["C_edge_pf"].to_numpy(dtype=np.float64).copy()
    node_new = node_df["C_node_pf"].to_numpy(dtype=np.float64).copy()

    seg_groups = seg_df.groupby("net_key").indices      # name -> positional idx array
    node_groups = node_df.groupby("net_key").indices

    ep1_all = seg_df["endpoint_1"].to_numpy(dtype=object)
    ep2_all = seg_df["endpoint_2"].to_numpy(dtype=object)
    ndef_all = node_df["node_id_def"].to_numpy(dtype=object)

    # endpoint / node coordinate keys (used to resolve `Steiner(x, y)` labels
    # that never match node_id_def by name)
    # Coordinates (x, y) of every row as an integer tuple, or None if the coordinates are missing. #
    def xy_array(df, xcol, ycol):
        xs = df[xcol].to_numpy() if xcol in df.columns else np.full(len(df), np.nan)
        ys = df[ycol].to_numpy() if ycol in df.columns else np.full(len(df), np.nan)
        vals = [_xy(x, y) for x, y in zip(xs, ys)]
        out = np.empty(len(vals), dtype=object)   # keep tuples as scalar elements
        out[:] = vals
        return out

    ep1_xy_all = xy_array(seg_df, "coord_x1", "coord_y1")
    ep2_xy_all = xy_array(seg_df, "coord_x2", "coord_y2")
    node_xy_all = xy_array(node_df, "coord_x", "coord_y")

    # Fold the node capacitance of every net onto its edges #
    agg = Counter()
    per_net = {}
    n_nets = 0
    n_nets_no_nodes = 0
    worst_cons = 0.0

    for nk, s_idx in seg_groups.items():
        n_idx = node_groups.get(nk)
        if n_idx is None or len(n_idx) == 0:
            n_nets_no_nodes += 1
            continue
        new_ce, new_cn, st = fold_net(
            ep1_all[s_idx], ep2_all[s_idx],
            ep1_xy_all[s_idx], ep2_xy_all[s_idx],
            seg_new[s_idx],
            ndef_all[n_idx], node_xy_all[n_idx], node_new[n_idx],
        )
        seg_new[s_idx] = new_ce
        node_new[n_idx] = new_cn
        n_nets += 1
        for k in ("n_edges", "n_nodes", "n_folded_nodes", "n_deg0_nodes",
                  "n_endpoints_by_name", "n_endpoints_by_coord",
                  "n_endpoints_unresolved", "n_multi_coord"):
            agg[k] += st[k]
        for k in ("folded_pf", "residual_pf"):
            agg[k] += st[k]
        worst_cons = max(worst_cons, st["conservation_abs_err_pf"])
        per_net[nk] = st

    # Write the outputs #
    seg_df["C_edge_pf_orig"] = seg_df["C_edge_pf"]
    seg_df["C_edge_pf"] = seg_new
    node_df["C_node_pf_orig"] = node_df["C_node_pf"]
    node_df["C_node_pf"] = node_new

    seg_out = args.out_dir / "collapsed_segments.csv"
    node_out = args.out_dir / "collapsed_nodes.csv"
    seg_df.to_csv(seg_out,  index=False)
    node_df.to_csv(node_out, index=False)

    total_orig = float(np.nansum(seg_df["C_edge_pf_orig"].to_numpy(np.float64))) \
               + float(np.nansum(node_df["C_node_pf_orig"].to_numpy(np.float64)))
    total_new = float(np.nansum(seg_df["C_edge_pf"].to_numpy(np.float64))) \
               + float(np.nansum(node_df["C_node_pf"].to_numpy(np.float64)))

    run_summary = dict(
        requested_runs=requested,
        final_runs=final_runs,
        substitutions=subs,
        seg_rows=int(len(seg_df)),
        node_rows=int(len(node_df)),
        nets_processed=n_nets,
        nets_skipped_no_node_rows=n_nets_no_nodes,
        aggregate=dict(agg),
        conservation_worst_abs_err_pf=worst_cons,
        total_cap_orig_pf=total_orig,
        total_cap_new_pf=total_new,
        total_cap_abs_err_pf=abs(total_new - total_orig),
        outputs=dict(segments=str(seg_out), nodes=str(node_out)),
        elapsed_s=round(time.time() - t_start, 1),
    )
    with open(args.out_dir / "run_summary.json", "w") as f:
        json.dump(run_summary, f, indent=2)

    print(f"INFO: Runs {final_runs}")
    print(f"INFO: {len(seg_df):,} segment rows, {len(node_df):,} node rows, {n_nets:,} nets processed "
          f"({n_nets_no_nodes:,} skipped without node rows)")
    print(f"INFO: Folded {agg['n_folded_nodes']:,} nodes ({agg['folded_pf']:.6g} pF), {agg['n_deg0_nodes']:,} nodes "
          f"without an incident edge keep their capacitance ({agg['residual_pf']:.3g} pF)")
    print(f"INFO: Endpoints resolved by name {agg['n_endpoints_by_name']:,}, by coordinates {agg['n_endpoints_by_coord']:,}, "
          f"unresolved {agg['n_endpoints_unresolved']:,}, with several coordinate matches {agg['n_multi_coord']:,}")
    print(f"INFO: Capacitance conservation: worst per-net error {worst_cons:.3e} pF, "
          f"global error {abs(total_new - total_orig):.3e} pF")
    print(f"INFO: Wrote {seg_out}, {node_out} and {args.out_dir / 'run_summary.json'}")
    print(f"INFO: Elapsed {time.time() - t_start:.0f}s")


if __name__ == "__main__":
    main()
