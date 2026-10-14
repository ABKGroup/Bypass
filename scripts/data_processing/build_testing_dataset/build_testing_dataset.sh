#!/bin/bash
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PAIRS=""; DESIGNS=(); CASES=(); JOBS=4; WORK="$PWD/test_work"; PART=""; DELAYS_DIR=""; LIB_CAP_JSON=""
while [[ $# -gt 0 ]]; do case "$1" in
  --pairs-dir)    PAIRS="${2:?}"; shift 2 ;;
  --design)       IFS=, read -ra _d <<< "${2:?}"; DESIGNS+=("${_d[@]}"); shift 2 ;;
  --case)         CASES+=("${2:?}"); shift 2 ;;
  --jobs)         JOBS="${2:?}"; shift 2 ;;
  --work)         WORK="${2:?}"; shift 2 ;;
  --part)         PART="${2:?}"; shift 2 ;;
  --delays-dir)   DELAYS_DIR="${2:?}"; shift 2 ;;
  --lib-cap-json) LIB_CAP_JSON="${2:?}"; shift 2 ;;
  -h|--help)      sed -n '2,14p' "$0"; exit 0 ;;
  *) echo "ERROR: unknown argument: $1"; exit 1 ;;
esac; done

[[ -n "$PAIRS" ]] || { echo "ERROR: need --pairs-dir DIR (folder with <case>/*.def)"; exit 1; }
[[ -d "$PAIRS" ]] || { echo "ERROR: pairs dir not found: $PAIRS"; exit 1; }

if [[ ${#CASES[@]} -eq 0 ]]; then
  [[ ${#DESIGNS[@]} -gt 0 ]] || { echo "ERROR: need --design <name[,name]> or --case <name>"; exit 1; }
  for d in "${DESIGNS[@]}"; do
    for dir in "$PAIRS"/*/; do
      n="$(basename "$dir")"       # case folders are named <design>_<tcp>_<util>_<ar>[-blockages] by run_sweep.sh
      [[ "$n" =~ ^${d}_[0-9.]+_[0-9.]+_[0-9.]+(-blockages)?$ ]] && CASES+=("$n")
    done
  done
fi
[[ ${#CASES[@]} -gt 0 ]] || { echo "ERROR: no cases found in $PAIRS"; exit 1; }
if [[ -n "$PART" ]]; then
  [[ "$PART" =~ ^([1-9][0-9]*)/([1-9][0-9]*)$ ]] || { echo "ERROR: --part must look like 1/2"; exit 1; }
  mapfile -t CASES < <(printf '%s\n' "${CASES[@]}" | sort | awk -v i="${BASH_REMATCH[1]}" -v n="${BASH_REMATCH[2]}" '(NR-1)%n==i-1')
  [[ ${#CASES[@]} -gt 0 ]] || { echo "ERROR: no cases in this part"; exit 1; }
fi

ARGS=(--pairs-dir "$PAIRS" --cases "$(IFS=,; echo "${CASES[*]}")" --jobs "$JOBS" --work "$WORK")
[[ -z "$DELAYS_DIR" ]]   || ARGS+=(--delays-dir "$DELAYS_DIR")
[[ -z "$LIB_CAP_JSON" ]] || ARGS+=(--lib-cap-json "$LIB_CAP_JSON")
exec bash "$HERE/extract_features/extract_features.sh" "${ARGS[@]}"
