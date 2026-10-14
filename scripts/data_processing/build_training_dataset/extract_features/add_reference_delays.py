import argparse
import json
import os

import pandas as pd

# Read elmore_delays.csv of every case folder in root and stack them, with the folder name in the column _case. #
def load_all_elmore(root):
    dfs = []
    for folder in sorted(os.listdir(root)):
        csv_path = os.path.join(root, folder, "elmore_delays.csv")
        if not os.path.isfile(csv_path):
            continue
        df = pd.read_csv(csv_path)
        df["_case"] = folder
        dfs.append(df)
    print(f"INFO: Loaded {sum(len(d) for d in dfs):,} Elmore delays from {len(dfs)} case folders in {root}")
    return pd.concat(dfs, ignore_index=True)

def strip_ng45(s):
    return s[len("ng45_"):] if s.startswith("ng45_") else s

# Library capacitance of the pin of a node, in pF. The macro is cell_base_type + "_X" + cell_strength, the pin is the part of #
# node_id_def after the last "/". Internal nodes and unknown cells give 0.                                                    #
def lookup_pin_cap(row, lib_caps):
    base = str(row.get('cell_base_type', ''))
    strength = row.get('cell_strength', 1)
    node_id = str(row.get('node_id_def', ''))
    if base in ('INTERNAL', 'nan', '') or '/' not in node_id:
        return 0.0
    pin = node_id.split('/')[-1]
    try:
        full_cell = f"{base}_X{int(float(strength))}"
    except (ValueError, TypeError):
        return 0.0
    cap_fF = lib_caps.get(full_cell, {}).get(pin, 0.0)
    return cap_fF / 1000.0  # fF → pF

# Join the reference Elmore delays (case, net, load pin) to the node table, derive elmore_gt_ps (ps, -1 if unknown) and has_elmore #
# (a sink pin with a delay), add C_pin_liberty_pf (0 for the driver pin) and write the result.                                     #
def merge(elmore_root, csv_b_path, lib_cap_json, output_path):
    a = load_all_elmore(elmore_root)

    with open(lib_cap_json) as f:
        lib_caps = json.load(f)
    print(f"INFO: Loaded pin capacitances of {len(lib_caps)} cell types from {lib_cap_json}")

    b = pd.read_csv(csv_b_path, sep=",")
    print(f"INFO: Loaded {len(b):,} node rows with {len(b.columns)} columns from {csv_b_path}")

    # Key for the join, the names without the DEF escapes of the brackets #
    b["node_id_def_join"] = (
        b["node_id_def"].astype(str).str.strip()
         .str.replace(r"\\\[", "[", regex=True)
         .str.replace(r"\\\]", "]", regex=True)
    )

    # Extract net name part from net_key (everything after first /)
    b["_net_part"] = b["net_key"].str.split("/", n=1).str[1]

    a["load_pin"] = a["load_pin"].astype(str).str.strip()
    a["net"] = a["net"].astype(str).str.strip()
    a["_case"] = a["_case"].astype(str).str.strip()
    b["case"] = b["case"].astype(str).str.strip()

    a["_case"] = a["_case"].apply(strip_ng45)
    b["case"] = b["case"].apply(strip_ng45)

    a_slim = a[["_case", "net", "load_pin", "elmore_rise_s", "elmore_fall_s"]].drop_duplicates()

    merged = b.merge(
        a_slim,
        left_on = ["case",  "_net_part",  "node_id_def_join"],
        right_on = ["_case", "net",        "load_pin"],
        how="left",
    ).drop(columns=["_case", "net", "load_pin", "node_id_def_join", "_net_part"])

    merged["elmore_gt_ps"] = merged["elmore_rise_s"] * 1e12
    merged["has_elmore"] = (
        (merged["is_sink_pin"] == 1) &
        merged["elmore_rise_s"].notna()
    ).astype(int)
    merged["elmore_gt_ps"] = merged["elmore_gt_ps"].fillna(-1.0)

    merged["C_pin_liberty_pf"] = merged.apply(lambda row: lookup_pin_cap(row, lib_caps), axis=1)
    
    # Zero out driver output pin caps #
    merged.loc[merged["is_driver_pin"] == 1, "C_pin_liberty_pf"] = 0.0

    n_sink = (b["is_sink_pin"] == 1).sum()
    n_matched = merged["elmore_rise_s"].notna().sum()
    n_lib_nonzero = (merged["C_pin_liberty_pf"] > 0).sum()
    print(f"INFO: Elmore delay found for {n_matched:,} of {n_sink:,} sink pins ({100 * n_matched / max(n_sink, 1):.1f}%), "
          f"has_elmore=1 for {merged['has_elmore'].sum():,} rows")
    print(f"INFO: Library pin capacitance is non-zero for {n_lib_nonzero:,} of {len(b):,} node rows")

    merged.to_csv(output_path, index=False)
    print(f"INFO: Wrote {len(merged):,} rows to {output_path}")

if __name__ == "__main__":
    ap = argparse.ArgumentParser(description="Add the reference Elmore delays and the library pin capacitances to the annotated node table.")
    ap.add_argument("--delays-dir", required=True, help="folder with <design>/elmore_delays.csv")
    ap.add_argument("--lib-cap-json", required=True, help="library pin capacitances (data/configs/ng45_pin_capacitance.json)")
    ap.add_argument("--nodes-csv", default="annotated/annotated_nodes.csv")
    ap.add_argument("--output", default="annotated_nodes_with_elmore.csv")
    a = ap.parse_args()
    merge(a.delays_dir, a.nodes_csv, a.lib_cap_json, a.output)