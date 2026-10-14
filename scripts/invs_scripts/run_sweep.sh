#!/bin/bash
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="" ; DESIGN="" ; TCP="" ; UTIL="" ; AR="" ; JOBS=1 ; BLOCKAGES=0 ; FIVE=0
while [[ $# -gt 0 ]]; do case "$1" in
  --out-dir)    OUT_DIR="$2"; shift 2 ;;
  --design)     DESIGN="$2"; shift 2 ;;
  --tcp)        TCP="$2"; shift 2 ;;
  --util)       UTIL="$2"; shift 2 ;;
  --ar)         AR="$2"; shift 2 ;;
  --blockages)  BLOCKAGES=1; shift ;;
  --5layer)     FIVE=1; shift ;;
  --jobs)       JOBS="$2"; shift 2 ;;
  -h|--help)    sed -n '2,15p' "$0"; exit 0 ;;
  *) echo "unknown argument: $1"; exit 1 ;;
esac; done
for v in OUT_DIR DESIGN TCP UTIL AR; do [[ -n "${!v}" ]] || { echo "missing --$(echo "$v" | tr 'A-Z_' 'a-z-')"; sed -n '2,15p' "$0"; exit 1; }; done
mkdir -p "$OUT_DIR"; OUT_DIR="$(realpath "$OUT_DIR")"
[[ "$BLOCKAGES" -eq 1 && "$FIVE" -eq 1 ]] && { echo "--blockages and --5layer cannot be combined"; exit 1; }
SUFFIX=""; FLAG=""
if [[ "$BLOCKAGES" -eq 1 ]]; then SUFFIX="-blockages"; FLAG="--blockages"; fi
if [[ "$FIVE" -eq 1 ]]; then FLAG="--5layer"; fi

run_one () {
  local t="$1" u="$2" a="$3"
  local dir="${OUT_DIR}/${DESIGN}_${t}_${u}_${a}${SUFFIX}"
  if [[ -f "$dir/${DESIGN}.def" && -f "$dir/${DESIGN}.spef" ]]; then
    echo "[SKIP] $dir (${DESIGN}.def and ${DESIGN}.spef exist)"; return 0
  fi
  mkdir -p "$dir"
  echo "[RUN ] $DESIGN  tcp=${t}ns  util=${u}  ar=${a}  ${FLAG}  -> $dir"
  if (cd "$dir" && bash "$HERE/run_design_flow.sh" "$DESIGN" "$t" "$u" "$a" $FLAG > flow.log 2>&1); then
    echo "[DONE] $dir"
  else
    echo "[FAIL] $dir (see $dir/flow.log)"; return 1
  fi
}
export -f run_one; export HERE OUT_DIR DESIGN SUFFIX FLAG

FAIL=0
for t in $TCP; do for u in $UTIL; do for a in $AR; do echo "$t $u $a"; done; done; done \
  | xargs -P "$JOBS" -L 1 bash -c 'run_one "$@"' _ || FAIL=1
[[ "$FAIL" -eq 0 ]] || { echo "some runs failed"; exit 1; }
