#!/bin/bash
set -uo pipefail

main () {

usage () { sed -n '2,23p' "$0"; exit 1; }

MAX_JOBS=4
EVAL_DIR=""; NETLIST_BASE=""; LIB_FILE=""
declare -a CASE_FILTER=() SOURCES=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --eval-dir)    EVAL_DIR="${2:?}"; shift 2 ;;
        --netlist-dir) NETLIST_BASE="${2:?}"; shift 2 ;;
        --lib)         LIB_FILE="${2:?}"; shift 2 ;;
        --case)        CASE_FILTER+=("${2:?}"); shift 2 ;;
        --source)      SOURCES+=("${2:?}"); shift 2 ;;
        --jobs)
            shift
            [[ -z "${1-}" || ! "${1}" =~ ^[1-9][0-9]*$ ]] && { echo "ERROR: --jobs needs a positive int"; usage; }
            MAX_JOBS="$1"; shift ;;
        -h|--help) usage ;;
        *) echo "ERROR: Unknown argument: $1"; usage ;;
    esac
done
echo "Parallel jobs : ${MAX_JOBS}"
echo


# Paths #
[ -n "${EVAL_DIR}" ] && [ -n "${NETLIST_BASE}" ] && [ -n "${LIB_FILE}" ] || { echo "ERROR: --eval-dir, --netlist-dir and --lib are required"; usage; }
EVAL_DIR="$(realpath "${EVAL_DIR}")"
PRED_SPEF_BASE="${EVAL_DIR}/spef_src"  # <variant>/<case>/<case>.spef #
BASE_REPORT_DIR="${EVAL_DIR}/elmore_pred"
TCL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STA_BIN="${STA_BIN:-$(command -v sta || true)}"
if [ "${#SOURCES[@]}" -gt 0 ]; then MODELS=("${SOURCES[@]}")
else mapfile -t MODELS < <(ls "${PRED_SPEF_BASE}" 2>/dev/null); fi

mkdir -p "${BASE_REPORT_DIR}"


extract_design_name () {
    python3 - "$1" << 'EOF'
import re, sys
case = sys.argv[1]; out = []
for p in case.split("_"):
    if re.fullmatch(r"\d+(\.\d+)?", p): break
    out.append(p)
print("_".join(out))
EOF
}

extract_clock_period () {
    python3 - "$1" << 'EOF'
import re, sys
case = sys.argv[1]
for p in case.split("_"):
    if re.fullmatch(r"\d+(\.\d+)?", p):
        print(p); break
EOF
}

find_netlist () {
    local CASE_DIR="${NETLIST_BASE}/$1"
    [ -d "${CASE_DIR}" ] && find "${CASE_DIR}" -type f -name "*.v" | head -n 1 || echo ""
}

extract_module_name () {
    local NETLIST_PATH="$1" DESIGN_HINT="$2"
    [ -f "${NETLIST_PATH}" ] || { echo ""; return; }
    local ALL_MODULES
    ALL_MODULES="$(sed -n 's/^[[:space:]]*module[[:space:]]\+\([A-Za-z_][A-Za-z0-9_$]*\).*/\1/p' "${NETLIST_PATH}")"
    [ -n "${ALL_MODULES}" ] || { echo ""; return; }
    local HINT="${DESIGN_HINT}"; [[ "${HINT}" == ng45_* ]] && HINT="${HINT#ng45_}"
    local MATCH; MATCH="$(echo "${ALL_MODULES}" | grep -x -F "${HINT}" | head -n 1)"
    [ -n "${MATCH}" ] && { echo "${MATCH}"; return; }
    echo "${ALL_MODULES}" | tail -n 1
}

# Run OpenSTA for one (case, model) pair #
run_elmore_for_case () {
    local CASE_NAME="$1" DESIGN_NAME="$2" CLOCK_PERIOD="$3"
    local SPEF_PATH="$4" NETLIST_PATH="$5" REPORT_DIR="$6"

    local OUTPUT_CSV LOG WORKDIR LINK_NAME ARRIVAL_CSV SUMMARY_CSV MODEL_NAME
    OUTPUT_CSV="$(realpath -m "${REPORT_DIR}/elmore_delays.csv")"
    ARRIVAL_CSV="$(realpath -m "${REPORT_DIR}/arrival_times.csv")"
    SUMMARY_CSV="$(realpath -m "${REPORT_DIR}/summary.csv")"
    SLACK_CSV="$(realpath -m "${REPORT_DIR}/endpoint_slack.csv")"
    PATHS_RPT="$(realpath -m "${REPORT_DIR}/top_paths.rpt")"
    TOPN="${TOPN:-500}"
    MODEL_NAME="$(basename "${REPORT_DIR}")"
    LOG="${REPORT_DIR}/sta.log"
    WORKDIR="$(mktemp -d)"

    LINK_NAME="$(extract_module_name "${NETLIST_PATH}" "${DESIGN_NAME}")"
    [ -z "${LINK_NAME}" ] && { echo "ERROR: no 'module' in ${NETLIST_PATH} for ${CASE_NAME}"; return 1; }

    echo "------------------------------------------------------------"
    echo "Case ${CASE_NAME}  |  link ${LINK_NAME}  |  clk ${CLOCK_PERIOD}ns"
    echo "SPEF   ${SPEF_PATH}"
    echo "Out    ${OUTPUT_CSV}"
    echo "------------------------------------------------------------"

    EXTRA_LIBS=""
    for _m in $(grep -o 'fakeram45_[0-9x]*' "${NETLIST_PATH}" 2>/dev/null | sort -u); do
        _f="$(dirname "${LIB_FILE}")/${_m}.lib"
        [ -f "${_f}" ] && EXTRA_LIBS+="${_f} "
    done

    NOCRPR_DESIGNS="swerv_wrapper"
    NOCRPR=0
    for _d in ${NOCRPR_DESIGNS}; do
        [ "${LINK_NAME}" = "${_d}" ] && NOCRPR=1
    done
    [ "${NOCRPR}" -eq 1 ] && echo "CRPR disabled (sta::set_crpr_enabled 0): OpenSTA 3.1.0 segfault workaround for ${LINK_NAME}; clock is propagated" > "${REPORT_DIR}/crpr_off.txt"

    local T0 T1
    T0="$(date +%s.%N)"
    # opensta_timing.tcl takes its inputs from the environment #
    ( cd "${WORKDIR}" && \
      LIB_FILE="${LIB_FILE}" EXTRA_LIBS="${EXTRA_LIBS}" NETLIST_FILE="${NETLIST_PATH}" LINK_NAME="${LINK_NAME}" \
      CLOCK_PERIOD="${CLOCK_PERIOD}" SPEF_FILE="${SPEF_PATH}" REPORT_DIR="${REPORT_DIR}" MODEL_NAME="${MODEL_NAME}" \
      TOPN="${TOPN}" NOCRPR="${NOCRPR}" \
        "${STA_BIN}" -no_init "${TCL_DIR}/opensta_timing.tcl" 2>&1 ) | tee "${LOG}"
    local EXIT_STATUS=${PIPESTATUS[0]}
    T1="$(date +%s.%N)"
    rm -rf "${WORKDIR}"

    awk -v t0="${T0}" -v t1="${T1}" 'BEGIN{printf "%.3f\n", t1-t0}' > "${REPORT_DIR}/sta_seconds.txt"

    [ "${EXIT_STATUS}" -ne 0 ] && { echo "ERROR: sta exit ${EXIT_STATUS} for ${CASE_NAME}"; return "${EXIT_STATUS}"; }
    [ ! -s "${OUTPUT_CSV}" ]   && { echo "ERROR: empty output for ${CASE_NAME}: ${OUTPUT_CSV}"; return 1; }
    echo "OK: ${CASE_NAME} -> $(wc -l < "${OUTPUT_CSV}") rows  ($(cat "${REPORT_DIR}/sta_seconds.txt")s)"
    return 0
}

# Pass 1: validate  (one job per case x model) #
[ -d "${PRED_SPEF_BASE}" ] || { echo "ERROR: no ${PRED_SPEF_BASE}"; exit 1; }

declare -a J_CASE=() J_MODEL=() J_DESIGN=() J_CLK=() J_SPEF=() J_NET=() J_RPT=()
SKIP_COUNT=0

for MODEL in "${MODELS[@]}"; do
    MODEL_DIR="${PRED_SPEF_BASE}/${MODEL}"
    if [ ! -d "${MODEL_DIR}" ]; then
        echo "SKIP [${MODEL}]: no ${MODEL_DIR}"
        SKIP_COUNT=$((SKIP_COUNT+1)); continue
    fi
    for CASE_DIR in "${MODEL_DIR}"/*/; do
        [ -d "${CASE_DIR}" ] || continue
        CASE_NAME=$(basename "${CASE_DIR}")
        if [ "${#CASE_FILTER[@]}" -gt 0 ] && [[ ! " ${CASE_FILTER[*]} " == *" ${CASE_NAME} "* ]]; then continue; fi
        DESIGN_NAME=$(extract_design_name "${CASE_NAME}")
        CLOCK_PERIOD=$(extract_clock_period "${CASE_NAME}")
        NETLIST_FILE=$(find_netlist "${CASE_NAME}")

        if [ -z "${DESIGN_NAME}" ] || [ -z "${CLOCK_PERIOD}" ] || [ -z "${NETLIST_FILE}" ]; then
            echo "SKIP [${CASE_NAME}]: design='${DESIGN_NAME}' clk='${CLOCK_PERIOD}' netlist='${NETLIST_FILE}'"
            SKIP_COUNT=$((SKIP_COUNT+1)); continue
        fi

        SPEF_FILE=$(find "${CASE_DIR}" -maxdepth 1 -type f -name "*.spef" | head -n 1)
        if [ -z "${SPEF_FILE}" ]; then
            echo "SKIP [${CASE_NAME}/${MODEL}]: no .spef in ${CASE_DIR}"
            SKIP_COUNT=$((SKIP_COUNT+1)); continue
        fi
        RPT_DIR="$(realpath -m "${BASE_REPORT_DIR}/${CASE_NAME}/${MODEL}")"
        if [ -s "${RPT_DIR}/elmore_delays.csv" ] && [ -s "${RPT_DIR}/endpoint_slack.csv" ]; then
            echo "SKIP [${CASE_NAME}/${MODEL}]: output exists"
            SKIP_COUNT=$((SKIP_COUNT+1)); continue
        fi
        mkdir -p "${RPT_DIR}"
        echo "OK   [${CASE_NAME}/${MODEL}]  design=${DESIGN_NAME} clk=${CLOCK_PERIOD}ns"
        J_CASE+=("${CASE_NAME}");   J_MODEL+=("${MODEL}")
        J_DESIGN+=("${DESIGN_NAME}"); J_CLK+=("${CLOCK_PERIOD}")
        J_SPEF+=("${SPEF_FILE}");   J_NET+=("${NETLIST_FILE}");  J_RPT+=("${RPT_DIR}")
    done
done

VALID_COUNT=${#J_CASE[@]}
echo
echo "Validation: ${VALID_COUNT} job(s), ${SKIP_COUNT} skipped."
[ "${VALID_COUNT}" -eq 0 ] && { echo "Nothing to run."; exit 0; }
echo

# Pass 2: run #
declare -a RUNNING_PIDS=()
declare -A PID_TO_JOB=()
FAIL_COUNT=0; DONE_COUNT=0

reap_finished () {
    local still=()
    for pid in "${RUNNING_PIDS[@]}"; do
        if kill -0 "${pid}" 2>/dev/null; then
            still+=("${pid}")
        else
            local st=0; wait "${pid}" || st=$?
            local j="${PID_TO_JOB[$pid]:-unknown}"
            if [ "${st}" -eq 0 ]; then echo "[DONE ] ${j}"; DONE_COUNT=$((DONE_COUNT+1))
            else echo "[FAIL ] ${j} (exit ${st})"; FAIL_COUNT=$((FAIL_COUNT+1)); fi
            unset "PID_TO_JOB[$pid]"
        fi
    done
    RUNNING_PIDS=("${still[@]+"${still[@]}"}")
}
wait_for_slot () {
    while [ "${#RUNNING_PIDS[@]}" -ge "${MAX_JOBS}" ]; do sleep 0.5; reap_finished; done
}

for i in "${!J_CASE[@]}"; do
    JOB="${J_CASE[$i]}/${J_MODEL[$i]}"
    echo
    echo "=== Queuing ${JOB} ==="
    wait_for_slot
    if [ "${MAX_JOBS}" -eq 1 ]; then
        run_elmore_for_case "${J_CASE[$i]}" "${J_DESIGN[$i]}" "${J_CLK[$i]}" \
                            "${J_SPEF[$i]}" "${J_NET[$i]}" "${J_RPT[$i]}"
        [ $? -eq 0 ] && DONE_COUNT=$((DONE_COUNT+1)) || FAIL_COUNT=$((FAIL_COUNT+1))
    else
        (
            run_elmore_for_case "${J_CASE[$i]}" "${J_DESIGN[$i]}" "${J_CLK[$i]}" \
                                "${J_SPEF[$i]}" "${J_NET[$i]}" "${J_RPT[$i]}"
        ) >> "${J_RPT[$i]}/console.log" 2>&1 &
        BG_PID=$!
        RUNNING_PIDS+=("${BG_PID}")
        PID_TO_JOB["${BG_PID}"]="${JOB}"
        echo "  launched PID ${BG_PID} -> ${J_RPT[$i]}/console.log"
    fi
done

if [ "${MAX_JOBS}" -gt 1 ] && [ "${#RUNNING_PIDS[@]}" -gt 0 ]; then
    echo; echo "Waiting for ${#RUNNING_PIDS[@]} job(s)..."
    while [ "${#RUNNING_PIDS[@]}" -gt 0 ]; do sleep 1; reap_finished; done
fi

echo
echo "Elmore predicted runs finished."
echo "Jobs valid : ${VALID_COUNT}   skipped : ${SKIP_COUNT}   completed : ${DONE_COUNT}"
echo "Reports under : ${BASE_REPORT_DIR}/<case>/<variant>/"

TIMING_CSV="${EVAL_DIR}/elmore_pred_timing.csv"
echo "case,design,clock_period_ns,model,seconds" > "${TIMING_CSV}"
for TFILE in "${BASE_REPORT_DIR}"/*/*/sta_seconds.txt; do
    [ -f "${TFILE}" ] || continue
    MODEL_NAME="$(basename "$(dirname "${TFILE}")")"
    CASE_NAME="$(basename "$(dirname "$(dirname "${TFILE}")")")"
    DESIGN_NAME="$(extract_design_name "${CASE_NAME}")"
    CLOCK_PERIOD="$(extract_clock_period "${CASE_NAME}")"
    SECS="$(cat "${TFILE}")"
    echo "${CASE_NAME},${DESIGN_NAME},${CLOCK_PERIOD},${MODEL_NAME},${SECS}" >> "${TIMING_CSV}"
done
N_TIMED=$(($(wc -l < "${TIMING_CSV}") - 1))
echo
echo "OpenSTA wall time per (case, model): ${N_TIMED} row(s) -> ${TIMING_CSV}"
if [ "${N_TIMED}" -gt 0 ]; then
    echo "  per-model mean/total seconds:"
    awk -F',' 'NR>1{sum[$4]+=$5; n[$4]++} END{for(m in sum) printf "    %-12s mean=%.2fs  total=%.1fs  n=%d\n", m, sum[m]/n[m], sum[m], n[m]}' "${TIMING_CSV}"
fi
echo "============================================================"
[ "${FAIL_COUNT}" -eq 0 ] || exit 1
}

main "$@"
