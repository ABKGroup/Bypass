#!/bin/bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="${WORK:-$PWD}"
FOLD="$HERE/fold_node_capacitance.py"
SCALE="$HERE/scale_to_spef_capacitance.py"
DESIGN_LIST="${DESIGN_LIST:-$HERE/../training_designs.txt}"
SEG="$WORK/processed/processed_segments.csv"
NODE="$WORK/annotated_nodes_with_elmore.csv"
SEG_SCALED="${SEG%.csv}_scaled.csv"
NODE_SCALED="${NODE%.csv}_scaled.csv"
OUT="$WORK/collapsed"
NB="${1:-4}"

[ -n "${PAIRS_BASE:-}" ] || { echo "ERROR: set PAIRS_BASE to the folder that holds the <design>/*.spef files"; exit 1; }
[ -s "$SEG" ]  || { echo "ERROR: missing $SEG";  exit 1; }
[ -s "$NODE" ] || { echo "ERROR: missing $NODE (run add_reference_delays.py first)"; exit 1; }
[ -s "$DESIGN_LIST" ] || { echo "ERROR: missing $DESIGN_LIST"; exit 1; }

# Step 1: capacitance fix against the golden SPEF
if [ -s "$SEG_SCALED" ] && [ -s "$NODE_SCALED" ]; then
  echo "INFO: Capacitance scaling skipped, $SEG_SCALED and $NODE_SCALED already exist"
else
  echo "INFO: Scaling the capacitance of $SEG to the golden SPEF"
  python3 -u "$SCALE" --seg "$SEG" --node "$NODE" --spef-root "$PAIRS_BASE" --write-csv
  [ -s "$SEG_SCALED" ] && [ -s "$NODE_SCALED" ] || { echo "ERROR: scale_to_spef_capacitance.py did not write $SEG_SCALED / $NODE_SCALED"; exit 1; }
fi

# Step 2: fold, in batches
mapfile -t RUNS < <(
  grep -vE '^\s*(#|$)' "$DESIGN_LIST" | while read -r p; do basename "$p"; done
)
echo "INFO: Folding ${#RUNS[@]} runs in $NB batches"

mkdir -p "$OUT"
declare -a PIDS=()
for ((b=0; b<NB; b++)); do
  BR=(); for ((i=b; i<${#RUNS[@]}; i+=NB)); do BR+=("${RUNS[$i]}"); done
  mkdir -p "$OUT/build_b$b"
  echo "INFO: Batch $b (${#BR[@]} runs): ${BR[*]}"
  env -u LD_LIBRARY_PATH nohup python3 -u "$FOLD" \
      --seg-csv "$SEG_SCALED" --node-csv "$NODE_SCALED" \
      --out-dir "$OUT/build_b$b" --runs "${BR[@]}" \
      > "$OUT/build_b$b.log" 2>&1 &
  PIDS+=($!)
done
echo "INFO: Batches started, logs in $OUT/build_b*.log"

FAIL=0
for p in "${PIDS[@]}"; do wait "$p" || FAIL=1; done
[ "$FAIL" -eq 0 ] || { echo "ERROR: a batch failed, see $OUT/build_b*.log"; exit 1; }

echo "INFO: Concatenating the batches"
for kind in segments nodes; do
  first=1
  : > "$OUT/collapsed_${kind}.csv"
  for ((b=0; b<NB; b++)); do
    f="$OUT/build_b$b/collapsed_${kind}.csv"
    [ -s "$f" ] || { echo "ERROR: missing $f"; exit 1; }
    if [ "$first" -eq 1 ]; then cat "$f" >> "$OUT/collapsed_${kind}.csv"; first=0
    else tail -n +2 "$f" >> "$OUT/collapsed_${kind}.csv"; fi
  done
  echo "INFO: Wrote $OUT/collapsed_${kind}.csv ($(($(wc -l < "$OUT/collapsed_${kind}.csv") - 1)) rows)"
done
