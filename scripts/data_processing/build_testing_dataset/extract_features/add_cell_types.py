import re
import argparse
import pandas as pd
from pathlib import Path

# Remove the DEF escapes (\. \[ \] \/) from a name. #
def normalize_identifier(name):
    if not isinstance(name, str):
        return name

    return (
        name.replace(r"\.", ".")
            .replace(r"\[", "[")
            .replace(r"\]", "]")
            .replace(r"\/", "/")
    )
# Design name of a case name <design>_<tcp>_<util>_<ar>[-blockages] (aes_cipher_top_0.6_0.4_1.0 -> aes_cipher_top). #
def extract_design_name(case_name):
    m = re.match(r"^(.+)_[0-9.]+_[0-9.]+_[0-9.]+(-blockages)?$", case_name)
    return m.group(1) if m else case_name

def get_pin_suffix(node_id_def):
    node_id_def = normalize_identifier(node_id_def)

    if isinstance(node_id_def, str) and "/" in node_id_def:
        return node_id_def.rsplit("/", 1)[-1]

    return None

def get_component_name(node_id_def):
    node_id_def = normalize_identifier(node_id_def)

    if isinstance(node_id_def, str) and "/" in node_id_def:
        return node_id_def.rsplit("/", 1)[0]

    return node_id_def

# Find <case>/<design>.def of every case folder. A case without DEF is reported and skipped. #
def discover_def_files(pairs_base):
    def_files = {}

    for case_dir in sorted(pairs_base.iterdir()):
        if not case_dir.is_dir():
            continue

        case_name = case_dir.name
        design_name = extract_design_name(case_name)

        def_path = case_dir / f"{design_name}.def"

        if not def_path.exists():
            print(f"WARNING: Missing DEF: {def_path}")
            continue

        def_files[case_name] = def_path

    return def_files

# Read the components (instance -> macro) and the top-level pins (pin -> direction) of a DEF. #
def parse_def(def_path):
    comp_map = {}
    pin_map = {}

    with open(def_path, "r", errors="ignore") as f:
        lines = f.readlines()

    in_components = False
    in_pins = False
    current_pin = None

    for raw_line in lines:
        line = raw_line.strip()

        if line.startswith("COMPONENTS"):
            in_components = True
            continue

        if in_components and line.startswith("END COMPONENTS"):
            in_components = False
            continue

        if in_components and line.startswith("-"):
            tokens = line.split()

            if len(tokens) >= 3:
                comp_name = normalize_identifier(tokens[1])
                cell_type = tokens[2]
                comp_map[comp_name] = cell_type

        if line.startswith("PINS"):
            in_pins = True
            continue

        if in_pins and line.startswith("END PINS"):
            in_pins = False
            current_pin = None
            continue

        if in_pins:
            if line.startswith("-"):
                tokens = line.split()

                if len(tokens) >= 2:
                    current_pin = normalize_identifier(tokens[1])

            if "DIRECTION" in line and current_pin is not None:
                if re.search(r"\bINPUT\b", line):
                    pin_map[current_pin] = "INPUT"
                elif re.search(r"\bOUTPUT\b", line):
                    pin_map[current_pin] = "OUTPUT"
                elif re.search(r"\bINOUT\b", line):
                    pin_map[current_pin] = "INOUT"

    return comp_map, pin_map


# Cell type of one node row. Everything that no rule matches is <UNMATCHED>. Returns the normalised names, #
# type_of_cell and match_source.                                                                           #
def classify_node(row, comp_maps, pin_maps):
    node_raw = row["node_id_def"]
    design = row["design"]

    node_norm = normalize_identifier(node_raw)
    comp_name = get_component_name(node_norm)
    suffix = get_pin_suffix(node_norm)

    comp_map = comp_maps.get(design, {})
    pin_map = pin_maps.get(design, {})

    if isinstance(suffix, str) and suffix.isdigit():
        return pd.Series({
            "node_id_def_norm": node_norm,
            "component_name_norm": comp_name,
            "type_of_cell": "INTERNAL",
            "match_source": "internal_numeric_suffix"
        })

    if comp_name in comp_map:
        return pd.Series({
            "node_id_def_norm": node_norm,
            "component_name_norm": comp_name,
            "type_of_cell": comp_map[comp_name],
            "match_source": "component"
        })

    if node_norm in pin_map:
        return pd.Series({
            "node_id_def_norm": node_norm,
            "component_name_norm": comp_name,
            "type_of_cell": pin_map[node_norm],
            "match_source": "top_pin"
        })

    if isinstance(node_norm, str) and (
        "Steiner" in node_norm or
        re.search(r"/n_\d+(?:/|$)", node_norm) is not None
    ):
        return pd.Series({
            "node_id_def_norm": node_norm,
            "component_name_norm": comp_name,
            "type_of_cell": "INTERNAL",
            "match_source": "internal_pattern"
        })

    return pd.Series({
        "node_id_def_norm": node_norm,
        "component_name_norm": comp_name,
        "type_of_cell": "<UNMATCHED>",
        "match_source": "unmatched"
    })

# Split a macro name "<type>_X<n>" into the base type and the drive strength n. Names without _X<n>, and the special types, get strength 1. #
def parse_cell_type_and_strength(cell_name):
    special = {"INTERNAL", "INPUT", "OUTPUT", "INOUT", "<UNMATCHED>"}

    if not isinstance(cell_name, str) or cell_name in special:
        return cell_name, 1

    match = re.match(r"^(.+)_X(\d+)$", cell_name)

    if match:
        base_type = match.group(1)
        strength = int(match.group(2))
        return base_type, strength

    return cell_name, 1

def add_cell_type_and_strength(df):
    parsed = df["type_of_cell"].apply(parse_cell_type_and_strength)

    df["cell_base_type"] = parsed.apply(lambda x: x[0])
    df["cell_strength"] = parsed.apply(lambda x: x[1])

    return df

# Print the match statistics per design and a warning with the first unmatched rows. #
def print_basic_reports(df):
    n = len(df)
    counts = df["match_source"].value_counts(dropna=False)
    print("INFO: Match source: " + ", ".join(f"{k} {v:,} ({100.0 * v / n:.1f}%)" for k, v in counts.items()))

    types = df["type_of_cell"].value_counts(dropna=False)
    shown = types.head(10)
    more = f", {len(types) - len(shown)} more types" if len(types) > len(shown) else ""
    print("INFO: Type of cell: " + ", ".join(f"{k} {v:,}" for k, v in shown.items()) + more)

    for design, d in df.groupby("design"):
        frac = d["match_source"].value_counts(normalize=True)
        n_unmatched = int((d["match_source"] == "unmatched").sum())
        print(f"INFO: {design}: " + ", ".join(f"{k} {100.0 * v:.1f}%" for k, v in frac.items())
              + f" ({n_unmatched:,} unmatched of {len(d):,} rows)")

    unmatched = df[df["match_source"] == "unmatched"]
    if len(unmatched) > 0:
        sample_cols = [
            "design",
            "net_name",
            "node_id_def",
            "node_id_def_norm",
            "component_name_norm",
            "is_pin",
            "is_driver_pin",
            "is_sink_pin",
        ]
        sample_cols = [c for c in sample_cols if c in df.columns]
        print(f"WARNING: {len(unmatched):,} unmatched node rows, the first {min(10, len(unmatched))}:")
        print(unmatched[sample_cols].head(10).to_string(index=False))


# Read processed_nodes.csv, parse the DEF of every design, classify every node row and write the annotated table. #
def main():
    parser = argparse.ArgumentParser(
        description="Add type_of_cell, cell_base_type, and cell_strength to processed_nodes.csv using DEF files."
    )

    parser.add_argument(
        "--nodes_csv",
        required=True,
        type=Path,
        help="Input processed_nodes.csv file."
    )

    parser.add_argument(
        "--pairs_base",
        required=True,
        type=Path,
        help="Base directory containing case folders with DEF files."
    )

    parser.add_argument(
        "--out_csv",
        required=True,
        type=Path,
        help="Output CSV path."
    )

    args = parser.parse_args()

    nodes_csv = args.nodes_csv
    pairs_base = args.pairs_base
    out_csv = args.out_csv

    if not nodes_csv.exists():
        raise FileNotFoundError(f"Input nodes CSV does not exist: {nodes_csv}")

    if not pairs_base.exists():
        raise FileNotFoundError(f"Pairs base directory does not exist: {pairs_base}")

    df = pd.read_csv(nodes_csv)

    required_cols = {"design", "node_id_def"}
    missing_cols = required_cols - set(df.columns)

    if missing_cols:
        raise ValueError(f"Missing required columns in nodes CSV: {missing_cols}")

    print(f"INFO: Loaded {len(df):,} node rows of {df['design'].nunique()} designs from {nodes_csv}")

    def_files = discover_def_files(pairs_base)

    missing_defs = sorted(set(df["design"].unique()) - set(def_files.keys()))
    extra_defs = sorted(set(def_files.keys()) - set(df["design"].unique()))

    if missing_defs:
        print(f"WARNING: Designs without a DEF: {missing_defs}")
    if extra_defs:
        print(f"INFO: DEF files not used: {extra_defs}")

    comp_maps = {}
    pin_maps = {}

    for design, def_path in def_files.items():
        comp_map, pin_map = parse_def(def_path)

        comp_maps[design] = comp_map
        pin_maps[design] = pin_map

    classified = df.apply(lambda row: classify_node(row, comp_maps, pin_maps), axis=1)

    df["node_id_def_norm"] = classified["node_id_def_norm"]
    df["component_name_norm"] = classified["component_name_norm"]
    df["type_of_cell"] = classified["type_of_cell"]
    df["match_source"] = classified["match_source"]

    df = add_cell_type_and_strength(df)

    print(f"INFO: Classified {len(df):,} node rows with {len(def_files)} DEF files")
    print_basic_reports(df)

    out_csv.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(out_csv, index=False)

    print(f"INFO: Wrote annotated nodes to {out_csv}")

if __name__ == "__main__":
    main()