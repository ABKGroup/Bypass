import json
import os
from pathlib import Path

import joblib
import numpy as np
import pandas as pd
from scipy.optimize import nnls
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, r2_score
from sklearn.preprocessing import StandardScaler

# TRAINING_WORK is the --work folder of scripts/data_processing/build_training_dataset/build_training_dataset.sh
REPO = Path(__file__).resolve().parents[2]
TRAINING_WORK = Path(os.environ.get("TRAINING_WORK", REPO / "training_work"))
EDGE_CSV = Path(os.environ.get("EDGE_CSV", TRAINING_WORK / "collapsed" / "collapsed_segments.csv"))
OUTPUT_DIR = Path(os.environ.get("BASELINE_CE_DIR", REPO / "results" / "ML" / "baseline_c_edge"))
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Held-out P&R runs. These are identical to VAL_RUNS in the training script for Bypass #
VAL_RUNS = {
    "aes_cipher_top_10_0.7_1.2", "ibex_core_10_0.7_1.2", "jpeg_encoder_10_0.7_1.2",
    "aes_cipher_top_0.65_0.6_1.0", "ibex_core_1.0_0.6_1.0", "jpeg_encoder_0.65_0.6_1.0",
}

# Dictionary that contains the capacitance per unit length (in fF/um) for different # 
# metal layers. These values are used as reference coefficients for capacitance     #
# estimation in the model.                                                          #
RC_CAP_FF_PER_UM = {
    "len_metal2": 8.33611E-02, "len_metal3": 1.03981E-01, "len_metal4": 1.19150E-01,
    "len_metal5": 1.09256E-01, "len_metal6": 1.14168E-01, "len_metal7": 1.17491E-01,
    "len_metal8": 9.45346E-02, "len_metal9": 1.06091E-01, "len_metal10": 7.37095E-01,
}

MIN_LEN_UM = 0.1
C_PER_UM_MAX = 20.0    
PLACEHOLDER_R = 1.5e-3  
# Edges with resistance less than PLACEHOLDER_R are considered placeholders #
# (e.g., from the GNN's R loss) and are filtered out of the training set.   #
RF_N_EST, RF_MAX_DEPTH, RF_MIN_LEAF, SEED = 300, 15, 3, 42 
# RF_N_EST: Number of trees in the random forest                        #
# RF_MAX_DEPTH: Maximum depth of each tree                              #
# RF_MIN_LEAF: Minimum number of samples required to be at a leaf node  #
# SEED: Random seed for reproducibility                                 #

def run_of(net_key):
    return str(net_key).split("/", 1)[0]

# Evaluate the model's predictions against the ground truth. Compute R2, MAPE, medAPE, and MAE in fF. #
def ev(name, yt, yp):
    yt = np.asarray(yt, np.float64); yp = np.asarray(yp, np.float64)
    mae = mean_absolute_error(yt, yp)
    r2 = r2_score(yt, yp)
    ape = np.abs((yt - yp) / (yt + 1e-12))
    print(f"  {name:<26} R2={r2:.4f}  MAPE={100*ape.mean():.1f}%  "
          f"medAPE={100*np.median(ape):.1f}%  MAE={mae*1000:.3f} fF")
    return {"mae_fF": mae * 1000, "r2": float(r2),
            "mape": float(100 * ape.mean()), "medape": float(100 * np.median(ape))}


# Load the edge data from a CSV file, filter out placeholder edges, and compute additional features      # 
# for training and validation. Split the data into training and validation sets based on the net_key     # 
# prefixes defined in VAL_RUNS. Evaluate different models (tech-coefficient reference, NNLS fitted       #
# linear, and random forest) on the validation set and save the results and artifacts to the OUTPUT_DIR. #
df = pd.read_csv(EDGE_CSV, low_memory=False)
print(f"rows {len(df):,}   cols {df.shape[1]}")


len_cols = [c for c in RC_CAP_FF_PER_UM if c in df.columns]
for c in len_cols + ["C_edge_pf", "R_ohms", "coord_x1", "coord_y1", "coord_x2", "coord_y2"]:
    df[c] = pd.to_numeric(df.get(c), errors="coerce")
df[len_cols] = df[len_cols].fillna(0.0)
df["sum_layer_len"] = df[len_cols].sum(axis=1)

n_ph = int(((df["R_ohms"] > 0) & (df["R_ohms"] <= PLACEHOLDER_R)).sum())
keep = ((df["C_edge_pf"] > 1e-9) & (df["sum_layer_len"] >= MIN_LEN_UM)
        & (df["R_ohms"] > PLACEHOLDER_R))
df = df[keep].copy()
print(f"INFO: dropped {n_ph:,} placeholder edges (R_ohms <= {PLACEHOLDER_R})")
df["C_per_um"] = df["C_edge_pf"] / df["sum_layer_len"] * 1000.0 
n_before = len(df)
df = df[df["C_per_um"] <= C_PER_UM_MAX].copy()

df["dx_um"] = (df["coord_x2"] - df["coord_x1"]).abs().fillna(0.0)
df["dy_um"] = (df["coord_y2"] - df["coord_y1"]).abs().fillna(0.0)
df["manhattan_um"] = df["dx_um"] + df["dy_um"]

geom_features = len_cols + ["sum_layer_len", "dx_um", "dy_um", "manhattan_um"]
topo_candidates = ["coord_x1", "coord_y1", "coord_x2", "coord_y2",
                   "total_vias", "via_density", "net_total_len", "net_total_vias"]
topo_features = [c for c in topo_candidates if c in df.columns]
for c in topo_features:
    df[c] = pd.to_numeric(df[c], errors="coerce").fillna(0.0)
all_features = topo_features + geom_features
df[all_features] = df[all_features].fillna(0.0)
print(f"features: {len(all_features)}  ({len(topo_features)} topo + {len(geom_features)} geom)")

is_val = df["net_key"].map(run_of).isin(VAL_RUNS)
df_tr, df_va = df[~is_val].copy(), df[is_val].copy()
print(f"train {len(df_tr):,}   val {len(df_va):,}")
print(f"val runs present  : {sorted(df_va['net_key'].map(run_of).unique())}")
if len(df_va) == 0:
    raise SystemExit("No validation edges -- check VAL_RUNS against the net_key prefixes.")

Xtr_len = df_tr[len_cols].values
Xva_len = df_va[len_cols].values
ytr = df_tr["C_edge_pf"].values
yva = df_va["C_edge_pf"].values

results = {}

# 1. Physics-based tech-coefficient reference
tech_vec = np.array([RC_CAP_FF_PER_UM[c] for c in len_cols]) / 1000.0
results["physics_tech"] = ev("physics (tech coeffs)", yva, Xva_len @ tech_vec)

# 2. NNLS fitted linear
coefs_nnls, _ = nnls(Xtr_len, ytr)
results["nnls"] = ev("NNLS (fitted linear)", yva, np.maximum(0.0, Xva_len @ coefs_nnls))
print("  per-layer NNLS (fF/um):",
      {c.replace('len_', ''): round(v * 1000, 4) for c, v in zip(len_cols, coefs_nnls)})

# 3. Random forest on log target (raw features, matches original predict_c_edge.py)
scaler = StandardScaler().fit(df_tr[all_features].values.astype(np.float64))  
rf = RandomForestRegressor(n_estimators=RF_N_EST, max_depth=RF_MAX_DEPTH,
                           min_samples_leaf=RF_MIN_LEAF, n_jobs=-1, random_state=SEED)
rf.fit(df_tr[all_features].values.astype(np.float32), np.log(ytr + 1e-18))
pred_rf = np.maximum(0.0, np.exp(rf.predict(df_va[all_features].values.astype(np.float32))))
results["rf"] = ev("random forest (log)", yva, pred_rf)
results["rf"]["n_train"] = int(len(df_tr))
results["rf"]["n_test"] = int(len(df_va))

joblib.dump(rf,     OUTPUT_DIR / "baseline_c_edge.joblib")
joblib.dump(scaler, OUTPUT_DIR / "scaler.joblib")

# Save the results and artifacts to JSON files in the OUTPUT_DIR. This includes the NNLS # 
# coefficients, feature names, split information, and baseline results.                  #
json.dump({
    "layers":          len_cols,
    "nnls_pF_per_um":  coefs_nnls.tolist(),
    "nnls_fF_per_um":  (coefs_nnls * 1000).tolist(),
    "tech_fF_per_um":  [RC_CAP_FF_PER_UM[c] for c in len_cols],
}, open(OUTPUT_DIR / "nnls_coeffs.json", "w"), indent=2)

# Save feature names and split information to JSON files in the OUTPUT_DIR. This includes # 
# all features, topo features, geom features, and the number of columns. It also includes #
#  validation runs, target variable, number of training and validation edges, and number  #
# of unique training and validation networks.                                             #
json.dump({
    "all_features":  all_features,
    "topo_features": topo_features,
    "geom_features": geom_features,
    "len_cols":      len_cols,
}, open(OUTPUT_DIR / "feature_names.json", "w"), indent=2)

# Save split information to a JSON file in the OUTPUT_DIR. This includes the validation runs, #
# target variable, number of training and validation edges, and number of unique training and # 
# validation networks.                                                                        #
json.dump({
    "val_runs":      sorted(VAL_RUNS),
    "target":        "C_edge_pf (folded, conservation-scaled)",
    "n_train_edges": int(len(df_tr)),
    "n_val_edges":   int(len(df_va)),
    "n_train_nets":  int(df_tr["net_key"].nunique()),
    "n_val_nets":    int(df_va["net_key"].nunique()),
}, open(OUTPUT_DIR / "split_info.json", "w"), indent=2)

# Save the baseline results to a JSON file in the OUTPUT_DIR. This includes the evaluation metrics # 
# for each model (physics-based, NNLS, and random forest).                                         #
json.dump(results, open(OUTPUT_DIR / "baseline_results.json", "w"), indent=2)

print(f"\nINFO: -> {OUTPUT_DIR}")
for k, r in results.items():
    print(f"  {k:<14} R2={r['r2']:.4f}  MAPE={r['mape']:.1f}%")
