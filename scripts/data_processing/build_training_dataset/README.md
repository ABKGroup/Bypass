# Training Dataset Construction

The Bypass training dataset is built from routed NanGate45 designs. The input is a set of matched DEF-SPEF pairs. The output is, for every net, a routed-net graph with per-node and per-edge feature vectors and edge-level Commercial reference (CommRef) `R_edge` and `C_edge` supervision. The procedure runs on every net of every design and has three parts.

| Part | Sections | Result |
|:---|:---|:---|
| A. Topology alignment | 1 to 4 | Each routed DEF wire segment is mapped onto its RC path in the SPEF, which gives the labels. |
| B. Graph features | 5 | The aligned tables of all designs are merged and extended with features. |
| C. Capacitance processing | 6 to 7 | A *capacitance scaling* and a *node-to-edge fold* give the edge-only representation that Bypass predicts. |

Usage, inputs and outputs are in Section 8.

---

# Part A. Topology Alignment

## 1. Graph Construction

**DEF routing graph `G_DEF`.** Nodes are pins and Steiner points. Edges are the routed wire segments between them.

- A wire is cut wherever a via or a pin lies strictly inside it, so that every connection becomes a node of the graph.
- Each pin attaches to its connecting wire point, chosen in this order:
  1. the end of a via whose shape overlaps a pin shape on the same layer,
  2. a wire point inside a pin shape,
  3. the closest wire point within a tolerance.
- A *Steiner point* is a non-pin wire point where three or more wire pieces meet.
- An edge may bend or change layer between its two end nodes. Intermediate points stay inside the edge, together with the length and layer of each piece.

**SPEF RC tree `G_SPEF`.** The SPEF stores the same net as an RC tree with one node per extraction resistor, so `G_SPEF` has many more nodes than `G_DEF`. Chains of non-pin nodes with exactly two neighbors are collapsed into single edges. Each collapsed edge carries the sum of the absorbed resistances and the sum of the absorbed node capacitances. Only pins and branching points remain.

## 2. Reachable Sets

Matching each DEF edge to its ground-truth `R_edge` and `C_edge` in the SPEF is not always structurally direct. Three mismatches occur.

- DEF may preserve a Steiner junction that SPEF collapses.
- A via stack may be split across nodes in one representation and merged in the other.
- A via branch point may fall on the same coordinate as a pin.

We resolve these mismatches with a topology-preserving alignment based on *reachable sets*. For a node `v` in a net's routing tree rooted at the driver, `S(v)` is the set of pin names reachable from `v` by traversing edges away from the driver. Two nodes with equal reachable sets are treated as the same location.

## 3. Alignment Algorithm

Pins are matched by name, Steiner nodes by reachable-set equality, and any SPEF node left unmatched is restored as an additional node on the DEF edge whose reachable set contains it.

```
Input : DEF routing graph G_DEF, SPEF RC tree G_SPEF, pins P
Output: node map phi (DEF node -> SPEF node), edge map psi (DEF edge -> SPEF path)

1. Build G_DEF and G_SPEF topologies.
2. Insert virtual Steiner points at co-located pin/via junctions.
3. d <- driver pin.
   Compute S_DEF(v) and S_SPEF(n) for all nodes via DFS from d.
4. Match pins p in P by name:              phi(p) <- n in G_SPEF.
   Match Steiner nodes by reachable set:   phi(s) <- n  s.t.  S_DEF(s) = S_SPEF(n).
5. For each unmatched n in G_SPEF:
       identify DEF edge (u, v)  s.t.  S_SPEF(n) is a proper subset of S_DEF(u);
       insert additional node k into (u, v) and set phi(k) <- n.
6. For each DEF edge e = (u, v):
       psi(e) <- resistive path in G_SPEF between phi(u) and phi(v).
return phi, psi
```

| Step | Note |
|:---|:---|
| 1. Driver | The driver `d` is the SPEF node from which every pin of the net is reachable. |
| 2. Virtual Steiner point | When a via branch point falls on the same coordinate as a pin, a virtual Steiner point keeps the branch and the pin as separate nodes. It connects to its physical DEF node through a *zero-length edge*, a synthetic edge of zero physical length, so the reachable-set computation still treats both as a single location. |
| 3. Reachable sets | `S(v)` contains the pins in the subtree of `v`, excluding the driver. A virtual Steiner point and its physical node do not propagate pins to each other, so their sets remain distinguishable. |
| 4. Matching | Pins are matched by name and Steiner nodes by reachable-set equality. A DEF node left unmatched between two mapped neighbors inherits the SPEF node of those neighbors. |
| 5. Additional nodes | When a SPEF branching point was collapsed during DEF routing, i.e., its reachable set is a proper subset of an existing DEF node's set, an additional node is inserted into the corresponding DEF edge to restore it. The cut is placed at the coordinate of a neighboring pin when one lies on the edge, and otherwise at the same fraction of the path resistance. The additional node connects to its physical position through a zero-length edge. |
| 6. Edge map | Once all nodes are matched, `psi` records, for each collapsed DEF edge `(p1, p2)`, the corresponding SPEF node pair `(n1, n2)` and the SPEF tree path between them. |

## 4. Edge and Node Labels

| Label | Rule |
|:---|:---|
| Resistance | `R_edge` is the sum of SPEF resistances along `psi(e)`. A SPEF edge shared by several DEF edges is divided among them in proportion to length. |
| Capacitance | `C_edge` is the sum of the node capacitances absorbed along `psi(e)`. `C_node(v)` is the capacitance of `phi(v)`, defined for pins and branching points only. |
| Synthetic edges | Zero-length edges receive `R = 0` and `C = 0`. A short artifact edge (below 0.05 um) at a virtual Steiner point receives a fixed resistance of 0.001 Ohm. |
| Stub de-lumping | See below. |

*Stub de-lumping.* SPEF often models a pin or via drop as a single 5 to 15 Ohm resistor that lumps pin and via resistance. A DEF stub shorter than 0.15 um that is the sole user of such a resistor would otherwise receive all of it, although its wire contributes almost none. The stub keeps only its geometric resistance (0.20 Ohm/um, minimum 1 mOhm). The remainder moves to the neighboring edges that share an endpoint with the stub, so total net resistance is unchanged.

---

# Part B. Graph Features

## 5. Graph Features

| Feature group | Content |
|:---|:---|
| Node features | Local geometry (incident wire length and via count per layer), tree position (driver depth, downstream sink count and wirelength, Manhattan distance to the driver and to the nearest sink), node type, and the standard-cell type of the pin. |
| Edge features | Routed length and via count per layer, downstream sink count, and the edge's length as a fraction of total net wirelength. Virtual Steiner edges are flagged and assigned a fixed resistance rather than a measured value. |
| Reference delay | The OpenSTA Elmore delay of every sink pin (`elmore_gt_ps`, `has_elmore`) is the label of the timing loss. |
| Pin capacitance | The library pin capacitance `C_pin_liberty_pf` is added to every node (zero for driver pins). |

---

# Part C. Capacitance Processing

## 6. Capacitance Scaling

SPEF tree collapse and alignment can lose a small fraction of a net's capacitance, so `sum_e C_edge + sum_v C_node` can fall below the CommRef SPEF total. For each net, the scale factor is

```
scale = C_SPEF / (sum_e C_edge(e) + sum_v C_node(v)),     clipped to [0.9, 3.0]
```

where `C_SPEF` is the total capacitance in the `*D_NET` line of the CommRef SPEF. All `C_edge` and `C_node` values of the net are multiplied by `scale`, so the missing capacitance is added in proportion to where capacitance already sits. Most nets have `scale = 1`, and only the tail receives a correction.

| Output | Content |
|:---|:---|
| `scale_report.csv` | Per net: table total, SPEF total, raw ratio, applied scale and segment count. |
| `scale_factors.csv` | Applied scale per `net_key`. |
| `processed_segments_scaled.csv`, `annotated_nodes_with_elmore_scaled.csv` | Scaled tables, written next to the inputs. |

The run prints, for each design, the fraction of CommRef capacitance covered before and after scaling.

## 7. Node-to-Edge Capacitance Fold

Alignment produces `C_edge` for every edge and `C_node` for every node, but Bypass predicts capacitance only at the edge level. We therefore fold each node's capacitance into its incident edges and eliminate `C_node` as a separate prediction target. In the collapsed representation only pins and Steiner points remain as nodes. For a node `v` with `deg(v)` incident edges,

```
share(v) = C_node(v) / deg(v)
```

is added to the `C_edge` of each incident edge, and `C_node(v)` is set to zero. The fold preserves each net's total capacitance `sum_e C_edge + sum_v C_node`, but is not exact for individual arc delays.



*Conservation check.* For every net, the script compares total capacitance after the fold with total capacitance before it and reports the worst error over all nets. The error is at floating-point rounding level.

*Batches.* The tables of all training runs are large (several GB), so the fold processes runs in batches.

1. Runs are read from the design list (`training_designs.txt`) and assigned round-robin to `N` batches.
2. Each batch reads the scaled tables in chunks, keeps only the rows of its runs, and applies the fold net by net. It writes `collapsed_segments.csv`, `collapsed_nodes.csv` and `run_summary.json` (runs used, row counts, conservation error, elapsed time).
3. Batches run in parallel. Their tables are concatenated into a single `collapsed_segments.csv` and `collapsed_nodes.csv` with one header each.

A requested run that is missing from either table is replaced by a sibling run of the same family, and the substitution is reported. If no sibling exists, the script stops.

---

# 8. Usage

## Inputs

| Input | Content | Source |
|:---|:---|:---|
| `--pairs-dir` | One folder per design with `<design>.def`, `<design>.spef` and `<design>.v`. | `scripts/invs_scripts` (`run_sweep.sh`) |
| `--delays-dir` | One folder per design with `elmore_delays.csv`, the OpenSTA Elmore delay of every driver-to-load arc on the CommRef SPEF. | `scripts/opensta_scripts/run_opensta_elmore.sh` |
| `--designs` | The cases to use, one per line. | `training_designs.txt` (41 training runs) |
| `data/configs/ng45_lef_geometry.json` | LEF geometry of the library. | repository |
| `--lib-cap-json` | Library input-pin capacitances (default `data/configs/ng45_pin_capacitance.json`). | repository, rebuilt with `parse_liberty.py` |

- Each folder name in `--pairs-dir` is the case name, e.g., `aes_cipher_top_10_0.7_1.2`, with the suffix `-blockages` for runs with routing blockages.
- The delays are generated with `ORIGINAL_BASE=<pairs dir> BASE_REPORT_DIR=<delays dir> scripts/opensta_scripts/run_opensta_elmore.sh`.
- The CommRef SPEF must come from an extraction without coupling capacitance, so that every net total is a ground capacitance.

## Command

```bash
./build_training_dataset.sh --designs training_designs.txt --pairs-dir <pairs dir> --delays-dir <delays dir> \
                            [--lib-cap-json FILE] [--work DIR] [--jobs N] [--batches N]
```

| Option | Meaning | Default |
|:---|:---|:---|
| `--jobs` | Designs extracted in parallel | 4 |
| `--batches` | Fold batches | 4 |
| `--work` | Output folder | `./training_work` |

Finished per-design outputs and finished scaling are reused when a run is restarted.

## Outputs

- `<work>/collapsed/collapsed_segments.csv` and `<work>/collapsed/collapsed_nodes.csv` are the input of `models/bypass/train.py` (set `TRAINING_WORK` to the work folder).
- Per-batch tables remain in `<work>/collapsed/build_b<k>/`.
- Intermediate tables are in `<work>/csv`, `<work>/enhanced-csv`, `<work>/processed` and `<work>/annotated`. Logs are in `<work>/logs`.

The test designs have no SPEF and are processed by `../build_testing_dataset`.