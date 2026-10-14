# Test Dataset Construction

The Bypass test dataset is built from routed NanGate45 designs without reading any parasitics. The input is the routed DEF of each design (and the LEF). The output is, for every net, a routed-net graph with per-node and per-edge feature vectors, which is the input of `models/*/run_inference.py`. The SPEF is never used, so there is no topology alignment and no `R_edge` or `C_edge` supervision. The procedure runs on every net of every design and has two parts.

| Part | Sections | Result |
|:---|:---|:---|
| A. Graph construction | 1 to 3 | Each routed DEF is converted into a routing graph per net, with the driver and the sinks taken from the LEF and DEF pin directions. |
| B. Graph features | 4 | The per-design tables are merged and extended with features. |

Usage, inputs and outputs are in Section 6. The training flow, which uses the SPEF, is in `../build_training_dataset`.

---

# Part A. Graph Construction

## 1. Routing Graph

The graph `G_DEF` is built from the routed DEF in the same way as in the training flow. Nodes are pins and Steiner points. Edges are the routed wire segments between them.

- A wire is cut wherever a via or a pin lies strictly inside it, so that every connection becomes a node of the graph.
- Each pin attaches to its connecting wire point, chosen in this order:
  1. the end of a via whose shape overlaps a pin shape on the same layer,
  2. a wire point inside a pin shape,
  3. the closest wire point within a tolerance.
- Vias that the DEF defines itself (the `VIAS` section written by Innovus) are read from the DEF.
- When the router lands several vias or wires on the same pin shape, the pin metal connects them but the DEF routing does not. One synthetic pin-metal segment from the primary pin point to each extra contact point joins them. Its layer is the pin layer, so its length counts as wire on that layer.
- A *Steiner point* is a non-pin wire point where three or more wire pieces meet.
- An edge may bend or change layer between its two end nodes. Intermediate points stay inside the edge, together with the length and layer of each piece.


There is no SPEF tree to align with, so no virtual Steiner points, additional nodes or zero-length edges are created. A wire that runs through a pin is simply cut there, and a pin is a plain node of the graph. 

## 2. Driver and Sinks

Without the SPEF the driver is taken from the pin directions.

| Pin type | Source of the direction | Role |
|:---|:---|:---|
| Cell pin | `DIRECTION` of the pin in the cell LEF | `OUTPUT` is the driver of the net |
| Top-level port | `DIRECTION` in the DEF `PINS` section | `INPUT` is the driver of the net |
| Fallback | none known | the first pin of the net |

All other pins of the net are sinks. A tree is rooted at the driver and the node depth is the number of edges from it. Nodes that the driver cannot reach start a second walk from the node of highest degree of their component.

## 3. Node Names

| Node | Name |
|:---|:---|
| Cell pin | `instance/pin` |
| Top-level port | the port name |
| Steiner point | `net/<k>` with a running number `k`, which `add_cell_types.py` recognizes as an internal node |

The names are written directly, because there is no SPEF name map.

---

# Part B. Graph Features

## 4. Graph Features

| Feature group | Content |
|:---|:---|
| Node features | Local geometry (incident wire length and via count per layer), tree position (driver depth, downstream sink count and wirelength, Manhattan distance to the driver and to the nearest sink), node type, node degree, and the standard-cell type of the pin. |
| Edge features | Routed length and via count per layer, downstream sink count, and the edge's length as a fraction of total net wirelength. |
| Pin capacitance | The library pin capacitance `C_pin_liberty_pf` is added to every node (zero for driver pins). |
| Reference delay | `elmore_gt_ps = -1` and `has_elmore = 0` for every node. The OpenSTA Elmore delay is added only with `--delays-dir`, as an evaluation label and never as a feature. |

The columns `R_ohms`, `C_edge_pf` and `C_node_pf` exist in the per-design tables with the same schema as in the training flow but are empty. They are dropped from the processed tables, and the inference scripts zero-fill missing target columns.

# 5. Usage

## Inputs

| Input | Content | Source |
|:---|:---|:---|
| `--pairs-dir` | One folder per case with the routed `<design>.def`. Only the DEF is read. The folder name is the case name `<design>_<tcp>_<util>_<ar>`, with `-blockages` added for runs with routing blockages, e.g., `aes_cipher_top_0.9_0.4_1.0`. The design is the part before `_<tcp>`, and `--design` selects the cases by it. | `scripts/invs_scripts` (`run_sweep.sh`) |
| `data/configs/ng45_lef_geometry.json` | LEF geometry of the library. | repository |
| Cell LEFs | `scripts/invs_scripts/tech/ng45/lef` (the driver directions come from them). Override the folder with `INVS_INPUTS`. | repository |
| `--lib-cap-json` | Library input-pin capacitances (default `data/configs/ng45_pin_capacitance.json`). | repository |
| `--delays-dir` (optional) | One folder per case with `elmore_delays.csv`, from `ORIGINAL_BASE=<pairs dir> scripts/opensta_scripts/run_opensta_elmore.sh --jobs 8`. | OpenSTA |

NanGate45 uses 2000 DBU per um.

## Command

```bash
./build_testing_dataset.sh --pairs-dir <pairs dir> --case aes_cipher_top_0.9_0.4_1.0 --work test_work                  # one case
./build_testing_dataset.sh --pairs-dir <pairs dir> --design aes_cipher_top,ibex_core --jobs 4 --work test_work          # all cases of the designs
./build_testing_dataset.sh --pairs-dir <pairs dir> --design aes_cipher_top --delays-dir <delays dir> --work test_work   # with Elmore labels
```

| Option | Meaning | Default |
|:---|:---|:---|
| `--case NAME` | A single case (repeatable) | |
| `--design NAMES` | All cases of these designs, comma-separated | |
| `--jobs` | Designs extracted in parallel | 4 |
| `--work` | Output folder | `./test_work` |
| `--part i/N` | Run only the i-th of N interleaved slices of the case list, to split the work over several servers | |
| `--delays-dir` | Add the Elmore reference delays | |
| `--lib-cap-json` | Library pin capacitances | `data/configs/ng45_pin_capacitance.json` |

## Outputs

- `<work>/processed/processed_segments.csv` and `<work>/elmore/annotated_nodes_with_elmore.csv` are the inputs of `models/*/run_inference.py`.
- Intermediate tables are in `<work>/csv`, `<work>/enhanced-csv` and `<work>/annotated`. Logs are in `<work>/logs`.

The default run uses no STA or SPEF output. The OpenSTA delays are needed only to compare predicted timing with the Commercial reference (CommRef) timing later.
