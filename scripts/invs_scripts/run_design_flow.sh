#!/bin/bash
# This script was written and developed by ABKGroup students at UCSD VLSI CAD Lab. However, the underlying commands and reports are copyrighted by Cadence.
# We thank Cadence for granting permission to share our research to help promote and foster the next generation of innovators.

set -euo pipefail

if [[ $# -lt 4 ]]; then sed -n '4,13p' "$0"; exit 1; fi

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export INVS_SCRIPTS="$HERE"
export GENUS_SCRIPTS="$(cd "$HERE/../genus_scripts" && pwd)"
export PROJ_DIR="${PROJ_DIR:-$HERE}"      # only used for an optional netlist cache, the technology files are in tech/
export DESIGN="$1"
export CLK_PERIOD="$2"
export UTIL="$3"
export TECH="ng45"
export AR="$4"
export PHY_SYNTH=0
INNOVUS_SCRIPT="run_innovus_no_blockages.tcl"
case "${5:-}" in
  "")           ;;
  --blockages)  INNOVUS_SCRIPT="run_innovus_blockages.tcl" ;;
  --5layer)     INNOVUS_SCRIPT="run_innovus_5layer.tcl" ;;
  *) echo "unknown option: $5"; exit 1 ;;
esac

[[ -d "$HERE/designs/$DESIGN" ]]  || { echo "ERROR: no setup for design '$DESIGN' in $HERE/designs"; exit 1; }
[[ -d "$HERE/tech/$TECH/lib" ]]   || { echo "ERROR: technology files not found: $HERE/tech/$TECH"; exit 1; }

mkdir -p log
genus   -overwrite -log log/genus.log -no_gui -files "$GENUS_SCRIPTS/run_genus.tcl"
innovus -64 -overwrite -log log/innovus.log -files "$INVS_SCRIPTS/$INNOVUS_SCRIPT"
