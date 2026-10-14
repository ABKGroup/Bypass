#!/bin/bash
set -uo pipefail
SRC=""; CASES=""; JOBS=4; SHARDS=1; STRIDE=1; EVAL_DIR=""; NETLIST_BASE=""
while [[ $# -gt 0 ]]; do case "$1" in
  --src) SRC="${2:?}"; shift 2 ;;
  --eval-dir) EVAL_DIR="${2:?}"; shift 2 ;;
  --netlist-dir) NETLIST_BASE="${2:?}"; shift 2 ;;
  --cases) CASES="${2:?}"; shift 2 ;;
  --jobs) JOBS="${2:?}"; shift 2 ;;
  --shards) SHARDS="${2:?}"; shift 2 ;;
  --stride) STRIDE="${2:?}"; shift 2 ;;
  -h|--help) sed -n '2,16p' "$0"; exit 0 ;;
  *) echo "unknown arg: $1"; exit 1 ;;
esac; done
[ -n "$SRC" ] && [ -n "$EVAL_DIR" ] && [ -n "$NETLIST_BASE" ] || { echo "need --src, --eval-dir and --netlist-dir"; exit 1; }
VER="$(printf '%s' "$SRC" | tr '[:lower:]' '[:upper:]')"
if type module >/dev/null 2>&1; then module load primetime/O-2018.06-SP5-2; fi
: "${NANGATE45_DB_DIR:?set NANGATE45_DB_DIR to the folder with the NanGate45 .db libraries}"
export NANGATE45_DB_DIR

HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
R="$(realpath "${EVAL_DIR}")"
ARCS_BASE="${R}/elmore_pred"          # <case>/original/elmore_delays.csv
TCL="${HERE}/pt_net_delay.tcl"
[ -z "$CASES" ] && CASES="$(ls "${R}/spef_src/${SRC}" 2>/dev/null)"
[ -n "$CASES" ] || { echo "ERR: no cases under ${R}/spef_src/${SRC} (run prepare_spef_variants.sh)"; exit 1; }

dn () { python3 - "$1" <<'PY'
import re,sys
o=[]
for p in sys.argv[1].split("_"):
    if re.fullmatch(r"\d+(\.\d+)?",p): break
    o.append(p)
print("_".join(o))
PY
}
ck () { python3 - "$1" <<'PY'
import re,sys
for p in sys.argv[1].split("_"):
    if re.fullmatch(r"\d+(\.\d+)?",p): print(p); break
PY
}

JOBFILE="$(mktemp)"
for C in $CASES; do
  OUTD="${R}/pt_netdelay/${C}/${SRC}"; mkdir -p "$OUTD"
  if [ -s "${OUTD}/${VER}_net_delay.csv" ]; then echo "SKIP ${C}/${SRC} (merged CSV exists)"; continue; fi
  SPEF="$(find "${R}/spef_src/${SRC}/${C}" -maxdepth 1 -type f -name '*.spef' | head -1)"
  NET="$(find "${NETLIST_BASE}/${C}" -type f -name '*.v' | head -1)"
  ARCS="${ARCS_BASE}/${C}/original/elmore_delays.csv"
  if [ -z "$SPEF" ] || [ -z "$NET" ] || [ ! -s "$ARCS" ]; then echo "SKIP ${C}: spef='$SPEF' net='$NET' arcs='$ARCS'"; continue; fi
  for ((s=0; s<SHARDS; s++)); do
    echo "$C|$(dn "$C")|$(ck "$C")|$SPEF|$NET|$ARCS|$OUTD|$s" >> "$JOBFILE"
  done
done
[ -s "$JOBFILE" ] || { echo "Nothing to run."; rm -f "$JOBFILE"; exit 0; }
echo "variant=${SRC}  pt_shell jobs: $(wc -l < "$JOBFILE")  (concurrent: ${JOBS}, shards/case: ${SHARDS})"

run_job () {
  IFS='|' read -r C D K SPEF NET ARCS OUTD S <<< "$1"
  WD="$(mktemp -d)"
  ( cd "$WD"
    export CASE="$C" DESIGN="$D" CLOCK_PERIOD="$K" VERSION="$VER" SPEF_FILE="$SPEF" NETLIST_FILE="$NET" \
           REPORT_DIR="$OUTD" ARCS_CSV="$ARCS" SHARD="$S" NSHARDS="$SHARDS" STRIDE="$STRIDE"
    pt_shell -f "$TCL" > "${OUTD}/pt_net_delay_s${S}.log" 2>&1 )
  rm -rf "$WD"
  [ -s "${OUTD}/${VER}_net_delay_s${S}.csv" ] && echo "OK  $C shard $S" || echo "ERR $C shard $S (see ${OUTD}/pt_net_delay_s${S}.log)"
}
export -f run_job; export VER SHARDS STRIDE TCL
xargs -d '\n' -P "$JOBS" -I{} bash -c 'run_job "$@"' _ {} < "$JOBFILE"
rm -f "$JOBFILE"

# merge shards -> one CSV per case
for C in $CASES; do
  OUTD="${R}/pt_netdelay/${C}/${SRC}"
  ls "${OUTD}/${VER}_net_delay_s"*.csv >/dev/null 2>&1 || continue
  [ -s "${OUTD}/${VER}_net_delay.csv" ] && continue
  first=1
  for f in $(ls "${OUTD}/${VER}_net_delay_s"*.csv | sort -V); do
    if [ $first -eq 1 ]; then cat "$f" > "${OUTD}/${VER}_net_delay.csv"; first=0; else tail -n +2 "$f" >> "${OUTD}/${VER}_net_delay.csv"; fi
  done
  echo "merged ${C}/${SRC}: $(($(wc -l < "${OUTD}/${VER}_net_delay.csv") - 1)) arcs"
done
