# Training Dataset Sample

A small sample of the tables the model was trained on. It shows the format that `models/bypass/train.py` reads.

| File | Content |
|:---|:---|
| `collapsed/collapsed_segments.csv` | One row per edge of the routing graph (1372 rows). Edge features, the Commercial reference (CommRef) `R_ohms` and `C_edge_pf`, and the per-layer lengths and via counts. |
| `collapsed/collapsed_nodes.csv` | One row per node (1549 rows). Node features and the node capacitance. |

The sample has 100 randomly chosen nets from each of three runs, with every edge and node of those nets.

| Run | Role in training | Routing |
|:---|:---|:---|
| `aes_cipher_top_5_0.4_1.0` | training | 5-layer stack |
| `aes_cipher_top_0.8_0.4_1.0` | training | 8-layer stack |
| `ibex_core_1.0_0.6_1.0` | validation | 8-layer stack |

The columns are identical to the full tables. These are the tables after the capacitance scaling and the node-to-edge fold, so `C_edge_pf` includes the folded node capacitance and `C_node_pf` is close to zero. The values before the fold are in `C_edge_pf_orig` and `C_node_pf_orig`. The steps are described in `scripts/data_processing/build_training_dataset/README.md`.
