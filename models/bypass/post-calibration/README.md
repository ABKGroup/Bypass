# Bypass Capacitance Calibration

The early arrivals of Bypass come from its net capacitance, which is low on long nets and in dense routing. A net-level correction reduces this bias. It is a post-processing step on the predicted SPEF, and the model is not retrained. The effect on the capacitance and on timing is reported in [Section 4 of the results](../../../results/README.md#4-capacitance-calibration).

## Method

For every net, the log ratio of CommRef to predicted net-total capacitance is regressed on the routed geometry of the net.

```
log(C_CommRef / C_pred) = b0 + b1 log(wl) + b2 log(1 + vias/wl) + b3 upper_share + b4 mid_share + b5 log(1 + segments)
```

| Term | Definition |
|:---|:---|
| `wl` | Routed wirelength (um) |
| `vias` | Number of vias of the net |
| `upper_share` | Share of the wire on M7 to M10 |
| `mid_share` | Share of the wire on M4 to M6 |
| `segments` | Number of segments of the net |

- **Fit.** Weighted by CommRef capacitance, so long nets count more, as in the weighted bias and WMAPE. Only the six validation runs are used (165,000 nets).
- **Application.** The factor k(net) = exp(prediction), clipped to [0.5, 2], multiplies the `*CAP` values and the `*D_NET` total of the predicted net. Resistances and pin capacitances are unchanged.
- **Inference.** k(net) needs only the segment table of the feature extraction, and no CommRef data.
- **Coefficients.** [results/calibration/calibration.json](../../../results/calibration/calibration.json).

## Files

| File | Content |
|:---|:---|
| `net_features.py` | Computes the per-net features (wirelength, layer shares, segments, vias) from the segment table of the feature extraction |
| `fit_calibration.py` | Fits the regression on the validation nets and writes the coefficients (`calibration.json`) |
| `apply_calibration.py` | Scales the capacitance of every net of a predicted SPEF and writes the calibrated SPEF |

## Usage

```bash
# 1. fit on the validation nets (csv: wl, up_share, mid_share, nseg, nvia, c_gt_pf, c_pred_pf)
python3 models/bypass/post-calibration/fit_calibration.py --nets val_nets.csv --out calibration.json

# 2. calibrate one predicted SPEF (segments: processed_segments.csv of the feature extraction)
python3 models/bypass/post-calibration/apply_calibration.py --spef bypass.spef --segments processed_segments.csv \
    --case <case> --calibration calibration.json --out bypass_cal.spef
```

The coefficients fitted on the validation runs are in `results/calibration/calibration.json` and can be used directly in step 2.
