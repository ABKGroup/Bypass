import argparse
import json

import numpy as np
import pandas as pd

COLS = ["lwl", "lvpu", "up_share", "mid_share", "lnseg"]
CLIP = [0.5, 2.0]

def design_matrix(d):
    wl = d.wl.clip(lower=0.5)
    f = pd.DataFrame({"lwl": np.log(wl), "lvpu": np.log1p(d.nvia / wl), "up_share": d.up_share, "mid_share": d.mid_share,
                      "lnseg": np.log1p(d.nseg)})
    return np.column_stack([np.ones(len(d))] + [f[c].values for c in COLS])

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--nets", required=True, help="validation nets (csv or csv.gz)")
    ap.add_argument("--out", default="calibration.json")
    a = ap.parse_args()

    d = pd.read_csv(a.nets)
    d = d[(d.c_gt_pf > 0) & (d.c_pred_pf > 0) & (d.wl > 0)]
    y = np.log(d.c_gt_pf / d.c_pred_pf).values
    X = design_matrix(d)
    w = d.c_gt_pf.values
    beta = np.linalg.solve(X.T @ (X * w[:, None]) + 1e-9 * np.eye(X.shape[1]), X.T @ (w * y))
    k = np.exp(np.clip(X @ beta, np.log(CLIP[0]), np.log(CLIP[1])))
    bias = lambda c: 100.0 * (c.sum() - d.c_gt_pf.sum()) / d.c_gt_pf.sum()
    print("INFO: %d validation nets" % len(d))
    print("INFO: weighted C_total bias on the validation nets, before %.2f %%  after %.2f %%" % (bias(d.c_pred_pf), bias(d.c_pred_pf * k)))
    print("INFO: k median %.3f  min %.2f  max %.2f" % (np.median(k), k.min(), k.max()))
    json.dump(dict(model="log-ratio regression", cols=["const"] + COLS, beta=beta.tolist(), clip=CLIP, fit_on="validation runs only", nets=int(len(d))),
              open(a.out, "w"), indent=1)
    print("INFO: wrote %s" % a.out)


if __name__ == "__main__":
    main()
