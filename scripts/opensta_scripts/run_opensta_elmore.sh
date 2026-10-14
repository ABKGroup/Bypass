#!/bin/bash
set -uo pipefail

main () {

usage () {
    echo "Usage: ORIGINAL_BASE=<folder with the case dirs> $0 [--jobs N] [--case NAME ...]"
    echo "  --jobs N     Number of parallel OpenSTA jobs (default: 4)"
    echo "  --case NAME  run only this case (repeatable; default: every case in ORIGINAL_BASE)"
    exit 1
}

MAX_JOBS=4
declare -a CASE_FILTER=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --jobs)
            shift
            if [[ -z "${1-}" || ! "${1}" =~ ^[1-9][0-9]*$ ]]; then
                echo "ERROR: --jobs requires a positive integer."
                usage
            fi
            MAX_JOBS="$1"
            shift
            ;;
        --case) shift; CASE_FILTER+=("${1:?--case needs a name}"); shift ;;
        -h|--help) usage ;;
        *) echo "ERROR: Unknown argument: $1"; usage ;;
    esac
done

echo "Parallel jobs : ${MAX_JOBS}"
echo

# Case dirs hold <design>.def/.v/.spef named <design>_<tcp>_<util>_<ar> #
# (tcp: nanoseconds)                                                    #
# Set ORIGINAL_BASE to the folder with the case dirs (required),        #
# BASE_REPORT_DIR for the output                                        #
# (default: data/OpenSTA_delays), INVS_INPUTS for the library files,    #
# STA_BIN for the OpenSTA binary.                                       #
TCL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INVS_IN="${INVS_INPUTS:-${REPO}/scripts/invs_scripts/tech}"
DEF_BASE="${ORIGINAL_BASE:?set ORIGINAL_BASE to the folder with the case dirs (<design>/{*.def,*.v,*.spef})}"
DEF_REPORTS="${REPO}/data/OpenSTA_delays"
LIB_FILES=( "${INVS_IN}/ng45/lib/NangateOpenCellLibrary_typical.lib" )
ORIGINAL_BASE="${ORIGINAL_BASE:-${DEF_BASE}}"
BASE_REPORT_DIR="${BASE_REPORT_DIR:-${DEF_REPORTS}}"
STA_BIN="${STA_BIN:-$(command -v sta || true)}"

mkdir -p "${BASE_REPORT_DIR}"

extract_design_name () {
    local CASE_NAME="$1"
    python3 - << EOF
import re
case = "${CASE_NAME}"
parts = case.split("_")
design_parts = []
for p in parts:
    if re.fullmatch(r"\d+(\.\d+)?", p):
        break
    design_parts.append(p)
print("_".join(design_parts))
EOF
}

extract_clock_period () {
    local CASE_NAME="$1"
    python3 - << EOF
import re
case = "${CASE_NAME}"
parts = case.split("_")
for p in parts:
    if re.fullmatch(r"\d+(\.\d+)?", p):
        print(p)
        break
EOF
}

find_spef () {
    local CASE_DIR="${ORIGINAL_BASE}/$1"
    [ -d "${CASE_DIR}" ] && find "${CASE_DIR}" -type f -name "*.spef" | head -n 1 || echo ""
}

find_netlist () {
    local CASE_DIR="${ORIGINAL_BASE}/$1"
    [ -d "${CASE_DIR}" ] && find "${CASE_DIR}" -type f -name "*.v" | head -n 1 || echo ""
}

extract_module_name () {
    local NETLIST_PATH="$1"
    local DESIGN_HINT="$2"
    [ -f "${NETLIST_PATH}" ] || { echo ""; return; }

    local ALL_MODULES
    ALL_MODULES="$(sed -n 's/^[[:space:]]*module[[:space:]]\+\([A-Za-z_][A-Za-z0-9_$]*\).*/\1/p' "${NETLIST_PATH}")"
    [ -n "${ALL_MODULES}" ] || { echo ""; return; }

    local HINT="${DESIGN_HINT}"
    if [[ "${HINT}" == ng45_* ]]; then
        HINT="${HINT#ng45_}"
    fi

    local MATCH
    MATCH="$(echo "${ALL_MODULES}" | grep -x -F "${HINT}" | head -n 1)"
    if [ -n "${MATCH}" ]; then
        echo "${MATCH}"
        return
    fi

    echo "${ALL_MODULES}" | tail -n 1
}


# Run sta (opensta_elmore.tcl) for one case #
run_elmore_for_case () {
    local CASE_NAME="$1"
    local DESIGN_NAME="$2"
    local CLOCK_PERIOD="$3"
    local SPEF_PATH="$4"
    local NETLIST_PATH="$5"
    local REPORT_DIR="$6"

    local OUTPUT_CSV
    OUTPUT_CSV="$(realpath -m "${REPORT_DIR}/elmore_delays.csv")"
    local LOG="${REPORT_DIR}/sta.log"
    local WORKDIR
    WORKDIR="$(mktemp -d)"

    local LINK_NAME
    LINK_NAME="$(extract_module_name "${NETLIST_PATH}" "${DESIGN_NAME}")"
    if [ -z "${LINK_NAME}" ]; then
        echo "ERROR: could not find a 'module' declaration in ${NETLIST_PATH} for case ${CASE_NAME}"
        return 1
    fi

    echo "------------------------------------------------------------"
    echo "Case         : ${CASE_NAME}"
    echo "Design       : ${DESIGN_NAME}"
    echo "Link module  : ${LINK_NAME}"
    echo "Clock period : ${CLOCK_PERIOD}"
    echo "SPEF         : ${SPEF_PATH}"
    echo "Netlist      : ${NETLIST_PATH}"
    echo "Output CSV   : ${OUTPUT_CSV}"
    echo "------------------------------------------------------------"

    # opensta_elmore.tcl takes its inputs from the environment @
    (
        cd "${WORKDIR}"
        LIB_FILES="${LIB_FILES[*]}" NETLIST_FILE="${NETLIST_PATH}" LINK_NAME="${LINK_NAME}" \
        CLOCK_PERIOD="${CLOCK_PERIOD}" SPEF_FILE="${SPEF_PATH}" OUTPUT_CSV="${OUTPUT_CSV}" \
            "${STA_BIN}" -no_init "${TCL_DIR}/opensta_elmore.tcl" 2>&1
    ) | tee "${LOG}"

    local EXIT_STATUS=${PIPESTATUS[0]}

    rm -rf "${WORKDIR}"

    if [ "${EXIT_STATUS}" -ne 0 ]; then
        echo "ERROR: sta exited with status ${EXIT_STATUS} for case ${CASE_NAME}"
        return "${EXIT_STATUS}"
    fi

    if [ ! -f "${OUTPUT_CSV}" ] || [ ! -s "${OUTPUT_CSV}" ]; then
        echo "ERROR: Output CSV missing or empty for case ${CASE_NAME}: ${OUTPUT_CSV}"
        return 1
    fi

    local ROW_COUNT
    ROW_COUNT=$(wc -l < "${OUTPUT_CSV}")
    echo "OK: ${CASE_NAME} -> ${ROW_COUNT} rows (incl. header) in ${OUTPUT_CSV}"
    return 0
}


# Pass 1: validate all cases #
CASE_DIRS=$(find "${ORIGINAL_BASE}" -mindepth 1 -maxdepth 1 -type d | sort || true)

if [ -z "${CASE_DIRS}" ]; then
    echo "ERROR: No case directories found in ${ORIGINAL_BASE}"
    exit 1
fi

declare -a VALID_CASE_NAMES=()
declare -a VALID_DESIGN_NAMES=()
declare -a VALID_CLOCK_PERIODS=()
declare -a VALID_SPEF_PATHS=()
declare -a VALID_NETLIST_PATHS=()
SKIP_COUNT=0

for CASE_DIR in ${CASE_DIRS}; do
    CASE_NAME=$(basename "${CASE_DIR}")
    SKIP=0
    if [ "${#CASE_FILTER[@]}" -gt 0 ] && [[ ! " ${CASE_FILTER[*]} " == *" ${CASE_NAME} "* ]]; then
        continue
    fi

    DESIGN_NAME=$(extract_design_name "${CASE_NAME}")
    CLOCK_PERIOD=$(extract_clock_period "${CASE_NAME}")
    SPEF_FILE=$(find_spef "${CASE_NAME}")
    NETLIST_FILE=$(find_netlist "${CASE_NAME}")

    [ -z "${DESIGN_NAME}" ]  && { echo "SKIP [${CASE_NAME}]: cannot extract design name"; SKIP=1; }
    [ -z "${CLOCK_PERIOD}" ] && { echo "SKIP [${CASE_NAME}]: cannot extract clock period"; SKIP=1; }
    [ -z "${SPEF_FILE}" ]    && { echo "SKIP [${CASE_NAME}]: no .spef found"; SKIP=1; }
    [ -z "${NETLIST_FILE}" ] && { echo "SKIP [${CASE_NAME}]: no .v found"; SKIP=1; }

    if [ "${SKIP}" -eq 0 ]; then
        # Skip if output already exists and is non-empty #
        EXISTING="${BASE_REPORT_DIR}/${CASE_NAME}/elmore_delays.csv"
        if [ -f "${EXISTING}" ] && [ -s "${EXISTING}" ]; then
            echo "SKIP [${CASE_NAME}]: output already exists: ${EXISTING}"
            SKIP_COUNT=$((SKIP_COUNT + 1))
            continue
        fi

        echo "OK   [${CASE_NAME}]  design=${DESIGN_NAME}  clk=${CLOCK_PERIOD}ns"
        VALID_CASE_NAMES+=("${CASE_NAME}")
        VALID_DESIGN_NAMES+=("${DESIGN_NAME}")
        VALID_CLOCK_PERIODS+=("${CLOCK_PERIOD}")
        VALID_SPEF_PATHS+=("${SPEF_FILE}")
        VALID_NETLIST_PATHS+=("${NETLIST_FILE}")
    else
        SKIP_COUNT=$((SKIP_COUNT + 1))
    fi
done

VALID_COUNT=${#VALID_CASE_NAMES[@]}
echo
echo "Validation summary: ${VALID_COUNT} valid, ${SKIP_COUNT} skipped."

if [ "${VALID_COUNT}" -eq 0 ]; then
    echo "No valid cases to run. Exiting."
    exit 0
fi
echo


# Pass 2: run OpenSTA for each validated case #
declare -a RUNNING_PIDS=()
declare -A PID_TO_CASE=()
FAIL_COUNT=0
DONE_COUNT=0

reap_finished () {
    local still_running=()
    for pid in "${RUNNING_PIDS[@]}"; do
        if kill -0 "${pid}" 2>/dev/null; then
            still_running+=("${pid}")
        else
            local status=0
            wait "${pid}" || status=$?
            local cname="${PID_TO_CASE[$pid]:-unknown}"
            if [ "${status}" -eq 0 ]; then
                echo "[DONE ] ${cname}"
                DONE_COUNT=$((DONE_COUNT + 1))
            else
                echo "[FAIL ] ${cname} (exit status ${status})"
                FAIL_COUNT=$((FAIL_COUNT + 1))
            fi
            unset "PID_TO_CASE[$pid]"
        fi
    done
    RUNNING_PIDS=("${still_running[@]+"${still_running[@]}"}")
}

wait_for_slot () {
    while [ "${#RUNNING_PIDS[@]}" -ge "${MAX_JOBS}" ]; do
        sleep 0.5
        reap_finished
    done
}

for i in "${!VALID_CASE_NAMES[@]}"; do
    CASE_NAME="${VALID_CASE_NAMES[$i]}"
    DESIGN_NAME="${VALID_DESIGN_NAMES[$i]}"
    CLOCK_PERIOD="${VALID_CLOCK_PERIODS[$i]}"
    SPEF_FILE="${VALID_SPEF_PATHS[$i]}"
    NETLIST_FILE="${VALID_NETLIST_PATHS[$i]}"

    CASE_REPORT_DIR="$(realpath -m "${BASE_REPORT_DIR}/${CASE_NAME}")"
    mkdir -p "${CASE_REPORT_DIR}"


    wait_for_slot

    if [ "${MAX_JOBS}" -eq 1 ]; then
        run_elmore_for_case \
            "${CASE_NAME}" "${DESIGN_NAME}" "${CLOCK_PERIOD}" \
            "${SPEF_FILE}" "${NETLIST_FILE}" "${CASE_REPORT_DIR}"
        DONE_COUNT=$((DONE_COUNT + 1))
    else
        CONSOLE_LOG="${CASE_REPORT_DIR}/console.log"
        (
            run_elmore_for_case \
                "${CASE_NAME}" "${DESIGN_NAME}" "${CLOCK_PERIOD}" \
                "${SPEF_FILE}" "${NETLIST_FILE}" "${CASE_REPORT_DIR}"
        ) >> "${CONSOLE_LOG}" 2>&1 &

        BG_PID=$!
        RUNNING_PIDS+=("${BG_PID}")
        PID_TO_CASE["${BG_PID}"]="${CASE_NAME}"
        echo "  Launched (PID ${BG_PID}) -> ${CONSOLE_LOG}"
    fi
done

if [ "${MAX_JOBS}" -gt 1 ] && [ "${#RUNNING_PIDS[@]}" -gt 0 ]; then
    while [ "${#RUNNING_PIDS[@]}" -gt 0 ]; do
        sleep 1
        reap_finished
    done
fi

# Summary #
echo
echo "============================================================"
echo "All Elmore delay runs finished."
echo "Valid cases   : ${VALID_COUNT}"
echo "Skipped       : ${SKIP_COUNT}"
echo "Completed     : ${DONE_COUNT}"
echo "Reports under : ${BASE_REPORT_DIR}"
echo "============================================================"

[ "${FAIL_COUNT}" -eq 0 ] || exit 1

}

main "$@"