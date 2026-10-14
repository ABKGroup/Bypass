# Design flow: Genus, Innovus and parasitic extraction (NanGate45)

These scripts produce the routed designs that Bypass is trained and tested on: a routed DEF, the netlist and the Commercial reference (CommRef) SPEF
(Innovus RC extraction, no coupling) for one design and one configuration (clock period, utilization, aspect ratio).
`genus_scripts/` holds the synthesis part, `invs_scripts/` the place-and-route and extraction part.

```
genus_scripts/
├── run_genus.tcl                  # logic synthesis
└── mmmc_setup.tcl                 # timing views (physical synthesis only)
invs_scripts/
├── run_sweep.sh                   # all combinations of clock period / utilization / aspect ratio of one design
├── run_design_flow.sh             # one configuration: Genus, then Innovus
├── run_innovus_no_blockages.tcl   # floorplan, placement, CTS, routing (M3 to M10), extraction
├── run_innovus_blockages.tcl      # the same with partial routing blockages on M2, M3, M4, M7, M8
├── run_innovus_5layer.tcl         # routing on M2 to M6 only, no blockages
├── util/                          # timing views, pin and macro placement, reports, DEF writing
├── tech/ng45/                     # NanGate45: lef/, lib/, qrc/ (extraction technology file) and the power-grid setup
└── designs/<design>/              # per design: the RTL, design_setup.tcl, rtl_list.tcl, <design>.sdc
```

## Run
```bash
# one configuration, in an empty run folder (clock period in ns, utilization, aspect ratio)
mkdir run && cd run && <repo>/scripts/invs_scripts/run_design_flow.sh aes_cipher_top 0.8 0.4 1.0
<repo>/scripts/invs_scripts/run_design_flow.sh aes_cipher_top 0.8 0.4 1.0 --blockages     # with routing blockages
<repo>/scripts/invs_scripts/run_design_flow.sh aes_cipher_top 5 0.4 1.0 --5layer              # 5-layer stack (M2 to M6)

# a sweep, one folder per run: <out-dir>/<design>_<tcp>_<util>_<ar>/  (runs with --blockages: ..._<ar>-blockages/)
<repo>/scripts/invs_scripts/run_sweep.sh --out-dir <pairs dir> --design aes_cipher_top \
    --tcp "0.5 0.65 0.8" --util "0.4 0.6" --ar "1.0" --jobs 2 [--blockages | --5layer]
```
`<pairs dir>` is the folder the dataset scripts read (`--pairs-dir` of `scripts/data_processing/build_*_dataset`). The suffix
`-blockages` stays in the case name, so the runs with and without blockages remain separate cases. Runs whose `.def` and `.spef` exist are skipped.

## Training configurations
The training set has two groups per design family (aes_cipher_top, ibex_core, jpeg_encoder).

**8-layer group** (routing on M3 to M10, tight clock periods, aspect ratio 1.0). Four configurations per family are run without
blockages and two with blockages:

| Family | Without blockages (clock period ns, utilization) | With blockages (`--blockages`) |
|:---|:---|:---|
| aes_cipher_top | (0.5, 0.4) (0.65, 0.4) (0.65, 0.6) (0.8, 0.4) | (0.8, 0.4) (0.65, 0.6) |
| ibex_core | (0.8, 0.4) (1.0, 0.4) (1.0, 0.6) (1.2, 0.6) | (1.0, 0.4) (1.2, 0.6) |
| jpeg_encoder | (0.5, 0.4) (0.65, 0.4) (0.65, 0.6) (0.8, 0.4) | (0.8, 0.4) (0.5, 0.6) |

The partial blockages cover the whole core area: 30% on M2, 70% on M3, 30% on M4, 10% on M7 and 10% on M8. M3 is blocked most to push
the router towards M5 and M6, which are otherwise used little, and M7 and M8 lightly to encourage M9 and M10.

**5-layer group** (routing on M2 to M6, relaxed clock periods, no blockages), run with `--5layer`:

| Family | Configurations (clock period ns, utilization, aspect ratio) |
|:---|:---|
| aes_cipher_top | (5, 0.4, 1.0) (5, 0.4, 1.2) (10, 0.4, 1.0) (10, 0.4, 1.2) (10, 0.7, 1.2) (15, 0.4, 1.2) (15, 0.8, 1.2) |
| ibex_core | (5, 0.4, 1.0) (5, 0.4, 1.2) (10, 0.4, 1.0) (10, 0.4, 1.2) (10, 0.7, 1.2) (10, 0.8, 1.2) (15, 0.4, 1.2) (15, 0.7, 1.2) |
| jpeg_encoder | (5, 0.4, 1.0) (5, 0.4, 1.2) (10, 0.4, 1.0) (10, 0.4, 1.2) (10, 0.7, 1.2) (10, 0.8, 1.2) (15, 0.4, 1.2) (15, 0.7, 1.2) |

The configurations are the ones listed in `scripts/data_processing/build_training_dataset/training_designs.txt`.
