import json
import os
import time
from pathlib import Path

import numpy as np
import pandas as pd
import torch
import torch.nn as nn
import torch.nn.functional as F
from sklearn.preprocessing import StandardScaler
from torch.utils.data import DataLoader, Dataset

# TRAINING_WORK is the --work folder of scripts/data_processing/build_training_dataset/build_training_dataset.sh
REPO = Path(__file__).resolve().parents[2]
TRAINING_WORK = Path(os.environ.get("TRAINING_WORK", REPO / "training_work"))
EDGE_CSV = Path(os.environ.get("EDGE_CSV", TRAINING_WORK / "collapsed" / "collapsed_segments.csv"))
OUTPUT_DIR = Path(os.environ.get("BASELINE_R_DIR", REPO / "results" / "ML" / "baseline_r"))
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Held-out P&R runs. These are identical to VAL_RUNS in the training script for Bypass #
VAL_RUNS = {
    "aes_cipher_top_10_0.7_1.2", "ibex_core_10_0.7_1.2", "jpeg_encoder_10_0.7_1.2",
    "aes_cipher_top_0.65_0.6_1.0", "ibex_core_1.0_0.6_1.0", "jpeg_encoder_0.65_0.6_1.0",
}

# tech-file resistances (Ohm/um). These are only the initial value of the learnable r_L #
RC_RES_OHM_PER_UM = {
    "len_metal1": 5.4286,  "len_metal2": 3.70635, "len_metal3": 3.57728,
    "len_metal4": 1.47397, "len_metal5": 1.49065, "len_metal6": 1.50265,
    "len_metal7": 0.264082, "len_metal8": 0.189296, "len_metal9": 0.034286,
    "len_metal10": 0.038654,
}

EPOCHS = 1000
PATIENCE = 40
BATCH_SIZE = 4096
LR_PHYSICS = 1e-3
LR_MLP = 1e-3
WEIGHT_DECAY = 1e-4
HUBER_DELTA = 1.0
EMBED_DIM = 256
LAMBDA_R = 1.0
MIN_LEN_UM = 1e-6
PLACEHOLDER_R = 1.5e-3   
# Edges with resistance less than PLACEHOLDER_R are considered placeholders #
# (e.g., from the GNN's R loss) and are filtered out of the training set.   #

def run_of(net_key):
    return str(net_key).split("/", 1)[0]

# Load the edge CSV and prepare the training and validation datasets #
df = pd.read_csv(EDGE_CSV, low_memory=False)


len_cols = [c for c in RC_RES_OHM_PER_UM if c in df.columns]
missing = [c for c in RC_RES_OHM_PER_UM if c not in df.columns]

print(f"INFO: Rows {len(df):,}, Columns {df.shape[1]}")
print(f"INFO: metal length cols : {len_cols}")
if missing:
    print(f"missing metal cols: {missing}")

for c in len_cols:
    df[c] = pd.to_numeric(df[c], errors="coerce").fillna(0.0)      # already micrometres #
df["R_ohms"] = pd.to_numeric(df["R_ohms"], errors="coerce")

# Total number of vias is either in the "total_vias" column or summed from the "n_via_*" columns #
if "total_vias" in df.columns:
    df["total_via_count"] = pd.to_numeric(df["total_vias"], errors="coerce").fillna(0.0)
else:
    vcols = [c for c in df.columns if c.startswith("n_via_")]
    df["total_via_count"] = (df[vcols].apply(pd.to_numeric, errors="coerce")
                             .fillna(0.0).sum(axis=1))

for c in ("coord_x1", "coord_y1", "coord_x2", "coord_y2"):
    df[c] = pd.to_numeric(df.get(c), errors="coerce").fillna(0.0)
df["dx_um"] = (df["coord_x2"] - df["coord_x1"]).abs()
df["dy_um"] = (df["coord_y2"] - df["coord_y1"]).abs()
df["manhattan_um"] = df["dx_um"] + df["dy_um"]
df["sum_layer_len"] = df[len_cols].sum(axis=1)

n0 = len(df)
n_ph = int(((df["R_ohms"] > 0) & (df["R_ohms"] <= PLACEHOLDER_R)).sum())
keep = (df["R_ohms"] > PLACEHOLDER_R) & (df["sum_layer_len"] > MIN_LEN_UM)
df = df[keep].copy()
print(f"after filters      : {len(df):,}  (dropped {n_ph:,} placeholder edges, "
      f"{n0 - len(df) - n_ph:,} zero-length)")

feats = len_cols + ["total_via_count", "sum_layer_len", "dx_um", "dy_um", "manhattan_um"]
df[feats] = df[feats].fillna(0.0)

is_val = df["net_key"].map(run_of).isin(VAL_RUNS)
df_tr, df_va = df[~is_val].copy(), df[is_val].copy()
print(f"train edges {len(df_tr):,}   val edges {len(df_va):,}")
print(f"val runs present   : {sorted(df_va['net_key'].map(run_of).unique())}")
if len(df_va) == 0:
    raise SystemExit("No validation edges -- check VAL_RUNS against the net_key prefixes.")

# Scale the features and prepare the PyTorch datasets and dataloaders #
scaler = StandardScaler()
X_tr = scaler.fit_transform(df_tr[feats].values.astype(np.float32))
X_va = scaler.transform(df_va[feats].values.astype(np.float32))
metal_tr = df_tr[len_cols].values.astype(np.float32)
metal_va = df_va[len_cols].values.astype(np.float32)
via_tr = df_tr[["total_via_count"]].values.astype(np.float32)
via_va = df_va[["total_via_count"]].values.astype(np.float32)
y_tr = df_tr["R_ohms"].values.astype(np.float32)
y_va = df_va["R_ohms"].values.astype(np.float32)

# EdgeDS: PyTorch Dataset for the edge features, metal lengths, via counts, and target resistances #
class EdgeDS(Dataset):
    def __init__(self, X, m, v, y):
        self.X, self.m, self.v, self.y = map(torch.from_numpy, (X, m, v, y))

    def __len__(self):
        return len(self.y)

    def __getitem__(self, i):
        return self.X[i], self.m[i], self.v[i], self.y[i]

# Create DataLoaders for training and validation datasets #
tl = DataLoader(EdgeDS(X_tr, metal_tr, via_tr, y_tr), batch_size=BATCH_SIZE, shuffle=True)
vl = DataLoader(EdgeDS(X_va, metal_va, via_va, y_va), batch_size=BATCH_SIZE, shuffle=False)

# TabularRPredictor: PyTorch model that predicts resistance from tabular features, #
# metal lengths, and via counts                                                    #
class TabularRPredictor(nn.Module):
    def __init__(self, feat_dim, n_metals, n_vias, r_L_init, r_via_init):
        super().__init__()
        self.r_L = nn.Parameter(torch.tensor(r_L_init,   dtype=torch.float32))
        self.r_via = nn.Parameter(torch.tensor(r_via_init, dtype=torch.float32))
        self.encoder = nn.Sequential(
            nn.Linear(feat_dim, EMBED_DIM), nn.LayerNorm(EMBED_DIM), nn.GELU(), nn.Dropout(0.1),
            nn.Linear(EMBED_DIM, EMBED_DIM), nn.LayerNorm(EMBED_DIM), nn.GELU(),
        )
        self.delta_r_head = nn.Sequential(
            nn.Linear(EMBED_DIM, 128), nn.GELU(), nn.Dropout(0.1),
            nn.Linear(128, 64), nn.GELU(), nn.Linear(64, 1),
        )
        nn.init.zeros_(self.delta_r_head[-1].weight)
        nn.init.zeros_(self.delta_r_head[-1].bias)

    def forward(self, x, metal_lens, via_counts):
        R_base = (metal_lens * self.r_L).sum(1) + (via_counts * self.r_via).sum(1)
        R_base = R_base.clamp(min=1e-6)
        dr = torch.clamp(self.delta_r_head(self.encoder(x)).squeeze(1), -5.0, 5.0)
        return R_base * torch.exp(dr)

# Compute regression metrics: R^2, MAPE, MedAPE, LogMAE #
def rmetrics(g, p):
    g = np.asarray(g, np.float64); p = np.asarray(p, np.float64)
    m = np.isfinite(g) & np.isfinite(p) & (g > 0) & (p > 0)
    g, p = g[m], p[m]
    if len(g) == 0:
        return {k: float("nan") for k in ("r2", "mape", "medape", "logmae")}
    e = p - g; ape = np.abs(e) / g
    ss = np.sum(e ** 2); st = np.sum((g - g.mean()) ** 2)
    return {
        "r2":     float(1 - ss / st) if st > 0 else float("nan"),
        "mape":   float(100 * ape.mean()),
        "medape": float(100 * np.median(ape)),
        "logmae": float(np.mean(np.abs(np.log(p) - np.log(g)))),
    }

dev = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print("device", dev)

# Initialize the TabularRPredictor model with the number of features, metals, and vias, #
# and set the initial resistances based on the RC_RES_OHM_PER_UM dictionary. Set up the #
# optimizer with different learning rates for the physical parameters (r_L and r_via)   #
# and the MLP components (encoder and delta_r_head).                                    #
model = TabularRPredictor( X_tr.shape[1], len(len_cols), 1,
                           r_L_init=[RC_RES_OHM_PER_UM.get(c, 1e-3) for c in len_cols],
                           r_via_init=[3.0],
).to(dev)

# Set up the optimizer with different learning rates for the physical parameters  # 
# (r_L and r_via) and the MLP components (encoder and delta_r_head). Create a     #
# learning rate scheduler that reduces the learning rate when the validation loss #
# plateaus.                                                                       #
opt = torch.optim.Adam([
    {"params": [model.r_L, model.r_via],         "lr": LR_PHYSICS},
    {"params": model.encoder.parameters(),       "lr": LR_MLP},
    {"params": model.delta_r_head.parameters(),  "lr": LR_MLP / 10},
], weight_decay=WEIGHT_DECAY)
sched = torch.optim.lr_scheduler.ReduceLROnPlateau(opt, mode="min", factor=0.5, patience=20)

# One training or validation epoch. Returns the mean Huber loss and the golden and predicted values. #
def run_epoch(loader, train):
    tot, P, G = 0.0, [], []
    for X, m, v, y in loader:
        X, m, v, y = (t.to(dev) for t in (X, m, v, y))
        Rp = model(X, m, v)
        msk = torch.isfinite(y) & torch.isfinite(Rp) & (y > 0) & (Rp > 0)
        if msk.any():
            d = torch.log(Rp[msk] + 1e-12) - torch.log(y[msk] + 1e-12)
            loss = LAMBDA_R * F.huber_loss(d, torch.zeros_like(d), delta=HUBER_DELTA)
        else:
            loss = torch.zeros((), device=dev)
        if train:
            opt.zero_grad(); loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0); opt.step()
        tot += float(loss)
        P.extend(Rp.detach().cpu().numpy()); G.extend(y.detach().cpu().numpy())
    return tot / max(len(loader), 1), np.array(G), np.array(P)

# Training loop: for each epoch, run a training epoch and a validation epoch,  #
# compute the metrics, update the learning rate scheduler, save the best model,#
# and implement early stopping based on validation loss. Save the training     #
# history to a CSV file.                                                       #
best, noimp, hist, t0 = float("inf"), 0, [], time.time()
print(f"{'ep':>4} | {'train':>9} | {'val':>9} | {'R2':>7} | {'MAPE':>7} | status")
print("-" * 60)
for ep in range(1, EPOCHS + 1):
    model.train(); ltr, _, _ = run_epoch(tl, True)
    model.eval()
    with torch.no_grad():
        lva, G, P = run_epoch(vl, False)
    m = rmetrics(G, P); sched.step(lva)
    hist.append({"epoch": ep, "loss_train": ltr, "loss_val": lva,
                 **{f"R_{k}": v for k, v in m.items()}})
    pd.DataFrame(hist).to_csv(OUTPUT_DIR / "training_history.csv", index=False)

    if lva < best:
        best, noimp, tag = lva, 0, "*"
        torch.save({
            "model_state":   model.state_dict(),
            "epoch":         ep,
            "feat_dim":      X_tr.shape[1],
            "n_metals":      len(len_cols),
            "n_vias":        1,
            "all_features":  feats,
            "geom_features": feats,
            "len_cols":      len_cols,
            "via_cols":      ["total_via_count"],
            "res_col":       "R_ohms",
            "scaler":        scaler,
            "val_runs":      sorted(VAL_RUNS),
            "val_loss":      lva,
            "R_metrics":     m,
        }, OUTPUT_DIR / "baseline_r.pt")
        json.dump({"epoch": ep, "val_loss": lva, "R_metrics": m},
                  open(OUTPUT_DIR / "best_model_summary.json", "w"), indent=2)
    else:
        noimp += 1; tag = f"no imp {noimp}"

    print(f"{ep:4d} | {ltr:9.5f} | {lva:9.5f} | {m['r2']:7.4f} | {m['mape']:6.2f}% | {tag}")
    if noimp >= PATIENCE:
        print("\nEarly stopping.")
        break

print(f"\niNFO: Total {(time.time() - t0)/60:.1f} min")
print("INFO: learned r_L  :", [round(x, 5) for x in model.r_L.detach().cpu().tolist()])
print("INFO: learned r_via:", [round(x, 5) for x in model.r_via.detach().cpu().tolist()])
print("INFO: best val     :", json.load(open(OUTPUT_DIR / "best_model_summary.json")))
