#!/bin/bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "${HERE}/../../.." && pwd)"

DESIGNS="" ; PAIRS_DIR="" ; DELAYS_DIR="" ; LIB_CAP_JSON="" ; WORK="$PWD/training_work" ; JOBS=4 ; BATCHES=4
usage () { sed -n '2,25p' "$0"; exit "${1:-1}"; }
while [[ $# -gt 0 ]]; do case "$1" in
  --designs)      DESIGNS="$2"; shift 2 ;;
  --pairs-dir)    PAIRS_DIR="$2"; shift 2 ;;
  --delays-dir)   DELAYS_DIR="$2"; shift 2 ;;
  --lib-cap-json) LIB_CAP_JSON="$2"; shift 2 ;;
  --work)         WORK="$2"; shift 2 ;;
  --jobs)         JOBS="$2"; shift 2 ;;
  --batches)      BATCHES="$2"; shift 2 ;;
  -h|--help)      usage 0 ;;
  *) echo "ERROR: unknown argument: $1"; usage ;;
esac; done
LIB_CAP_JSON="${LIB_CAP_JSON:-${REPO}/data/configs/ng45_pin_capacitance.json}"
for v in DESIGNS PAIRS_DIR DELAYS_DIR LIB_CAP_JSON; do
  [[ -n "${!v}" ]] || { echo "ERROR: missing argument for $v"; usage; }
done
[[ -f "$DESIGNS" ]]      || { echo "ERROR: --designs file not found: $DESIGNS"; exit 1; }
[[ -d "$PAIRS_DIR" ]]    || { echo "ERROR: --pairs-dir not found: $PAIRS_DIR"; exit 1; }
[[ -d "$DELAYS_DIR" ]]   || { echo "ERROR: --delays-dir not found: $DELAYS_DIR"; exit 1; }
[[ -f "$LIB_CAP_JSON" ]] || { echo "ERROR: --lib-cap-json not found: $LIB_CAP_JSON"; exit 1; }

mkdir -p "$WORK"; WORK="$(realpath "$WORK")"
DESIGNS="$(realpath "$DESIGNS")"

echo "INFO: [1/2] Extracting the features (extract_features/extract_features.sh)"
bash "$HERE/extract_features/extract_features.sh" --design-list "$DESIGNS" --pairs-dir "$PAIRS_DIR" --delays-dir "$DELAYS_DIR" \
     --lib-cap-json "$LIB_CAP_JSON" --jobs "$JOBS" --work "$WORK"

echo "INFO: [2/2] Scaling and folding the capacitance (fold_capacitance/build_final_dataset.sh)"
WORK="$WORK" DESIGN_LIST="$DESIGNS" PAIRS_BASE="$WORK/pairs_flat" bash "$HERE/fold_capacitance/build_final_dataset.sh" "$BATCHES"

echo "INFO: Training set written to $WORK/collapsed/ (collapsed_segments.csv, collapsed_nodes.csv)"
