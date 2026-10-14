#!/bin/bash
set -uo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "${SCRIPTS}/../../../.." && pwd)"

DESIGN_LIST="" ; PAIRS_DIR="" ; DELAYS_DIR="" ; LIB_CAP_JSON="" ; JOBS=4 ; WORK="$PWD/training_work" ; DO_POST=1
while [[ $# -gt 0 ]]; do case "$1" in
  --design-list)      DESIGN_LIST="$2"; shift 2 ;;
  --pairs-dir)        PAIRS_DIR="$2"; shift 2 ;;
  --delays-dir)       DELAYS_DIR="$2"; shift 2 ;;
  --lib-cap-json)     LIB_CAP_JSON="$2"; shift 2 ;;
  --jobs)             JOBS="$2"; shift 2 ;;
  --work)             WORK="$2"; shift 2 ;;
  --skip-postprocess) DO_POST=0; shift ;;
  -h|--help)          sed -n '2,34p' "$0"; exit 0 ;;
  *) echo "ERROR: unknown argument: $1"; exit 1 ;;
esac; done
[[ -f "$DESIGN_LIST" ]] || { echo "ERROR: need --design-list FILE (got: '$DESIGN_LIST')"; exit 1; }
DESIGN_LIST="$(realpath "$DESIGN_LIST")"
mkdir -p "$WORK"; WORK="$(realpath "$WORK")"   

mapfile -t RAW < <(grep -vE '^\s*(#|$)' "$DESIGN_LIST")
[[ "${#RAW[@]}" -gt 0 ]] || { echo "ERROR: design list has no entries"; exit 1; }

STAGE="${WORK}/pairs_flat"
rm -rf "$STAGE"; mkdir -p "$STAGE" "$WORK/logs"
declare -a NAMES=()
for src in "${RAW[@]}"; do
  src="${src%/}"
  [[ -d "$src" || -z "$PAIRS_DIR" ]] || src="${PAIRS_DIR%/}/$src"
  [[ -d "$src" ]] || { echo "WARNING: missing dir, skipped: $src"; continue; }
  src="$(realpath "$src")"
  name="$(basename "$src")"
  mkdir -p "${STAGE}/${name}"
  for f in "$src"/*.def "$src"/*.spef "$src"/*.v; do
    [[ -e "$f" ]] && ln -sf "$f" "${STAGE}/${name}/"
  done
  dn="$(printf '%s' "$name" | sed -E 's/_[0-9].*$//')"
  rd="$(ls "$src"/*.def 2>/dev/null | head -1)"
  [[ -n "$rd" && ! -e "${STAGE}/${name}/${dn}.def" ]] && ln -sf "$rd" "${STAGE}/${name}/${dn}.def"
  NAMES+=("$name")
done
[[ "${#NAMES[@]}" -gt 0 ]] || { echo "ERROR: nothing staged"; exit 1; }
if [[ -n "$DELAYS_DIR" ]]; then
  [[ -d "$DELAYS_DIR" ]]    || { echo "ERROR: --delays-dir not found: $DELAYS_DIR"; exit 1; }
  [[ -n "$LIB_CAP_JSON" ]] || LIB_CAP_JSON="${REPO}/data/configs/ng45_pin_capacitance.json"
  [[ -f "$LIB_CAP_JSON" ]]  || { echo "ERROR: --delays-dir needs --lib-cap-json FILE (got: '$LIB_CAP_JSON')"; exit 1; }
  DELAYS_DIR="$(realpath "$DELAYS_DIR")"; LIB_CAP_JSON="$(realpath "$LIB_CAP_JSON")"
fi
echo "INFO: Staged ${#NAMES[@]} designs in $STAGE"

cd "$WORK"
export PAIRS_BASE="$STAGE"

aggregate_designs () {
  local ENH="enhanced-csv" PROC="processed" ANN="annotated"
  mkdir -p "$PROC" "$ANN"
  local N; N=$(find "$ENH" -name "output_*.csv" ! -name "*_nodes*" | wc -l)
  [[ "$N" -gt 0 ]] || { echo "ERROR: No CSV files found in $ENH"; return 1; }

  echo "INFO: Preprocessing all designs"
  PREPROCESS_ENHANCED_DIR="$(realpath "$ENH")" PREPROCESS_OUTPUT_DIR="$(realpath "$PROC")" \
      python3 "${SCRIPTS}/preprocess.py" || { echo "ERROR: preprocessing failed"; return 1; }
  [[ -f "$PROC/processed_segments.csv" && -f "$PROC/processed_nodes.csv" ]] \
      || { echo "ERROR: processed CSVs not created"; return 1; }

  echo "INFO: Annotating the cell types"
  python3 "${SCRIPTS}/add_cell_types.py" --nodes_csv "$PROC/processed_nodes.csv" --pairs_base "$STAGE" \
      --out_csv "$ANN/annotated_nodes.csv" || { echo "ERROR: cell-type annotation failed"; return 1; }
  [[ -f "$ANN/annotated_nodes.csv" ]] || { echo "ERROR: cell-type annotation failed"; return 1; }
  echo "INFO: Aggregation done ($PROC/processed_segments.csv, $ANN/annotated_nodes.csv)"
}

run_one () {
  local dir="$1"
  if bash "${SCRIPTS}/extract_design_features.sh" "$dir" > "logs/${dir}.log" 2>&1; then
    echo "INFO: $dir done"
  else
    echo "ERROR: $dir failed (see $WORK/logs/${dir}.log)"
  fi
}
export -f run_one ; export SCRIPTS WORK

printf '%s\n' "${NAMES[@]}" | xargs -P "$JOBS" -I{} bash -c 'run_one "$@"' _ {}

PASS=0; FAIL_LIST=()
for d in "${NAMES[@]}"; do
  if [[ -s "csv/output_${d}_topo.csv" ]]; then PASS=$((PASS+1)); else FAIL_LIST+=("$d"); fi
done
echo "INFO: Per-design extraction: ${PASS} of ${#NAMES[@]} passed"
[[ ${#FAIL_LIST[@]} -gt 0 ]] && printf 'ERROR: failed: %s\n' "${FAIL_LIST[@]}"
[[ ${#FAIL_LIST[@]} -eq 0 ]] || { echo "ERROR: ${#FAIL_LIST[@]} design(s) failed, see $WORK/logs/"; exit 1; }

if [[ "$DO_POST" == 1 ]]; then
  echo "INFO: Aggregating ${PASS} designs"
  aggregate_designs 2>&1 | tee "logs/postprocess.log"
fi

if [[ "$DO_POST" == 1 ]]; then
  [[ -s "$WORK/processed/processed_segments.csv" && -s "$WORK/annotated/annotated_nodes.csv" ]] \
    || { echo "ERROR: aggregation did not produce processed_segments.csv / annotated_nodes.csv, see $WORK/logs/postprocess.log"; exit 1; }
  if [[ -n "$DELAYS_DIR" ]]; then
    echo "INFO: Adding the OpenSTA Elmore delays and the library pin capacitances"
    python3 -u "${SCRIPTS}/add_reference_delays.py" --delays-dir "$DELAYS_DIR" --lib-cap-json "$LIB_CAP_JSON" \
        --nodes-csv annotated/annotated_nodes.csv --output annotated_nodes_with_elmore.csv \
        2>&1 | tee "logs/reference_delays.log"
    [[ -s "$WORK/annotated_nodes_with_elmore.csv" ]] || { echo "ERROR: add_reference_delays.py failed, see $WORK/logs/reference_delays.log"; exit 1; }
  fi
fi

echo "INFO: Wrote $WORK/processed/processed_segments.csv and the r_L / r_via warm starts (r_L_warmstart.csv, r_via_warmstart.csv)"
[[ -n "$DELAYS_DIR" ]] && echo "INFO: Wrote $WORK/annotated_nodes_with_elmore.csv"
