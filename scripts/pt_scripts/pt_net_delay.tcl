#################################################################################################
#                                                                                               #
#     Portions Copyright © 2022 Synopsys, Inc. All rights reserved. Portions of                 #
#     these TCL scripts are proprietary to and owned by Synopsys, Inc. and may only             #
#     be used for internal use by educational institutions (including United States             #
#     government labs, research institutes and federally funded research and                    # 
#     development centers) on Synopsys tools for non-profit research, development,              #
#     instruction, and other non-commercial uses or as otherwise specifically set forth         #
#     by written agreement with Synopsys. All other use, reproduction, modification, or         #
#     distribution of these TCL scripts is strictly prohibited.                                 #
#                                                                                               #
#################################################################################################

set DESIGN       $env(DESIGN)
set VERSION      $env(VERSION)
set SPEF_FILE    $env(SPEF_FILE)
set NETLIST_FILE $env(NETLIST_FILE)
set REPORT_DIR   $env(REPORT_DIR)
set CLK_PERIOD   $::env(CLOCK_PERIOD)
set HALF_CLK_PERIOD [expr {$CLK_PERIOD / 2.0}]

# folder with the NanGate45 .db libraries (NangateOpenCellLibrary_typical.db and the fakeram45_*.db files)
set DB_DIR $::env(NANGATE45_DB_DIR)

set DB_FILE " \
    fakeram45_128x116.db fakeram45_128x256.db fakeram45_128x32.db \
    fakeram45_256x16.db  fakeram45_256x32.db  fakeram45_256x48.db \
    fakeram45_256x64.db  fakeram45_32x32.db   fakeram45_512x64.db \
    fakeram45_64x124.db  fakeram45_64x256.db  fakeram45_64x62.db \
    fakeram45_64x64.db   NangateOpenCellLibrary_typical.db \
    fakeram45_2048x39.db fakeram45_256x34.db fakeram45_64x21.db \
"

set search_path ". ${DB_DIR}"
set target_library ${DB_FILE}
set link_library "* ${target_library}"

file mkdir $REPORT_DIR

read_verilog ${NETLIST_FILE}
link_design ${DESIGN}

set_units -time 1ns

if { $DESIGN eq "aes_cipher_top" || $DESIGN eq "jpeg_encoder" || $DESIGN eq "gcd" || $DESIGN eq "usbf_top" || $DESIGN eq "ldpc_decoder_mod" || $DESIGN eq "nova" || $DESIGN eq "vga_enh_top" || $DESIGN eq "tate_pairing" || $DESIGN eq "mpeg2_top" || $DESIGN eq "swerv_wrapper" } {
    set CLOCK_NAME "clk"
} elseif { $DESIGN eq "ibex_core" } {
    set CLOCK_NAME "clk_i"
} else {
    puts "ERROR: Unknown design '$DESIGN'. Cannot choose clock name."
    exit 1
}

create_clock [get_ports $CLOCK_NAME] \
    -name $CLOCK_NAME -period $CLK_PERIOD \
    -waveform [list 0.0 $HALF_CLK_PERIOD]

set_input_delay -clock [get_clocks $CLOCK_NAME] 0.0 \
    [remove_from_collection [all_inputs] [get_ports $CLOCK_NAME]]
set_output_delay -clock [get_clocks $CLOCK_NAME] 0.0 [all_outputs]
set_propagated_clock [get_clocks $CLOCK_NAME]

read_parasitics -keep_capacitive_coupling -format SPEF ${SPEF_FILE}

report_annotated_parasitics \
    > /dev/null
report_annotated_parasitics -list_not_annotated \
    > /dev/null

update_timing

set ARCS_CSV $::env(ARCS_CSV)
set SHARD   0 ; if { [info exists ::env(SHARD)]   } { set SHARD   $::env(SHARD)   }
set NSHARDS 1 ; if { [info exists ::env(NSHARDS)] } { set NSHARDS $::env(NSHARDS) }
set STRIDE  1 ; if { [info exists ::env(STRIDE)]  } { set STRIDE  $::env(STRIDE)  }   ;# every STRIDE-th arc (same arcs for every variant)

set out_fp [open "${REPORT_DIR}/${VERSION}_net_delay_s${SHARD}.csv" w]
puts $out_fp "net,driver_pin,load_pin,net_delay_rise_ns,net_delay_fall_ns,trans_rise_ns,trans_fall_ns,total_cap_pf,total_res_kohm,status"

proc _num { rpt pat } {
    if { [regexp $pat $rpt -> a b] } { return [list $a $b] }
    return [list "" ""]
}

set in_fp [open $ARCS_CSV r]
gets $in_fp header
set n 0 ; set k 0 ; set done 0 ; set bad 0 ; set n_unparsed 0
set t0 [clock seconds]
while { [gets $in_fp line] >= 0 } {
    incr n
    if { ($n - 1) % $STRIDE != 0 } { continue }
    incr k
    if { ($k - 1) % $NSHARDS != $SHARD } { continue }
    set f [split $line ","]
    if { [llength $f] < 3 } { incr bad ; continue }
    set net [lindex $f 0] ; set drv [lindex $f 1] ; set rcv [lindex $f 2]

    set from_col [get_pins -quiet $drv]
    if { [sizeof_collection $from_col] == 0 } { set from_col [get_ports -quiet $drv] }
    set to_col [get_pins -quiet $rcv]
    if { [sizeof_collection $to_col] == 0 } { set to_col [get_ports -quiet $rcv] }
    if { [sizeof_collection $from_col] == 0 || [sizeof_collection $to_col] == 0 } {
        puts $out_fp "$net,$drv,$rcv,,,,,,,UNRESOLVED_PIN"
        continue
    }

    set rpt ""
    if { [catch { redirect -variable rpt { report_delay_calculation -from $from_col -to $to_col } } err] } {
        puts $out_fp "$net,$drv,$rcv,,,,,,,ERROR"
        continue
    }
    if { [string match "*No arcs between those pins*" $rpt] } {
        puts $out_fp "$net,$drv,$rcv,,,,,,,NO_ARC"
        continue
    }
    # no "Net delay" line in the report: keep the raw text of the first 30 such arcs for diagnosis and
    # flag the row (it used to be written as status=ok with empty numbers)
    if { ![regexp {Net delay\s*=} $rpt] } {
        incr n_unparsed
        if { $n_unparsed <= 30 } {
            set up [open "${REPORT_DIR}/${VERSION}_unparsed_s${SHARD}.txt" a]
            puts $up "===== $net  $drv -> $rcv"
            puts $up $rpt
            close $up
        }
        puts $out_fp "$net,$drv,$rcv,,,,,,,NO_NETDELAY"
        continue
    }
    set nd [_num $rpt {Net delay\s*=\s*(\S+)\s+(\S+)}]
    set tr [_num $rpt {Transition time\s*=\s*(\S+)\s+(\S+)}]
    set cap "" ; set res ""
    regexp {Total capacitance\s*=\s*(\S+)\s*pF} $rpt -> cap
    regexp {Total resistance\s*=\s*(\S+)\s*Kohm} $rpt -> res
    puts $out_fp "$net,$drv,$rcv,[lindex $nd 0],[lindex $nd 1],[lindex $tr 0],[lindex $tr 1],$cap,$res,ok"
    incr done
    if { $done % 20000 == 0 } {
        flush $out_fp
        puts "  shard $SHARD: $done arcs, [expr {[clock seconds] - $t0}] s"
    }
}
close $in_fp
close $out_fp
puts "Net-delay arcs written: $done  (skipped malformed lines: $bad, report without Net delay: $n_unparsed)  shard $SHARD/$NSHARDS"
exit
