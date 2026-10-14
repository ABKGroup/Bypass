#!/bin/bash
# extract_design_features.sh - per-design steps from the routed DEF and the LEF: process_LEF_DEF.py,
# then add_topological_features.py. Run from the work directory, it writes ./csv and ./enhanced-csv.
# Usage:  PAIRS_BASE=<dir> ./extract_design_features.sh <case_dir_name>
set -euo pipefail

BASE_PATH="${PAIRS_BASE:?set PAIRS_BASE to the dir holding the case dirs}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTRACTOR="${SCRIPT_DIR}/process_LEF_DEF.py"
TOPO="${SCRIPT_DIR}/add_topological_features.py"

# 500 DBU = 0.25 um at 2000 DBU/um (NanGate45)
export MAX_DIST_DBU="${MAX_DIST_DBU:-500}"

DIR_RAW="csv"; DIR_ENHANCED="enhanced-csv"
[[ $# -eq 1 ]] || { echo "Usage: $0 <case_dir_name>"; exit 1; }
DIR="$1"; INPUT_DIR="${BASE_PATH}/${DIR}"
[[ -d "$INPUT_DIR" ]] || { echo "ERROR: Directory not found: $INPUT_DIR"; exit 1; }
mkdir -p "$DIR_RAW" "$DIR_ENHANCED"

DEF_FILE=$(find "$INPUT_DIR" -name "*.def" | head -n 1)
[[ -n "$DEF_FILE" ]] || { echo "ERROR: No DEF found in $INPUT_DIR"; exit 1; }

RAW_EDGE_CSV="${DIR_RAW}/output_${DIR}.csv"
RAW_NODE_CSV="${DIR_RAW}/output_${DIR}_nodes.csv"
TOPO_EDGE_CSV="${DIR_RAW}/output_${DIR}_topo.csv"
TOPO_NODE_CSV="${DIR_RAW}/output_${DIR}_nodes_topo.csv"

if [[ -f "$RAW_NODE_CSV" ]]; then
    echo "INFO: $DIR: feature extraction skipped, $RAW_NODE_CSV already exists"
else
    echo "INFO: $DIR: DEF/LEF feature extraction"
    python3 "$EXTRACTOR" ${LEF_JSON:+--lef-json "$LEF_JSON"} "$DEF_FILE" --output_csv "$RAW_EDGE_CSV"
    [[ -f "$RAW_NODE_CSV" ]] || { echo "ERROR: $DIR: feature extraction failed"; exit 1; }
fi

if [[ -f "$TOPO_EDGE_CSV" ]]; then
    echo "INFO: $DIR: topological features skipped, $TOPO_EDGE_CSV already exists"
else
    echo "INFO: $DIR: topological features"
    python3 "$TOPO" --edge_csv "$RAW_EDGE_CSV" --node_csv "$RAW_NODE_CSV" \
        --output_edge "$TOPO_EDGE_CSV" --output_node "$TOPO_NODE_CSV"
    [[ -f "$TOPO_EDGE_CSV" ]] || { echo "ERROR: $DIR: topological features failed"; exit 1; }
fi

cp "$TOPO_EDGE_CSV" "${DIR_ENHANCED}/output_${DIR}.csv"
cp "$TOPO_NODE_CSV" "${DIR_ENHANCED}/output_${DIR}_nodes.csv"
echo "INFO: $DIR done ($TOPO_EDGE_CSV, $TOPO_NODE_CSV)"
