import pandas as pd
import os
import json


_REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", ".."))
_ELMORE_DEF = _REPO + "/data/OpenSTA_delays"
_LIB_DEF = _REPO + "/data/configs/ng45_pin_capacitance.json"
ELMORE_ROOT = os.environ.get("ELMORE_ROOT", _ELMORE_DEF)
CSV_B_PATH = "annotated/annotated_nodes.csv"
LIB_CAP_JSON = os.environ.get("LIB_CAP_JSON", _LIB_DEF)
OUTPUT_PATH = "elmore/annotated_nodes_with_elmore.csv"

NO_ELMORE = os.environ.get("NO_ELMORE", "0") == "1"

# Stack the elmore_delays.csv of every case folder, with the folder name in the column _case. #
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


# Library capacitance (pF) of the pin of a node. Internal nodes, top-level pins, unknown cells and pins without a #
# capacitance give 0.                                                                                             #
def lookup_pin_cap(row, lib_caps):
    full_cell = str(row.get('type_of_cell', ''))
    node_id = str(row.get('node_id_def', ''))
    if full_cell in ('INTERNAL', 'INPUT', 'OUTPUT', 'INOUT', '<UNMATCHED>', 'nan', '') or '/' not in node_id:
        return 0.0
    pin = node_id.split('/')[-1]
    cap_fF = lib_caps.get(full_cell, {}).get(pin)
    return (cap_fF or 0.0) / 1000.0


# Join the reference Elmore delays (case, net, load pin) to the node table, add elmore_gt_ps (-1 if unknown), #
# has_elmore and C_pin_liberty_pf (0 for driver pins), and write the result.                                  #
def merge(elmore_root, csv_b_path, lib_cap_json, output_path):
    if not NO_ELMORE:
        a = load_all_elmore(elmore_root)

    with open(lib_cap_json) as f:
        lib_caps = json.load(f)
    print(f"INFO: Loaded pin capacitances of {len(lib_caps)} cell types from {lib_cap_json}")

    b = pd.read_csv(csv_b_path, sep=None, engine="python")
    print(f"INFO: Loaded {len(b):,} node rows with {len(b.columns)} columns from {csv_b_path}")

    b["node_id_def_join"] = (
        b["node_id_def"].astype(str).str.strip()
         .str.replace(r"\\\[", "[", regex=True)
         .str.replace(r"\\\]", "]", regex=True)
    )

    b["_net_part"] = (
    b["net_key"].str.split("/", n=1).str[1]
        .str.replace(r"\\\[", "[", regex=True)
        .str.replace(r"\\\]", "]", regex=True)
        .str.replace(r"\\\$", "$", regex=True)
    )

    b["case"] = b["case"].astype(str).str.strip()

    if NO_ELMORE:
        print("INFO: NO_ELMORE=1, the Elmore ground truth is skipped")
        merged = b.drop(columns=["node_id_def_join", "_net_part"])
        merged["elmore_rise_s"] = float("nan")
        merged["elmore_fall_s"] = float("nan")
    else:
        a["load_pin"] = a["load_pin"].astype(str).str.strip()
        a["net"] = a["net"].astype(str).str.strip()
        a["_case"] = a["_case"].astype(str).str.strip()

        a_slim = a[["_case", "net", "load_pin",
                    "elmore_rise_s", "elmore_fall_s"]].drop_duplicates()

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

    merged["C_pin_liberty_pf"] = merged.apply(
        lambda row: lookup_pin_cap(row, lib_caps), axis=1
    )
    merged.loc[merged["is_driver_pin"] == 1, "C_pin_liberty_pf"] = 0.0

    n_sink = (b["is_sink_pin"] == 1).sum()
    n_matched = merged["elmore_rise_s"].notna().sum()
    n_lib_nonzero = (merged["C_pin_liberty_pf"] > 0).sum()
    if not NO_ELMORE:
        print(f"INFO: Elmore delay found for {n_matched:,} of {n_sink:,} sink pins ({100 * n_matched / max(n_sink, 1):.1f}%), "
              f"has_elmore=1 for {merged['has_elmore'].sum():,} rows")
    print(f"INFO: Library pin capacitance is non-zero for {n_lib_nonzero:,} of {len(b):,} node rows")

    merged.to_csv(output_path, index=False)
    print(f"INFO: Wrote {len(merged):,} rows to {output_path}")


if __name__ == "__main__":
    merge(ELMORE_ROOT, CSV_B_PATH, LIB_CAP_JSON, OUTPUT_PATH)