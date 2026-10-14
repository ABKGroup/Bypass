#!/usr/bin/env python3
"""
scale_to_spef_capacitance.py

Incremental fix for capacitance dropped during the collapse in
process_LEF_DEF_SPEF.py, WITHOUT re-running that script.

For every net:  true_total = sum of the golden SPEF's *CAP entries for that net.
                csv_total   = sum(C_edge_pf) + sum(C_node_pf) in the processed CSVs.
                scale       = clip(true_total / csv_total, MIN_SCALE, MAX_SCALE).
Then C_edge_pf and C_node_pf are multiplied by scale (per net).  Nets with a
ratio of ~1.0 (the majority) are untouched; the tail gets its missing cap back,
spread proportionally to where capacitance already sits.

Usage:
  python3 scale_to_spef_capacitance.py \
      --seg  <processed_segments.csv> \
      --node <annotated_nodes_with_elmore.csv> \
      --spef-root <dir containing <design>/<something>.spef> \
      [--designs d1 d2 ...]  [--out-suffix _scaled]  [--max-scale 3.0]

Writes  <seg>_scaled.csv , <node>_scaled.csv  next to the inputs, plus
scale_report.csv (per net: design, csv_total, spef_total, scale, n_segments).
"""

import argparse
import re
from collections import defaultdict
from pathlib import Path

import numpy as np
import pandas as pd

_NUM = re.compile(r"^\d+\s+\*")


def spef_cap_by_net(spef_path):
    """Return {net_name: (dnet_total, sum_CAP)} for one SPEF.

    dnet_total is the 3rd token of the *D_NET line (the net's lumped total
    capacitance as the timer sees it).  sum_CAP is the sum of the grounded
    *CAP entries -- used only as a cross-check (they match when there is no *K).
    """
    alias2name = {}
    dnet, capsum = {}, defaultdict(float)
    cur = None
    sect = None
    in_nm = False
    with open(spef_path, errors="replace") as f:
        for line in f:
            s = line.strip()
            if not s:
                continue
            if s.startswith("*NAME_MAP"):
                in_nm = True; continue
            if in_nm:
                m = re.match(r"\*(\d+)\s+(\S+)\s*$", s)
                if m:
                    alias2name[m.group(1)] = m.group(2)
                    continue
                if s.startswith("*"):
                    in_nm = False
            if s.startswith("*D_NET"):
                p = s.split()
                cur = p[1].lstrip("*")
                try:
                    dnet[cur] = float(p[2])
                except (IndexError, ValueError):
                    dnet[cur] = 0.0
                sect = None
                continue
            if s.startswith("*CONN"): sect = "conn"; continue
            if s.startswith("*CAP"):  sect = "cap";  continue
            if s.startswith("*RES"):  sect = "res";  continue
            if s.startswith("*END"):  cur = None; sect = None; continue
            if cur and sect == "cap" and _NUM.match(s):
                parts = s.split()
                # grounded:  idx *node val      coupled: idx *n1 *n2 val
                if len(parts) >= 4 and parts[2].startswith("*"):
                    continue
                try:
                    capsum[cur] += float(parts[2])
                except (IndexError, ValueError):
                    pass

    def resolve(a):
        n = alias2name.get(a, a)
        # strip a leading escaped-hier prefix nothing else uses
        return n
    return {resolve(a): (dnet[a], capsum.get(a, 0.0)) for a in dnet}


# Find the golden SPEF of a design under root (<design>/*.spef or a similar layout). Returns the path or None. #
def find_spef(root, design):
    for pat in (f"{design}/*.spef", f"*/{design}/*.spef",
                f"{design}/*/*.spef", f"*{design}*/*.spef"):
        c = sorted(Path(root).glob(pat))
        c = [x for x in c if f"/{design}/" in str(x) or str(x.parent).endswith(design)]
        if c:
            return c[0]
    return None


# Scale the capacitance of every net to the golden total. Per net, the scale is the golden *D_NET total divided by the CSV total #
# (edges plus nodes), limited to [min-scale, max-scale]. Writes scale_report.csv and scale_factors.csv. With --write-csv the     #
# scaled segment and node tables are also written.                                                                               #
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seg", required=True, type=Path)
    ap.add_argument("--node", required=True, type=Path)
    ap.add_argument("--spef-root", required=True, type=Path)
    ap.add_argument("--designs", nargs="*", default=None)
    ap.add_argument("--out-suffix", default="_scaled")
    ap.add_argument("--min-scale", type=float, default=0.9)
    ap.add_argument("--max-scale", type=float, default=3.0)
    ap.add_argument("--csv-floor", type=float, default=1e-9,
                    help="skip (scale=1) nets whose CSV total is below this")
    ap.add_argument("--write-csv", action="store_true",
                    help="also emit full <name>_scaled.csv (reads the whole CSVs; "
                         "default is diagnostic-only: scale_report.csv + scale_factors.csv)")
    args = ap.parse_args()

    # Load the tables (only the capacitance columns unless --write-csv is given) #
    outdir = args.seg.parent
    print(f"INFO: Loading {args.seg} and {args.node}")
    if args.write_csv:
        seg = pd.read_csv(args.seg, low_memory=False)
        node = pd.read_csv(args.node, low_memory=False)
    else:
        seg = pd.read_csv(args.seg,  usecols=["net_key", "C_edge_pf"], low_memory=False)
        node = pd.read_csv(args.node, usecols=["net_key", "C_node_pf"], low_memory=False)
    seg["_design"] = seg["net_key"].str.split("/").str[0]
    node["_design"] = node["net_key"].str.split("/").str[0]
    seg["_net"] = seg["net_key"].str.split("/", n=1).str[1]
    node["_net"] = node["net_key"].str.split("/", n=1).str[1]
    seg["C_edge_pf"] = pd.to_numeric(seg["C_edge_pf"],  errors="coerce").fillna(0.0)
    node["C_node_pf"] = pd.to_numeric(node["C_node_pf"], errors="coerce").fillna(0.0)

    # Designs to scale, each needs a golden SPEF #
    designs = args.designs or sorted(seg["_design"].unique())
    print(f"INFO: Scaling {len(designs)} designs")

    # Scale factor of every net #
    scale_map = {}          # (design, net) -> scale
    report = []
    for d in designs:
        sp = find_spef(args.spef_root, d)
        if sp is None:
            print(f"WARNING: {d}: no golden SPEF under {args.spef_root}, skipped")
            continue
        spef_by_net = spef_cap_by_net(sp)                       # name -> (dnet, capsum)
        # also index by a normalized key so hier / escape differences still join
        norm = lambda x: x.replace("\\", "").lstrip("/").lower()
        spef_norm = {norm(k): v for k, v in spef_by_net.items()}

        sd = seg[seg._design == d]
        nd = node[node._design == d]
        # Capacitance of the CSV per net (edges plus nodes) #
        csv_edge = sd.groupby("_net")["C_edge_pf"].sum()
        csv_node = nd.groupby("_net")["C_node_pf"].sum()
        csv_tot = csv_edge.add(csv_node, fill_value=0.0)
        nseg = sd.groupby("_net").size()

        cap_disagree = 0
        matched = n_scaled = 0
        # Compare with the golden total and clip the scale #
        for net, ct in csv_tot.items():
            hit = spef_by_net.get(net) or spef_norm.get(norm(str(net)))
            if hit is None or ct <= args.csv_floor:
                continue
            tt, cs = hit
            if tt > 0 and cs > 0 and abs(cs - tt) / tt > 0.02:
                cap_disagree += 1
            matched += 1
            raw = tt / ct
            sc = float(np.clip(raw, args.min_scale, args.max_scale))
            if abs(sc - 1.0) > 1e-6:
                n_scaled += 1
            scale_map[(d, net)] = sc
            report.append(dict(design=d, net=net, csv_total=ct, spef_total=tt,
                               ratio_raw=raw, scale=sc, n_segments=int(nseg.get(net, 0))))
        r = pd.DataFrame([x for x in report if x["design"] == d])
        print(f"INFO: {d}: matched {matched:,} of {len(csv_tot):,} nets, scaled {n_scaled:,}, "
              f"D_NET differs from the sum of CAP in {cap_disagree:,}, "
              f"ratio median {r.ratio_raw.median():.3f} p90 {r.ratio_raw.quantile(.9):.3f} max {r.ratio_raw.max():.2f}, "
              f"capacitance {100*r.csv_total.sum()/r.spef_total.sum():.1f}% -> "
              f"{100*(r.csv_total*r.scale).sum()/r.spef_total.sum():.1f}% of golden")

    # Write the report and the scale table #
    rep = pd.DataFrame(report)
    rep.to_csv(outdir / "scale_report.csv", index=False)
    # small scale table keyed by net_key -- drop-in for the consumers
    scale_tbl = rep.assign(net_key=rep.design + "/" + rep.net)[["net_key", "scale"]]
    scale_tbl.to_csv(outdir / "scale_factors.csv", index=False)

    # Apply the scale to the capacitance columns and write the scaled tables #
    if args.write_csv:
        seg_sc = np.asarray(seg.set_index(["_design", "_net"]).index.map(
            lambda k: scale_map.get(k, 1.0)), float)
        node_sc = np.asarray(node.set_index(["_design", "_net"]).index.map(
            lambda k: scale_map.get(k, 1.0)), float)
        for col, s in (("C_edge_pf", seg_sc), ("C_edge_pf_orig", seg_sc)):
            if col in seg.columns:
                seg[col] = pd.to_numeric(seg[col], errors="coerce").fillna(0.0).values * s
        for col in ("C_node_pf", "C_node_pf_orig"):
            if col in node.columns:
                node[col] = pd.to_numeric(node[col], errors="coerce").fillna(0.0).values * node_sc
        seg.drop(columns=["_design", "_net"]).to_csv(
            args.seg.with_name(args.seg.stem + args.out_suffix + ".csv"), index=False)
        node.drop(columns=["_design", "_net"]).to_csv(
            args.node.with_name(args.node.stem + args.out_suffix + ".csv"), index=False)

    print(f"INFO: {len(rep):,} nets matched, {(rep.scale.sub(1).abs() > 1e-6).sum():,} scaled")
    print(f"INFO: Ratio golden/CSV: median {rep.ratio_raw.median():.3f}  mean {rep.ratio_raw.mean():.3f}  "
          f"p90 {rep.ratio_raw.quantile(.9):.3f}  p99 {rep.ratio_raw.quantile(.99):.3f}, "
          f"{(rep.ratio_raw > args.max_scale).sum():,} nets clipped at the maximum scale {args.max_scale}")
    print(f"INFO: Total capacitance: CSV {rep.csv_total.sum():.3f} pF, scaled "
          f"{(rep.csv_total*rep.scale).sum():.3f} pF, golden {rep.spef_total.sum():.3f} pF")
    print(f"INFO: Wrote {outdir/'scale_report.csv'} and {outdir/'scale_factors.csv'}")
    if args.write_csv:
        print(f"INFO: Wrote {args.seg.with_name(args.seg.stem + args.out_suffix + '.csv')} and "
              f"{args.node.with_name(args.node.stem + args.out_suffix + '.csv')}")


if __name__ == "__main__":
    main()
