#!/bin/bash
# extract_features.sh - feature extraction of the test cases from the routed DEF and the LEF, without any SPEF.
# Normally started by build_testing_dataset.sh. It links the DEF of each case into <work>/pairs_flat, runs
# extract_design_features.sh per design (in parallel), then preprocess.py and add_cell_types.py, and finally
# add_pin_capacitances.py, which writes <work>/elmore/annotated_nodes_with_elmore.csv.
#
# Usage:
#   extract_features.sh --pairs-dir DIR --cases a,b,c [--jobs N] [--work DIR] [--delays-dir DIR] [--lib-cap-json FILE]
#     --pairs-dir DIR       folder with one <case>/ folder per case, the routed .def inside
#     --cases LIST          comma-separated case folder names
#     --delays-dir DIR      OpenSTA reports (<case>/elmore_delays.csv), adds the reference delays
#     --lib-cap-json FILE   library pin capacitances (default: data/configs/ng45_pin_capacitance.json)
set -uo pipefail

STEPS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "${STEPS}/../../../.." && pwd)"

PAIRS="" ; CASES_CSV="" ; DELAYS_DIR="" ; LIB_CAP_JSON="" ; JOBS=4 ; WORK="$PWD/test_work"
while [[ $# -gt 0 ]]; do case "$1" in
  --pairs-dir)    PAIRS="${2:?}"; shift 2 ;;
  --cases)        CASES_CSV="${2:?}"; shift 2 ;;
  --delays-dir)   DELAYS_DIR="${2:?}"; shift 2 ;;
  --lib-cap-json) LIB_CAP_JSON="${2:?}"; shift 2 ;;
  --jobs)         JOBS="${2:?}"; shift 2 ;;
  --work)         WORK="${2:?}"; shift 2 ;;
  -h|--help)      sed -n '2,12p' "$0"; exit 0 ;;
  *) echo "ERROR: unknown argument: $1"; exit 1 ;;
esac; done
[[ -d "$PAIRS" ]] || { echo "ERROR: --pairs-dir not found: '$PAIRS'"; exit 1; }
PAIRS="$(realpath "$PAIRS")"
[[ -n "$CASES_CSV" ]] || { echo "ERROR: need --cases a,b,c"; exit 1; }
[[ -n "$LIB_CAP_JSON" ]] || LIB_CAP_JSON="${LIB_CAP_JSON:-${REPO}/data/configs/ng45_pin_capacitance.json}"
[[ -f "$LIB_CAP_JSON" ]] || { echo "ERROR: --lib-cap-json not found: $LIB_CAP_JSON"; exit 1; }
if [[ -n "$DELAYS_DIR" ]]; then
  [[ -d "$DELAYS_DIR" ]] || { echo "ERROR: no Elmore reports in $DELAYS_DIR, run ${REPO}/scripts/opensta_scripts/run_opensta_elmore.sh --jobs 8"; exit 1; }
  DELAYS_DIR="$(realpath "$DELAYS_DIR")"
fi
IFS=, read -ra CASES <<< "$CASES_CSV"

mkdir -p "$WORK/logs"; WORK="$(realpath "$WORK")"
STAGE="${WORK}/pairs_flat"; rm -rf "$STAGE"; mkdir -p "$STAGE"
echo "INFO: Extracting the features of ${#CASES[@]} cases with $JOBS jobs (pairs $PAIRS, work $WORK)"

# only the DEF is linked
NAMES=()
for c in "${CASES[@]}"; do
  src="${PAIRS}/${c}"
  [[ -d "$src" ]] || { echo "WARNING: missing dir, skipped: $src"; continue; }
  def="$(ls "$src"/*.def 2>/dev/null | head -1)"
  [[ -n "$def" ]] || { echo "WARNING: no .def in $src, skipped"; continue; }
  mkdir -p "${STAGE}/${c}"
  ln -sf "$def" "${STAGE}/${c}/"
  # design name = case name without _<tcp>_<util>_<ar>[-blockages], the DEF name that add_cell_types.py looks for
  dn="$(printf '%s' "$c" | sed -E 's/_[0-9.]+_[0-9.]+_[0-9.]+(-blockages)?$//')"
  [[ -e "${STAGE}/${c}/${dn}.def" ]] || ln -sf "$def" "${STAGE}/${c}/${dn}.def"
  NAMES+=("$c")
done
[[ ${#NAMES[@]} -gt 0 ]] || { echo "ERROR: nothing staged"; exit 1; }
echo "INFO: Staged ${#NAMES[@]} DEF(s) in $STAGE"

cd "$WORK"
export PAIRS_BASE="$STAGE"
run_one () {
  if bash "${STEPS}/extract_design_features.sh" "$1" > "logs/$1.log" 2>&1; then echo "INFO: $1 done"
  else echo "ERROR: $1 failed (see ${WORK}/logs/$1.log)"; fi
}
export -f run_one; export STEPS WORK
printf '%s\n' "${NAMES[@]}" | xargs -P "$JOBS" -I{} bash -c 'run_one "$@"' _ {}

PASS=0; FAILS=()
for d in "${NAMES[@]}"; do
  if [[ -s "csv/output_${d}_topo.csv" ]]; then PASS=$((PASS+1)); else FAILS+=("$d"); fi
done
echo "INFO: Per-design extraction: ${PASS} of ${#NAMES[@]} passed"
[[ ${#FAILS[@]} -gt 0 ]] && printf 'ERROR: failed: %s\n' "${FAILS[@]}"
[[ ${#FAILS[@]} -eq 0 ]] || { echo "ERROR: ${#FAILS[@]} design(s) failed, see $WORK/logs/"; exit 1; }

aggregate_designs () {
  local ENH="enhanced-csv" PROC="processed" ANN="annotated"
  mkdir -p "$PROC" "$ANN"
  local N; N=$(find "$ENH" -name "output_*.csv" ! -name "*_nodes*" | wc -l)
  [[ "$N" -gt 0 ]] || { echo "ERROR: No CSV files in $ENH"; return 1; }

  echo "INFO: Preprocessing all designs"
  HAS_TARGETS=0 PREPROCESS_ENHANCED_DIR="$(realpath "$ENH")" PREPROCESS_OUTPUT_DIR="$(realpath "$PROC")" \
      python3 "${STEPS}/preprocess.py" || { echo "ERROR: preprocessing failed"; return 1; }
  [[ -f "$PROC/processed_segments.csv" && -f "$PROC/processed_nodes.csv" ]] \
      || { echo "ERROR: processed CSVs not created"; return 1; }

  echo "INFO: Annotating the cell types"
  python3 "${STEPS}/add_cell_types.py" --nodes_csv "$PROC/processed_nodes.csv" --pairs_base "$STAGE" \
      --out_csv "$ANN/annotated_nodes.csv" || { echo "ERROR: cell-type annotation failed"; return 1; }
  [[ -f "$ANN/annotated_nodes.csv" ]] || { echo "ERROR: cell-type annotation failed"; return 1; }
}
echo "INFO: Aggregating ${PASS} designs"
aggregate_designs 2>&1 | tee logs/postprocess.log
[[ -s annotated/annotated_nodes.csv ]] || { echo "ERROR: no annotated_nodes.csv, see $WORK/logs/postprocess.log"; exit 1; }

# C_pin_liberty_pf is an input feature. The Elmore delays (elmore_gt_ps) are only evaluation labels, added with --delays-dir.
mkdir -p elmore
if [[ -n "$DELAYS_DIR" ]]; then
  echo "INFO: Adding the library pin capacitances and the Elmore reference delays"
  NO_ELMORE=0 ELMORE_ROOT="$DELAYS_DIR" LIB_CAP_JSON="$LIB_CAP_JSON" python3 "${STEPS}/add_pin_capacitances.py"
else
  echo "INFO: Adding the library pin capacitances (no Elmore labels, no STA or SPEF)"
  NO_ELMORE=1 LIB_CAP_JSON="$LIB_CAP_JSON" python3 "${STEPS}/add_pin_capacitances.py"
fi
[[ -s elmore/annotated_nodes_with_elmore.csv ]] || { echo "ERROR: add_pin_capacitances.py produced nothing"; exit 1; }

echo "INFO: Wrote ${WORK}/processed/processed_segments.csv and ${WORK}/elmore/annotated_nodes_with_elmore.csv (${PASS} designs)"
