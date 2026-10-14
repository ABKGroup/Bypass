import re
import time
import numpy as np
import pandas as pd
from pathlib import Path
import numpy as np
import pandas as pd
from scipy.optimize import nnls
import os

def remove_prefix(text, prefix):
    if text.startswith(prefix):
        return text[len(prefix):]
    return text

def remove_suffix(text, suffix):
    if text.endswith(suffix):
        return text[:-len(suffix)]
    return text

def clean_case_name(name):
    name = remove_prefix(name, "ng45_")
    name = remove_suffix(name, "-blockages")
    return name

OUTPUT_DIR = Path(os.environ.get('PREPROCESS_OUTPUT_DIR', 'processed'))
ENHANCED_CSV_DIR = Path(os.environ.get('PREPROCESS_ENHANCED_DIR', 'enhanced-csv'))

# Find the pairs output_<case>.csv (segments) and output_<case>_nodes.csv (nodes) in a folder. A segment file without node file is #
# skipped. Returns {case: {"design", "segment_csv", "node_csv"}}.                                                                  #
def discover_design_csvs(csv_dir):
    design_csvs = {}

    segment_files = sorted(csv_dir.glob("output_*.csv"))

    for seg_csv in segment_files:
        name = seg_csv.name

        if "_nodes" in name or "_mapped" in name:
            continue

        node_csv = seg_csv.with_name(seg_csv.stem + "_nodes.csv")

        if not node_csv.exists():
            print(f"WARNING: Missing node CSV for {seg_csv.name}")
            continue
        
        case_name = remove_prefix(seg_csv.stem, "output_")
        design_name = case_name

        design_csvs[case_name] = {
            "design": design_name,
            "segment_csv": seg_csv,
            "node_csv": node_csv,
        }

    print(f"INFO: Found {len(design_csvs)} CSV pairs in {csv_dir}")

    return design_csvs

# Read the CSV pairs of all cases and stack them into one segment table and one node table, with the columns design and case. #
# Missing via counts and metal lengths are set to 0. Returns (segments, nodes).                                               #
def merge_csvs(design_csvs):
    seg_parts = []
    node_parts = []

    for case_name, paths in design_csvs.items():
        design_name = paths["design"]

        seg_d = pd.read_csv(paths["segment_csv"])
        node_d = pd.read_csv(paths["node_csv"])

        seg_d["design"] = design_name
        node_d["design"] = design_name

        # Important: unique run/config name, e.g. aes_cipher_top_5_0.4_1.0
        seg_d["case"] = case_name
        node_d["case"] = case_name

        seg_parts.append(seg_d)
        node_parts.append(node_d)

        print(f"INFO: {case_name}: {len(seg_d):,} segments, {len(node_d):,} nodes")

    seg_all = pd.concat(seg_parts,  ignore_index=True)
    node_all = pd.concat(node_parts, ignore_index=True)

    # Empty via counts and metal lengths mean 0 #
    via_cols = [c for c in seg_all.columns if c.startswith("n_via_")]
    seg_all[via_cols] = seg_all[via_cols].fillna(0)

    metal_len_cols = [c for c in seg_all.columns if c.startswith("len_metal")]
    seg_all[metal_len_cols] = seg_all[metal_len_cols].fillna(0)

    print(f"INFO: Merged {len(seg_all):,} segments and {len(node_all):,} nodes")

    return seg_all, node_all

import re

def parse_steiner_coords(name):
    m = re.search(r'\((\d+),\s*(\d+)\)', name)
    if m:
        return int(m.group(1)), int(m.group(2))
    return None

# Per case, replace the end point names of every segment by the row index of the node table. Order of the lookups: node_id_def,     #
# the coordinates in a Steiner name, the plain coordinates. Segments with an unresolved end are dropped. A segment that starts      #
# and ends at the same node (self loop) is removed and its vias, resistance and length are added to the node. Adds net_key          #
# (case/net) and local_node_idx. The removed self loops are saved to dropped_self_loops_diagnostics.csv. Returns (segments, nodes). #
def resolve_and_clean(seg_all, node_all):
    seg_resolved_parts = []
    node_resolved_parts = []
    all_loops_parts = []

    for case_name in seg_all["case"].unique():
        seg_d = seg_all[seg_all["case"] == case_name].copy().reset_index(drop=True)
        node_d = node_all[node_all["case"] == case_name].copy().reset_index(drop=True)

        design_name = seg_d["design"].iloc[0]

        # No deduplication needed — (net_name, coord_x, coord_y) is unique
        # (net, x, y) is unique, no deduplication is needed #
        node_d = node_d.reset_index(drop=True)

        # Primary lookup: node_id_def -> index (for pins and virtual Steiners)
        # Lookup 1: node_id_def to row index (pins and virtual Steiner points) #
        def_to_nidx = {
            row.node_id_def: i
            for i, row in enumerate(node_d.itertuples(index=False))
            if pd.notna(row.node_id_def)
        }

        # Fallback lookup: (net_name, coord_x, coord_y) -> index (for Steiner nodes)
        # Lookup 2: (net, x, y) to row index (Steiner points) #
        coord_to_nidx = {
            (row.net_name, int(round(row.coord_x)), int(round(row.coord_y))): i
            for i, row in enumerate(node_d.itertuples(index=False))
            if pd.notna(row.coord_x) and pd.notna(row.coord_y)
        }

        # Row index of an end point. Tier 1 node_id_def, tier 2 coordinates in the name (Steiner), tier 3 the plain coordinates. None if nothing matches. #
        def resolve_endpoint(ep, net_name, coord_x, coord_y):
            # Tier 1: try node_id_def match
            idx = def_to_nidx.get(ep)
            if idx is not None:
                return idx
            # Tier 2: coordinate fallback for Steiner nodes
            coords = parse_steiner_coords(ep)
            if coords:
                return coord_to_nidx.get((net_name, coords[0], coords[1]))
            # Tier 3: direct coordinate match (non-Steiner fallback)
            return coord_to_nidx.get((net_name, int(round(coord_x)), int(round(coord_y))))

        # Row indices of both end points of every segment #
        seg_d['node_idx_1'] = seg_d.apply(
            lambda r: resolve_endpoint(r.endpoint_1, r.net_name, r.coord_x1, r.coord_y1),
            axis=1
        )
        seg_d['node_idx_2'] = seg_d.apply(
            lambda r: resolve_endpoint(r.endpoint_2, r.net_name, r.coord_x2, r.coord_y2),
            axis=1
        )

        total = len(seg_d)
        both = (seg_d['node_idx_1'].notna() & seg_d['node_idx_2'].notna()).sum()
        print(f"INFO: {case_name}: end points resolved for {both:,} of {total:,} segments ({100 * both / total:.1f}%)")

        # Drop the segments whose end points could not be resolved #
        unresolved = seg_d['node_idx_1'].isna() | seg_d['node_idx_2'].isna()
        if unresolved.any():
            print(f"WARNING: {case_name}: dropped {unresolved.sum():,} segments with unresolved end points")
            seg_d = seg_d[~unresolved].reset_index(drop=True)

        seg_d['node_idx_1'] = seg_d['node_idx_1'].astype(int)
        seg_d['node_idx_2'] = seg_d['node_idx_2'].astype(int)

        # Self-loop handling
        # Self loops, the same node and the same name at both ends #
        self_loop_mask = (
            (seg_d['node_idx_1'] == seg_d['node_idx_2']) &
            (seg_d['endpoint_1'] == seg_d['endpoint_2'])
        )
        loops = seg_d[self_loop_mask].copy()

        print(f"INFO: {case_name}: {len(loops):,} self loops ({100 * len(loops) / len(seg_d):.1f}%)")

        if len(loops) > 0:
            loops["case"] = case_name
            loops["design"] = design_name
            all_loops_parts.append(loops)

        # Node columns that collect what the removed self loops carried #
        for col in [
            'incident_vias', 'self_loop_vias', 'self_loop_R_ohms',
            'self_loop_total_len_um', 'n_self_loops'
        ]:
            if col not in node_d.columns:
                node_d[col] = 0.0

        # Add the vias, resistance and length of each self loop to its node #
        for _, row in loops.iterrows():
            nidx = int(row['node_idx_1'])
            node_d.at[nidx, 'incident_vias'] += row.get('total_vias', 0.0)
            node_d.at[nidx, 'self_loop_vias'] += row.get('total_vias', 0.0)
            node_d.at[nidx, 'self_loop_R_ohms'] += row.get('R_ohms', 0.0)
            node_d.at[nidx, 'self_loop_total_len_um'] += row.get('total_len_um', 0.0)
            node_d.at[nidx, 'n_self_loops'] += 1.0

        # Remove the self loops from the segment table #
        seg_d = seg_d[~self_loop_mask].reset_index(drop=True)
        print(f"INFO: {case_name}: {len(seg_d):,} segments after the self-loop cleanup")

        node_d['local_node_idx'] = np.arange(len(node_d))

        seg_resolved_parts.append(seg_d)
        node_resolved_parts.append(node_d)

    seg = pd.concat(seg_resolved_parts,  ignore_index=True)
    node = pd.concat(node_resolved_parts, ignore_index=True)

    # net_key identifies a net across cases #
    seg["net_key"] = seg["case"]  + "/" + seg["net_name"]
    node["net_key"] = node["case"] + "/" + node["net_name"]

    # Save the removed self loops for inspection #
    if len(all_loops_parts) > 0:
        loops_all = pd.concat(all_loops_parts, ignore_index=True)
        loops_out = OUTPUT_DIR / "dropped_self_loops_diagnostics.csv"
        loops_all.to_csv(loops_out, index=False)
        print(f"INFO: Wrote the {len(loops_all):,} removed self loops to {loops_out}")
        if "total_vias" in loops_all.columns:
            print(f"INFO: Removed self loops: vias {loops_all['total_vias'].sum():,.2f}")
        if "R_ohms" in loops_all.columns:
            print(f"INFO: Removed self loops: resistance {loops_all['R_ohms'].sum():,.6f} Ω")

    print(f"INFO: After the end-point resolution: {len(seg):,} segments, {len(node):,} nodes")

    return seg, node

# Remove invalid rows. Segments with missing required values are dropped. Segments with zero resistance are kept only if they join two #
# different end points (connectors of virtual Steiner points), their resistance is set to 0.001 Ohm and is_virtual_steiner is set.     #
# Zero-length, via-free self loops are dropped. Nets with a negative node capacitance are removed, and so are nets that are missing    #
# in the segment or in the node table. Returns (segments, nodes).                                                                      #
def clean_data(seg_df, node_df):
    n0_seg = len(seg_df)
    n0_node = len(node_df)

    required_seg_cols = [
        'R_ohms', 'total_len_um', 'total_vias',
        'net_key',
        'coord_x1', 'coord_y1', 'coord_x2', 'coord_y2',
        'sinks_beyond_edge'
    ]

    # Rows with missing required values #
    seg_df = seg_df.dropna(subset=required_seg_cols).reset_index(drop=True)

    # Keep segments with R > 0, but also keep zero-R connector edges
    # between distinct endpoints (split/virtual Steiner connectors)
    # Keep R > 0 and the zero-R connectors between different end points #
    zero_r_connector = (seg_df['R_ohms'] == 0) & (seg_df['endpoint_1'] != seg_df['endpoint_2'])
    seg_df = seg_df[(seg_df['R_ohms'] > 0) | zero_r_connector].reset_index(drop=True)
    # Clamp zero-R connectors to small R so model training doesn't fail R_gt > 0 check
    zero_r_mask = seg_df['R_ohms'] == 0
    seg_df.loc[zero_r_mask, 'R_ohms'] = 0.001
    seg_df.loc[zero_r_mask, 'is_virtual_steiner'] = 1
    print(f'INFO: Kept {zero_r_mask.sum():,} zero-R connector edges and set their resistance to 0.001 Ω')

    # Drop zero-length self loops that carry no via #
    seg_df = seg_df[
        ~((seg_df['total_len_um'] < 1e-4) & 
          (seg_df['total_vias'] == 0) &
          (seg_df['endpoint_1'] == seg_df['endpoint_2']))
    ].reset_index(drop=True)

    print(f"INFO: Segment cleaning: {n0_seg:,} -> {len(seg_df):,} (dropped {n0_seg - len(seg_df):,})")

    # Keep only nodes of nets that still have segments #
    valid_seg_keys = set(seg_df['net_key'].unique())
    node_df = node_df[node_df['net_key'].isin(valid_seg_keys)].reset_index(drop=True)

    # Remove every net that has a node with negative capacitance #
    invalid_c_keys = set(
        node_df.loc[node_df['C_node_pf'] < 0, 'net_key'].unique()
    )
    n_invalid_nodes = (node_df['C_node_pf'] < 0).sum()

    node_df = node_df[~node_df['net_key'].isin(invalid_c_keys)].reset_index(drop=True)
    seg_df = seg_df[~seg_df['net_key'].isin(invalid_c_keys)].reset_index(drop=True)

    print(f"INFO: Node cleaning: {n0_node:,} -> {len(node_df):,} "
          f"(dropped {len(invalid_c_keys):,} nets with {n_invalid_nodes:,} nodes of negative capacitance)")

    # Keep nets that exist in both tables #
    both_keys = set(seg_df['net_key'].unique()) & set(node_df['net_key'].unique())

    seg_df = seg_df[seg_df['net_key'].isin(both_keys)].reset_index(drop=True)
    node_df = node_df[node_df['net_key'].isin(both_keys)].reset_index(drop=True)

    print(f"INFO: {len(both_keys):,} nets remain")

    return seg_df, node_df

# Add segment features. Active layers, index of the highest layer, via density, length share per layer, net totals (length,      #
# segments, vias), share of the net length, and the flags is_steiner, is_via_dominated (two or more vias and shorter than 2 um), #
# via_dom_metal2, via_dom_metal3plus and the products with the Steiner flag. Returns a copy of the table.                        #
def add_segment_features(df, metal_cols):
    df = df.copy()
    df['n_active_layers'] = (df[metal_cols] > 0).sum(axis=1).astype(np.float32)

    # Index of the highest metal layer used by the segment (0 if none) #
    layer_matrix = (df[metal_cols] > 0).values
    max_layer = np.where(
        layer_matrix.any(axis=1),
        layer_matrix.shape[1] - np.argmax(layer_matrix[:, ::-1], axis=1), 0
    )
    df['max_layer_idx'] = max_layer.astype(np.float32)
    df['via_density'] = (df['total_vias'] / df['total_len_um'].replace(0, np.nan)).fillna(0).astype(np.float32)

    for col in metal_cols:
        df[f'{col}_ratio'] = (df[col] / df['total_len_um'].replace(0, np.nan)).fillna(0).astype(np.float32)

    # Totals of the net, added to every segment of the net #
    net_stats = df.groupby('net_key').agg(
        net_total_len = ('total_len_um', 'sum'),
        net_n_segments =('total_len_um', 'count'),
        net_total_vias =('total_vias',   'sum'),
    ).reset_index()
    df = df.merge(net_stats, on='net_key', how='left')

    df['seg_len_fraction'] = (df['total_len_um'] / df['net_total_len'].replace(0, np.nan)).fillna(0).astype(np.float32)
    # Steiner segments (an end point is a Steiner node), via-dominated segments, and their products #
    df['is_steiner'] = (
        df['endpoint_1'].str.contains(r'/\d+$', na=False) | 
        df['endpoint_2'].str.contains(r'/\d+$', na=False) |
        df['endpoint_1'].str.contains('Steiner', na=False)
    ).astype(np.float32)
    df['is_via_dominated'] = ((df['total_vias'] >= 2) & (df['total_len_um'] < 2.0)).astype(np.float32)
    df['via_dom_metal2'] = ((df['is_via_dominated'] == 1) & (df['max_layer_idx'] == 1)).astype(np.float32)
    df['via_dom_metal3plus'] = ((df['is_via_dominated'] == 1) & (df['max_layer_idx'] >= 2)).astype(np.float32)
    df['steiner_via_ratio'] = (df['is_steiner'] * df['via_density']).astype(np.float32)
    df['steiner_layer'] = (df['is_steiner'] * df['max_layer_idx']).astype(np.float32)
    df['steiner_len'] = (df['is_steiner'] * df['total_len_um']).astype(np.float32)
    return df


# Fit the start values of the resistance model by non-negative least squares. r_L (ohm per um of each metal layer) comes from        #
# segments on a single layer without vias, r_via (ohm per via type) from segments without length. A layer with a fit below 0.01 gets #
# a fallback value, and the via fit is limited to at least 0.5 Ohm (3.0 Ohm if there is too little data). The two tables are         #
# written to r_L_warmstart.csv and r_via_warmstart.csv next to output_path and are returned.                                         #
def compute_nnls_warmstart(seg_df, metal_cols, output_path):    
    
    # Fallback r_L (ohm per um), used if the fit gives about 0 for a layer #
    R_L_FALLBACK = {
        'len_metal2': 3.59984, 'len_metal3': 3.58226, 'len_metal4': 1.51365,
        'len_metal5': 1.50666, 'len_metal6': 1.52133, 'len_metal7': 1.52133,
        'len_metal8': 1.50000, 'len_metal9': 1.50000, 'len_metal10': 1.50000,
    }
    
    EPSILON_R = 0.01 

    via_cols = [c for c in seg_df.columns if c.startswith('n_via_') and seg_df[c].sum() > 0]

    # r_L: segments on exactly one layer without vias #
    n_active = (seg_df[metal_cols] > 0).sum(axis=1)
    single_layer = seg_df[(n_active == 1) & (seg_df['total_vias'] == 0)].copy()

    print(f"INFO: Fitting r_L on {len(single_layer):,} segments")
    
    if len(single_layer) > len(metal_cols):
        X_r = single_layer[metal_cols].values.astype(np.float64)
        y_r = single_layer['R_ohms'].values.astype(np.float64)
        
        r_L_vals, _ = nnls(X_r, y_r)
    else:
        print("WARNING: Insufficient data for the r_L fit, using the fallback values")
        r_L_vals = np.array([R_L_FALLBACK.get(c, 1.5) for c in metal_cols])

    r_L_final = []
    r_L_notes = []
    for i, col in enumerate(metal_cols):
        val = r_L_vals[i]
        if val < EPSILON_R:
            val = R_L_FALLBACK.get(col, 1.5)
            r_L_notes.append(f"{col} {val:.5f} (fallback)")
        else:
            r_L_notes.append(f"{col} {val:.5f}")
        r_L_final.append(val)
    print("INFO: r_L (ohm/um): " + ", ".join(r_L_notes))

    # r_via: segments without length, only vias #
    via_only = seg_df[seg_df['total_len_um'] < 1e-4].copy()
    
    print(f"INFO: Fitting r_via on {len(via_only):,} segments")

    if len(via_only) > len(via_cols):
        X_v = via_only[via_cols].values.astype(np.float64)
        y_v = via_only['R_ohms'].values.astype(np.float64)
        
        r_via_vals, _ = nnls(X_v, y_v)
        r_via_vals = np.maximum(r_via_vals, 0.5) 
    else:
        print("WARNING: Insufficient via data, using the default of 3.0 Ω")
        r_via_vals = np.array([3.0] * len(via_cols))

    # Save the start values #
    r_L_results = pd.DataFrame({'metal_layer': metal_cols, 'r_L_ohm_per_um': r_L_final})
    r_via_results = pd.DataFrame({'via_type': via_cols, 'r_via_ohm': r_via_vals})

    r_L_results.to_csv(output_path.parent / 'r_L_warmstart.csv', index=False)
    r_via_results.to_csv(output_path.parent / 'r_via_warmstart.csv', index=False)
    
    return r_L_results, r_via_results


if __name__ == '__main__':
    total_start = time.time()
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # 1. read and merge the per-design CSVs #
    DESIGN_CSVS = discover_design_csvs(ENHANCED_CSV_DIR)
    seg_all, node_all = merge_csvs(DESIGN_CSVS)
    # 2. resolve the end points and clean the tables #
    seg, node = resolve_and_clean(seg_all, node_all)
    seg, node = clean_data(seg, node)

    print(f"INFO: Before the feature engineering: {len(seg):,} segments in {seg['net_key'].nunique():,} nets, "
          f"{len(node):,} nodes in {node['net_key'].nunique():,} nets")

    # 3. segment features. The metal length columns len_metal<n> in layer order #
    metal_cols = sorted(
        [c for c in seg.columns if c.startswith("len_metal") and not c.endswith("_ratio")],
        key=lambda c: int(c.replace("len_metal", ""))
    )

    # Convert metal length columns to numeric
    for col in metal_cols:
        seg[col] = pd.to_numeric(seg[col], errors="coerce").fillna(0.0)

    # Layer number of the segment: its only layer, or the layer with the most length if it uses several. NaN if it has no length. #
    def infer_primary_layer(row):
        vals = row[metal_cols].astype(float)
        active = vals[vals > 0]

        if len(active) == 1:
            col = active.index[0]
            return int(col.replace("len_metal", ""))

        if len(active) > 1:
            col = active.astype(float).idxmax()
            return int(col.replace("len_metal", ""))

        return np.nan

    seg["primary_layer"] = seg.apply(infer_primary_layer, axis=1)

    layer_counts = seg["primary_layer"].value_counts(dropna=False).sort_index()
    print("INFO: Primary layer: " + ", ".join(
        f"{'none' if pd.isna(k) else 'metal%d' % int(k)} {v:,}" for k, v in layer_counts.items()))

    # Segment features, then the totals of the net for the node table #
    seg = add_segment_features(seg, metal_cols)

    net_stats = seg.groupby('net_key').agg(
        net_total_len = ('total_len_um', 'sum'),
        net_n_segments = ('total_len_um', 'count'),
        net_total_vias = ('total_vias',   'sum'),
        net_max_sinks = ('sinks_beyond_edge', 'max')
    ).reset_index()
    node = node.merge(net_stats, on='net_key', how='left')

    print(f"INFO: After cleaning and feature engineering: {len(seg):,} segments with {seg.shape[1]} columns, "
          f"{len(node):,} nodes with {node.shape[1]} columns")

    # 4. NNLS start values of the resistance model #
    r_L_df, r_via_df = compute_nnls_warmstart(
        seg, metal_cols,
        output_path=OUTPUT_DIR / 'r_L_warmstart.csv'
    )

    # Start biases of the two capacitance experts (mean log node capacitance of pin and Steiner nodes) #
    pin_nodes = node[node['is_pin'] == 1]['C_node_pf'].clip(lower=1e-12)
    steiner_nodes = node[node['is_pin'] == 0]['C_node_pf'].clip(lower=1e-12)

    print(f"INFO: Start biases of the capacitance experts: pin {np.log(pin_nodes).mean():.5f}, "
          f"Steiner {np.log(steiner_nodes).mean():.5f}")

    # 5. write the processed tables #
    seg_out = OUTPUT_DIR / 'processed_segments.csv'
    node_out = OUTPUT_DIR / 'processed_nodes.csv'
    seg.to_csv(seg_out,   index=False)
    node.to_csv(node_out, index=False)
    print(f"INFO: Wrote {seg_out} ({len(seg):,} rows) and {node_out} ({len(node):,} rows)")

    print(f"INFO: Total time {(time.time() - total_start) / 60:.1f} min")