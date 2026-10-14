#!/bin/bash
set -uo pipefail
main () {
usage () { sed -n '2,16p' "$0"; exit 1; }
MAX_JOBS=1; SRC=""; EVAL_DIR=""; NETLIST_BASE=""
declare -a CASE_FILTER=()
while [[ $# -gt 0 ]]; do case "$1" in
  --eval-dir)    EVAL_DIR="${2:?}"; shift 2 ;;
  --netlist-dir) NETLIST_BASE="${2:?}"; shift 2 ;;
  --case)        CASE_FILTER+=("${2:?}"); shift 2 ;;
  --jobs) shift; [[ -z "${1-}" || ! "${1}" =~ ^[1-9][0-9]*$ ]] && { echo "ERROR: --jobs needs a positive int"; usage; }; MAX_JOBS="$1"; shift ;;
  --src)  shift; [[ -z "${1-}" ]] && { echo "ERROR: --src needs a name"; usage; }; SRC="$1"; shift ;;
  -h|--help) usage ;;
  *) echo "ERROR: unknown arg: $1"; usage ;;
esac; done
VER="$(printf '%s' "$SRC" | tr '[:lower:]' '[:upper:]')"
[ -n "${SRC}" ] && [ -n "${EVAL_DIR}" ] && [ -n "${NETLIST_BASE}" ] || { echo "ERROR: --src, --eval-dir and --netlist-dir are required"; usage; }
echo "Source        : ${SRC}  (VERSION=${VER})"
echo "Parallel jobs : ${MAX_JOBS}"

if type module >/dev/null 2>&1; then module load primetime/O-2018.06-SP5-2; fi
: "${NANGATE45_DB_DIR:?set NANGATE45_DB_DIR to the folder with the NanGate45 .db libraries}"
export NANGATE45_DB_DIR

HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
EVAL_DIR="$(realpath "${EVAL_DIR}")"
SPEF_BASE="${EVAL_DIR}/spef_src/${SRC}"          # <case>/<case>.spef
BASE_REPORT_DIR="${EVAL_DIR}/pt_pred"
PT_TCL="${HERE}/pt_timing.tcl"
mkdir -p "${BASE_REPORT_DIR}"

extract_design_name () { python3 - "$1" <<'EOF'
import re,sys
o=[]
for p in sys.argv[1].split("_"):
    if re.fullmatch(r"\d+(\.\d+)?",p): break
    o.append(p)
print("_".join(o))
EOF
}
extract_clock_period () { python3 - "$1" <<'EOF'
import re,sys
for p in sys.argv[1].split("_"):
    if re.fullmatch(r"\d+(\.\d+)?",p): print(p); break
EOF
}
find_netlist () { local d="${NETLIST_BASE}/$1"; [ -d "$d" ] && find "$d" -type f -name '*.v' | head -n1 || echo ""; }

run_one () {
  local CASE="$1" DESIGN="$2" CLK="$3" SPEF="$4" NET="$5" RPT="$6"
  RPT="$(realpath -m "${RPT}")"; mkdir -p "${RPT}"
  local WD; WD="$(mktemp -d)"
  echo "---- ${CASE} | ${DESIGN} | clk ${CLK}ns | ${VER}"
  ( cd "${WD}"
    export CASE DESIGN CLOCK_PERIOD="${CLK}" VERSION="${VER}" SPEF_FILE="${SPEF}" NETLIST_FILE="${NET}" REPORT_DIR="${RPT}"
    pt_shell -f "$(realpath "${PT_TCL}")" | tee "${RPT}/pt.log" ) ; local st=$?
  rm -rf "${WD}"
  [ -s "${RPT}/${VER}_arrival_times.csv" ] && echo "OK: ${CASE} -> $(wc -l < "${RPT}/${VER}_arrival_times.csv") rows" || { echo "ERR: no arrival CSV ${CASE}"; return 1; }
  return $st
}

declare -a JC=() JD=() JK=() JS=() JN=() JR=()
for CASE_DIR in "${SPEF_BASE}"/*/; do
  [ -d "${CASE_DIR}" ] || continue
  C=$(basename "${CASE_DIR}")
  if [ "${#CASE_FILTER[@]}" -gt 0 ] && [[ ! " ${CASE_FILTER[*]} " == *" ${C} "* ]]; then continue; fi
  D=$(extract_design_name "$C"); K=$(extract_clock_period "$C"); N=$(find_netlist "$C")
  S=$(find "${CASE_DIR}" -maxdepth 1 -type f -name '*.spef' | head -n1)
  R="${BASE_REPORT_DIR}/${C}/${SRC}"
  if [ -z "$D" ] || [ -z "$K" ] || [ -z "$N" ] || [ -z "$S" ]; then echo "SKIP ${C} (d=$D k=$K net=$N spef=$S)"; continue; fi
  if [ -s "${R}/${VER}_arrival_times.csv" ]; then echo "SKIP ${C} (${VER} arrival CSV exists)"; continue; fi
  JC+=("$C"); JD+=("$D"); JK+=("$K"); JS+=("$S"); JN+=("$N"); JR+=("$R")
done
echo "Jobs: ${#JC[@]}"; [ "${#JC[@]}" -eq 0 ] && { echo "Nothing to run."; exit 0; }

declare -a PIDS=(); declare -A P2J=(); FAIL=0
for i in "${!JC[@]}"; do
  while [ "${#PIDS[@]}" -ge "${MAX_JOBS}" ]; do
    n=(); for p in "${PIDS[@]}"; do kill -0 "$p" 2>/dev/null && n+=("$p") || { wait "$p" || FAIL=$((FAIL+1)); }; done
    PIDS=("${n[@]+"${n[@]}"}"); sleep 1
  done
  if [ "${MAX_JOBS}" -eq 1 ]; then
    run_one "${JC[$i]}" "${JD[$i]}" "${JK[$i]}" "${JS[$i]}" "${JN[$i]}" "${JR[$i]}" || FAIL=$((FAIL+1))
  else
    mkdir -p "${JR[$i]}"
    ( run_one "${JC[$i]}" "${JD[$i]}" "${JK[$i]}" "${JS[$i]}" "${JN[$i]}" "${JR[$i]}" ) >> "${JR[$i]}/console.log" 2>&1 &
    PIDS+=("$!"); P2J["$!"]="${JC[$i]}"
    echo "  launched PID $! -> ${JR[$i]}/console.log"
  fi
done
for p in "${PIDS[@]:-}"; do [ -n "$p" ] && { wait "$p" || FAIL=$((FAIL+1)); }; done
echo; echo "PrimeTime predicted runs finished.  failures: ${FAIL}"
echo "Reports: ${BASE_REPORT_DIR}/<case>/${SRC}/${VER}_arrival_times.csv"
[ "${FAIL}" -eq 0 ] || exit 1
}
main "$@"
