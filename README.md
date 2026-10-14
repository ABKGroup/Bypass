# Bypass: Physics-Guided Parasitic Extraction Without Technology Files

Bypass is a physics-guided graph neural network framework that
predicts the resistance and capacitance of a routed design from its DEF alone,
with no extraction technology file and no extraction run at inference time.
The output is a standard SPEF that OpenSTA and PrimeTime accept in place of an extracted one.

This work, *Bypass: Physics-Guided Parasitic Extraction Without Technology Files*, has been submitted to the International Symposium on Circuits and Systems (ISCAS) 2027.

![Bypass Framework](images/Overview-of-Bypass-Flow.png)

> This work was enabled by the generous academic support of *Cadence Design Systems* and *Synopsys*. We gratefully acknowledge their provision of EDA tools and technologies used in this research.
>
> Any indicators of correlation or performance presented herein are **not** and should **not** be construed as benchmarking of any commercial EDA tool, product, or vendor. Results are provided solely to enable reproducible academic research.

## Code Structure

```
Bypass/
├── models/                            # Model architectures
│   ├── bypass/
│   │   ├── train.py                   # Bypass model definition and training
│   │   ├── run_inference.py           # Bypass inference: predict R and C, write the SPEF
│   │   └── post-calibration/          # Optional net-level capacitance correction
│   ├── ML/                            # ML baseline: per-edge regressor (R) and random forest (C_edge)
│   ├── Tech/                          # Tech baseline: technology-table heuristic
│   └── common/                        # Graph building, inference loop, SPEF writer
├── scripts/                           # Scripts for data generation and evaluation
│   ├── genus_scripts/                 # Logic synthesis
│   ├── invs_scripts/                  # Placement, routing and extraction (incl. NanGate45 files)
│   ├── opensta_scripts/               # Elmore reference delays, timing with a SPEF
│   ├── pt_scripts/                    # PrimeTime timing with a SPEF
│   └── data_processing/
│       ├── build_training_dataset/    # LEF/DEF/SPEF features, label alignment, capacitance fold
│       └── build_testing_dataset/     # Features from LEF and DEF only
├── data/
│   ├── configs/                       # Library data (pin capacitances, LEF geometry) as JSON
│   └── training_sample/               # Sample of the training tables
├── results/                           # Model results
│   ├── model/                         # Trained Bypass model (bypass.pt)
│   ├── ML/                            # Trained baselines
│   ├── calibration/                   # Calibration coefficients and their effect on capacitance
│   ├── model_targets/                 # R and C accuracy tables (.csv)
│   ├── sta_analysis/                  # Timing tables (.csv)
│   └── figures/                       # Plots (described in results/README.md)
├── images/                            # Figures for this README
├── requirements.txt                   # Dependencies for model training and inference
├── LICENSE                            # License
└── README.md                          # Project documentation
```

## Requirements

The Python dependencies are listed in `requirements.txt`. For commercial EDA tools, we used the versions below.

**Cadence**

- Genus: 21.1
- Innovus: 21.1
- Quantus: 21.1

**Synopsys**

- PrimeTime: 18.6

## Training Bypass

1. **Generate routed designs and Commercial reference (CommRef) SPEF** with Genus, Innovus and Quantus. The 42 training configurations are listed in `scripts/invs_scripts/README.md`.

```
scripts/invs_scripts/run_sweep.sh --out-dir <pairs dir> --design aes_cipher_top \
    --tcp "0.5 0.65 0.8" --util "0.4 0.6" --ar "1.0" --jobs 2
```

2. **Compute CommRef Elmore delays** with OpenSTA (used as the timing term in the loss)

```
ORIGINAL_BASE=<pairs dir> BASE_REPORT_DIR=<delays dir> \
    scripts/opensta_scripts/run_opensta_elmore.sh --jobs 8
```

3. **Build the training tables**

```
scripts/data_processing/build_training_dataset/build_training_dataset.sh \
    --designs scripts/data_processing/build_training_dataset/training_designs.txt \
    --pairs-dir <pairs dir> --delays-dir <delays dir> --work <work dir>
```

The algorithm is described in the [training dataset README](scripts/data_processing/build_training_dataset/README.md). A small sample of the output is provided in `data/training_sample/`.

4. **Train Bypass**

```
pip install -r requirements.txt
TRAINING_WORK=<work dir> OUTPUT_DIR=<model dir> python3 models/bypass/train.py
```

Results are written to `OUTPUT_DIR` (default `results/model/`):

```
<model dir>/
├── bypass.pt           # Best model on the validation runs
├── bypass_latest.pt    # Model at the last epoch
└── ...                 # Plots and metrics of the best epoch
```

The validation runs are listed in `VAL_RUNS` at the top of `train.py`. Run names follow `<design>_<tcp>_<util>_<ar>`.

You can directly use our pre-trained model:

```
results/model/bypass.pt
```

5. (Optional) Train the baselines:

```
python3 models/ML/train_r.py
python3 models/ML/train_c_edge.py
```

## Predicting the SPEF of a New Design

Inference needs only the routed DEF. No technology file and no SPEF are read.

1. **Prepare routed designs**, one folder per design with the DEF inside (`<pairs dir>/<case>/<design>.def`). The folder name is the case name, e.g., `aes_cipher_top_0.8_0.4_1.0`. Designs can come from `scripts/invs_scripts` or from your own flow.

2. **Extract features** from the DEF

```
scripts/data_processing/build_testing_dataset/build_testing_dataset.sh \
    --pairs-dir <pairs dir> --case <case> --work <work dir>
```

This writes `<work>/processed/processed_segments.csv` and `<work>/elmore/annotated_nodes_with_elmore.csv`. Use `--design NAMES` to process all cases of some designs.

3. Run **Bypass** inference

```
MODEL_CKPT=results/model/bypass.pt \
TEST_SEG=<work>/processed/processed_segments.csv \
TEST_NODE=<work>/elmore/annotated_nodes_with_elmore.csv \
PAIRS_BASE=<pairs dir> PRED_OUT=<output dir> \
python3 models/bypass/run_inference.py
```

- **EVAL_DESIGNS**: comma-separated cases to restrict the run
- **PAIRS_BASE**: adds the top-level port connections from the DEF to the SPEF
- **SKIP_DONE**: completed designs are skipped by default, set `SKIP_DONE=0` to redo them

4. **Inference results** are generated in:

```
<output>/spef_src/bypass/<case>/<design>.spef        # Predicted SPEF
<output>/predictions/bypass/<case>_edges.csv         # R and C of every edge
<output>/predictions/bypass/<case>_nodes.csv         # Node capacitance
<output>/predictions/bypass/<case>_net_ctot.csv      # Total capacitance of every net
<output>/predictions/bypass/<case>_elmore.csv        # Predicted Elmore delay of every node
```

The SPEF is named after the design (the case name without `_<tcp>_<util>_<ar>`).

5. (Optional) Apply the capacitance calibration fitted on the validation runs:

```
python3 models/bypass/post-calibration/apply_calibration.py \
    --spef <output>/spef_src/bypass/<case>/<design>.spef \
    --segments <work>/processed/processed_segments.csv --case <case> \
    --calibration results/calibration/calibration.json --out <calibrated.spef>
```

6. (Optional) Run baseline comparisons (same variables and output layout as Bypass):

- **ML Baseline** (per-edge regressor for R, random forest for C_edge)

```
python3 models/ML/run_inference.py
```

- **Tech Baseline** (technology-table heuristic)

```
python3 models/Tech/run_inference.py
```

## Evaluation

A predicted SPEF is evaluated by the timing an STA engine reports with it, compared with the same analysis on the CommRef SPEF.

**Steps:**

1. Use the inference output folder as the evaluation folder and place the CommRef SPEF of each case in:

```
<eval dir>/spef_src/original/<case>/
```

2. Run **OpenSTA** (set `STA_BIN=<path to sta>` if it is not on the PATH)

```
scripts/opensta_scripts/run_opensta_timing.sh --eval-dir <eval dir> --netlist-dir <pairs dir> \
    --lib scripts/invs_scripts/tech/ng45/lib/NangateOpenCellLibrary_typical.lib --jobs 4
```

3. Run **PrimeTime**, with the `original` variant first (it is the reference)

```
NANGATE45_DB_DIR=<folder with the .db libraries> scripts/pt_scripts/run_primetime_timing.sh \
    --eval-dir <eval dir> --netlist-dir <pairs dir> --src original --jobs 4
NANGATE45_DB_DIR=<folder with the .db libraries> scripts/pt_scripts/run_primetime_timing.sh \
    --eval-dir <eval dir> --netlist-dir <pairs dir> --src bypass --jobs 4
```

4. Per-pin arrival times and the worst slack are written per case and variant.

5. (Optional) Run the resistance-or-capacitance ablation (five variants):

```
scripts/opensta_scripts/run_opensta_ablation.sh
scripts/pt_scripts/run_primetime_ablation.sh
```