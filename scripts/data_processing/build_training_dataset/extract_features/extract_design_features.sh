#!/bin/bash
set -euo pipefail

# Configuration
# PAIRS_BASE : folder with <design>/{*.def,*.spef} (set by extract_features.sh)
# LEF_JSON   : LEF geometry of the library as JSON (default: data/configs/ng45_lef_geometry.json of this repository)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
BASE_PATH="${PAIRS_BASE:?set PAIRS_BASE to the folder that holds the <design>/ folders}"
LEF_JSON="${LEF_JSON:-${REPO}/data/configs/ng45_lef_geometry.json}"
DBU=2000 # NanGate45: 2000 DBU per micron
EXTRACTOR="${SCRIPT_DIR}/process_LEF_DEF_SPEF.py"
TOPO="${SCRIPT_DIR}/add_topological_features.py"

DIR_RAW="csv"
DIR_ENHANCED="enhanced-csv"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <case_dir_name>"
    echo "Example: $0 jpeg_encoder_10_0.7_1.2"
    exit 1
fi

DIR="$1"
INPUT_DIR="${BASE_PATH}/${DIR}"

[[ -d "$INPUT_DIR" ]] || { echo "ERROR: Directory not found: $INPUT_DIR"; exit 1; }

mkdir -p "$DIR_RAW" "$DIR_ENHANCED"

# Find input files
DEF_FILE=$(find "$INPUT_DIR"  -name "*.def"  | head -n 1)
SPEF_FILE=$(find "$INPUT_DIR" -name "*.spef" | head -n 1)

[[ -n "$DEF_FILE"  ]] || { echo "ERROR: No DEF found in $INPUT_DIR";  exit 1; }
[[ -n "$SPEF_FILE" ]] || { echo "ERROR: No SPEF found in $INPUT_DIR"; exit 1; }

# Derived file paths
RAW_EDGE_CSV="${DIR_RAW}/output_${DIR}.csv"
RAW_NODE_CSV="${DIR_RAW}/output_${DIR}_nodes.csv"
TOPO_EDGE_CSV="${DIR_RAW}/output_${DIR}_topo.csv"
TOPO_NODE_CSV="${DIR_RAW}/output_${DIR}_nodes_topo.csv"


# Step 1: RC Extraction
if [[ -f "$RAW_EDGE_CSV" ]]; then
    echo "INFO: $DIR: RC extraction skipped, $RAW_EDGE_CSV already exists"
else
    echo "INFO: $DIR: RC extraction"
    python3 "$EXTRACTOR" \
        --lef-json "$LEF_JSON" \
        "$DBU" \
        "$DEF_FILE" \
        "$SPEF_FILE" \
        --output_csv "$RAW_EDGE_CSV"

    [[ -f "$RAW_EDGE_CSV" ]] || {
        echo "ERROR: $DIR: RC extraction failed"; exit 1; }
fi

# Step 2: Node names + topological features
if [[ -f "$TOPO_EDGE_CSV" ]]; then
    echo "INFO: $DIR: topological features skipped, $TOPO_EDGE_CSV already exists"
else
    echo "INFO: $DIR: node names and topological features"
    python3 "$TOPO" \
        --edge_csv    "$RAW_EDGE_CSV"    \
        --node_csv    "$RAW_NODE_CSV"    \
        --spef        "$SPEF_FILE"       \
        --output_edge "$TOPO_EDGE_CSV"   \
        --output_node "$TOPO_NODE_CSV"

    [[ -f "$TOPO_EDGE_CSV" ]] || {
        echo "ERROR: $DIR: topological features failed"; exit 1; }
fi

# Copy final outputs into the directory the aggregation in extract_features.sh will scan
cp "$TOPO_EDGE_CSV" "${DIR_ENHANCED}/output_${DIR}.csv"
cp "$TOPO_NODE_CSV" "${DIR_ENHANCED}/output_${DIR}_nodes.csv"

echo "INFO: $DIR done ($TOPO_EDGE_CSV, $TOPO_NODE_CSV)"
