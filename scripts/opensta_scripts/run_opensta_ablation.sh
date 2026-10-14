#!/bin/bash
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EVAL=""; NET=""; LIB=""; JOBS=1; declare -a CASES=()
while [[ $# -gt 0 ]]; do case "$1" in
  --eval-dir)    EVAL="${2:?}"; shift 2 ;;
  --netlist-dir) NET="${2:?}"; shift 2 ;;
  --lib)         LIB="${2:?}"; shift 2 ;;
  --case)        CASES+=("${2:?}"); shift 2 ;;
  --jobs)        JOBS="${2:?}"; shift 2 ;;
  -h|--help)     sed -n '2,15p' "$0"; exit 0 ;;
  *) echo "unknown argument: $1"; exit 1 ;;
esac; done
[ -n "$EVAL" ] && [ -n "$NET" ] && [ -n "$LIB" ] || { sed -n '2,15p' "$0"; exit 1; }
[ "${#CASES[@]}" -gt 0 ] || CASES=(
  aes_cipher_top_0.6_0.4_1.0
  aes_cipher_top_0.75_0.4_1.0
  aes_cipher_top_0.9_0.4_1.0
  aes_cipher_top_3_0.92_1.2
  ldpc_decoder_mod_1.0_0.3_1.0
  ldpc_decoder_mod_1.6_0.4_1.0
  vga_enh_top_1.0_0.6_1.0
  swerv_wrapper_1.0_0.70_1.0
  tate_pairing_1.0_0.6_1.0
  mpeg2_top_1.0_0.6_1.0
)
CASE_ARGS=(); for c in "${CASES[@]}"; do CASE_ARGS+=(--case "$c"); done

FAIL=0
for v in original ceiling_full bypass hybrid_C hybrid_R; do
  echo; echo "######## variant $v"
  bash "$HERE/run_opensta_timing.sh" --eval-dir "$EVAL" --netlist-dir "$NET" --lib "$LIB" --source "$v" --jobs "$JOBS" "${CASE_ARGS[@]}" || FAIL=1
done
echo; echo "Next: EVAL_DIR=$EVAL python3 evaluate_component_ablation.py ${CASES[*]}"
exit $FAIL
