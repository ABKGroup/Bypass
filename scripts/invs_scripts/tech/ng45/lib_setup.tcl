# This script was written and developed by ABKGroup students at UCSD VLSI CAD Lab. However, the underlying commands and reports are copyrighted by Cadence.
# We thank Cadence for granting permission to share our research to help promote and foster the next generation of innovators.

# lib and lef, RC setup

set libdir "${invs_dir}/tech/${TECH}/lib"
set lefdir "${invs_dir}/tech/${TECH}/lef"
set qrcdir "${invs_dir}/tech/${TECH}/qrc"

set_db init_lib_search_path { \
  ${libdir} \
  ${lefdir} \
}

set libworst "  
  ${libdir}/NangateOpenCellLibrary_typical.lib \
  ${libdir}/fakeram45_2048x39.lib \
  ${libdir}/fakeram45_256x34.lib \
  ${libdir}/fakeram45_64x21.lib \
  ${libdir}/fakeram45_256x32.lib \
  ${libdir}/fakeram45_64x64.lib \
  "

set libbest " 
  ${libdir}/NangateOpenCellLibrary_typical.lib \
  ${libdir}/fakeram45_2048x39.lib \
  ${libdir}/fakeram45_256x34.lib \
  ${libdir}/fakeram45_64x21.lib \
  ${libdir}/fakeram45_256x32.lib \
  ${libdir}/fakeram45_64x64.lib \
  "

set lefs "  
  ${lefdir}/NangateOpenCellLibrary.tech.lef \
  ${lefdir}/NangateOpenCellLibrary.macro.mod.lef \
  ${lefdir}/fakeram45_2048x39.lef \
  ${lefdir}/fakeram45_256x34.lef \
  ${lefdir}/fakeram45_64x21.lef \
  ${lefdir}/fakeram45_256x32.lef \
  ${lefdir}/fakeram45_64x64.lef \
  "

set qrc_max "${qrcdir}/NG45.tch"
set qrc_min "${qrcdir}/NG45.tch"

# Ensures proper and consistent library handling between Genus and Innovus
#set_db library_setup_ispatial true
setDesignMode -process 45

set SITE "FreePDK45_38x28_10R_NP_162NW_34O"
set HALO_WIDTH 5
set TOP_ROUTING_LAYER 10
set c2d 2
