import json
import os
import sys
from pathlib import Path

import numpy as np
import pandas as pd
import torch
import torch.nn as nn

_HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(_HERE.parent / "common"))
import inference_engine as E 

_REPO = _HERE.parents[1]
BASELINE_R_DIR = Path(os.environ.get("BASELINE_R_DIR",  str(_REPO / "results" / "ML" / "baseline_r")))
BASELINE_CE_DIR = Path(os.environ.get("BASELINE_CE_DIR", str(_REPO / "results" / "ML" / "baseline_c_edge")))
_EMBED = 256

# TabularRPredictor: learnable physics term R_base = sum(len*r_L) + n_via*r_via, # 
# times a small-MLP multiplicative residual.                                      #
class TabularRPredictor(nn.Module):
    def __init__(self, feat_dim, n_metals, n_vias):
        super().__init__()
        self.r_L = nn.Parameter(torch.zeros(n_metals))
        self.r_via = nn.Parameter(torch.zeros(n_vias))
        self.encoder = nn.Sequential(
            nn.Linear(feat_dim, _EMBED), nn.LayerNorm(_EMBED), nn.GELU(), nn.Dropout(0.1),
            nn.Linear(_EMBED, _EMBED), nn.LayerNorm(_EMBED), nn.GELU(),
        )
        self.delta_r_head = nn.Sequential(
            nn.Linear(_EMBED, 128), nn.GELU(), nn.Dropout(0.1),
            nn.Linear(128, 64), nn.GELU(), nn.Linear(64, 1),
        )

    def forward(self, x, metal_lens, via_counts):
        R_base = (metal_lens * self.r_L).sum(1) + (via_counts * self.r_via).sum(1)
        R_base = R_base.clamp(min=1e-6)
        dr = torch.clamp(self.delta_r_head(self.encoder(x)).squeeze(1), -5.0, 5.0)
        return R_base * torch.exp(dr)

# Predicts per-edge R and C_edge for each net in the segment dataframe. Returns two dictionaries keyed by net_key. #
def predict_baselines(seg):
    import joblib

    df = seg.reset_index(drop=True).copy()
    for c in ("coord_x1", "coord_y1", "coord_x2", "coord_y2"):
        df[c] = pd.to_numeric(df.get(c), errors="coerce").fillna(0.0)
    df["dx_um"] = (df["coord_x2"] - df["coord_x1"]).abs()
    df["dy_um"] = (df["coord_y2"] - df["coord_y1"]).abs()
    df["manhattan_um"] = df["dx_um"] + df["dy_um"]
    df["total_via_count"] = pd.to_numeric(df.get("total_vias"), errors="coerce").fillna(0.0)

    # R: physics + MLP residual #
    rck = torch.load(BASELINE_R_DIR / "baseline_r.pt", map_location="cpu")
    r_feats, r_len, r_scaler = rck["all_features"], rck["len_cols"], rck["scaler"]
    for c in set(r_feats) | set(r_len):
        if c not in df.columns:
            df[c] = 0.0
    for c in r_len:
        df[c] = pd.to_numeric(df[c], errors="coerce").fillna(0.0)
    df["sum_layer_len"] = df[r_len].sum(axis=1)                       # metal1..10
    Xr = r_scaler.transform(df[r_feats].to_numpy(np.float32)).astype(np.float32)
    rmodel = TabularRPredictor(rck["feat_dim"], rck["n_metals"], rck["n_vias"])
    rmodel.load_state_dict(rck["model_state"]); rmodel.eval()
    with torch.no_grad():
        R_all = rmodel(torch.from_numpy(Xr),
                       torch.from_numpy(df[r_len].to_numpy(np.float32)),
                       torch.from_numpy(df[["total_via_count"]].to_numpy(np.float32))
                       ).numpy().astype(np.float64)

    # C_edge: random forest on a log target #
    fj = json.load(open(BASELINE_CE_DIR / "feature_names.json"))
    ce_feats, ce_len = fj["all_features"], fj["len_cols"]
    rf = joblib.load(BASELINE_CE_DIR / "baseline_c_edge.joblib")
    for c in set(ce_feats) | set(ce_len):
        if c not in df.columns:
            df[c] = 0.0
    for c in ce_feats:
        df[c] = pd.to_numeric(df[c], errors="coerce").fillna(0.0)
    df["sum_layer_len"] = df[ce_len].sum(axis=1)                      # metal2..10
    Ce_all = np.maximum(0.0, np.exp(rf.predict(df[ce_feats].to_numpy(np.float32)))).astype(np.float64)

    grp = df.groupby("net_key").indices
    return ({nk: R_all[ix]  for nk, ix in grp.items()},
            {nk: Ce_all[ix] for nk, ix in grp.items()})

# MLSource: Uses the ML baselines to predict R and C_edge for each net in a batch. #
# It loads the pre-trained models and applies them to the input features.          #
class MLSource:
    name = "ml"

    def setup(self, seg, meta):
        self.r_by_net, self.ce_by_net = predict_baselines(seg)
        print(f"INFO: ML baselines: R and C_edge for {len(self.r_by_net):,} nets")

    def edge_rc(self, batch):
        ge = batch["graph_ids_edge"].numpy()
        R = np.zeros(len(ge), np.float64)
        Ce = np.zeros(len(ge), np.float64)
        for lg, net in enumerate(batch["net_names"]):
            em = np.where(ge == lg)[0]
            r, c = self.r_by_net.get(net), self.ce_by_net.get(net)
            if r is not None:
                R[em] = r[:len(em)]
            if c is not None:
                Ce[em] = c[:len(em)]
        return np.clip(R, 1e-6, None), np.clip(Ce, 0.0, None)


if __name__ == "__main__":
    E.main(MLSource(), _HERE / "predictions")
