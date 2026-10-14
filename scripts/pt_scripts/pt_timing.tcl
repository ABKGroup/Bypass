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
    > ${REPORT_DIR}/${VERSION}_annotated_parasitics.rpt
report_annotated_parasitics -list_not_annotated \
    > ${REPORT_DIR}/${VERSION}_not_annotated.rpt

update_timing

set wns "NA"
set tns 0.0
set num_violations 0

catch {
    set worst [get_timing_paths -delay_type max -max_paths 1]
    set wns [get_attribute $worst slack]
}

catch {
    set violating [get_timing_paths -delay_type max \
        -slack_lesser_than 0.0 -max_paths 100000]
    foreach_in_collection path $violating {
        set tns [expr {$tns + [get_attribute $path slack]}]
        incr num_violations
    }
}

set summary_fp [open "${REPORT_DIR}/${VERSION}_summary.csv" w]
puts $summary_fp "design,version,wns,tns,num_violations,spef"
puts $summary_fp "$DESIGN,$VERSION,$wns,$tns,$num_violations,$SPEF_FILE"
close $summary_fp

puts "======================================"
puts "PrimeTime Summary"
puts "Design          : $DESIGN"
puts "Version         : $VERSION"
puts "WNS             : $wns"
puts "TNS             : $tns"
puts "Violating paths : $num_violations"
puts "======================================"

set timing_save_pin_arrival_and_slack true
update_timing

# Endpoint set (register D pins + output ports) -- used to tag is_endpoint
# below, so one CSV serves both the per-pin and per-endpoint views instead of
# maintaining two separate report loops.
array unset is_endpoint_arr
array set is_endpoint_arr {}
foreach_in_collection ep [all_registers -data_pins] {
    set is_endpoint_arr([get_object_name $ep]) 1
}
foreach_in_collection ep [all_outputs] {
    set is_endpoint_arr([get_object_name $ep]) 1
}

set ARRIVAL_RPT_FILE "${REPORT_DIR}/${VERSION}_arrival_times.csv"
set arrival_fp [open $ARRIVAL_RPT_FILE w]
puts $arrival_fp "net_name,pin,direction,max_rise_arrival,max_fall_arrival,is_endpoint,status"

array unset seen_pins
array set seen_pins {}

foreach_in_collection net [get_nets -hierarchical *] {
    set net_name [get_object_name $net]

    foreach_in_collection obj [all_connected $net] {
        set obj_name  [get_object_name $obj]
        set direction ""
        catch { set direction [get_attribute $obj direction] }
        set is_ep [expr {[info exists is_endpoint_arr($obj_name)] ? 1 : 0}]

        if { [info exists seen_pins($obj_name)] } { continue }
        set seen_pins($obj_name) 1

        set pin_col [get_pins -quiet $obj_name]
        if { [sizeof_collection $pin_col] == 0 } { set pin_col [get_ports -quiet $obj_name] }
        if { [sizeof_collection $pin_col] == 0 } {
            puts $arrival_fp "$net_name,$obj_name,$direction,NA,NA,$is_ep,skipped_UNRESOLVED_PIN"
            continue
        }

        set ar_max_rise "NA"
        set ar_max_fall "NA"
        set status "ok"

        if { [catch { set ar_max_rise [get_attribute $pin_col max_rise_arrival] } err1] } {
            set status "ERROR: [string map {, ; \n { } \r { }} $err1]"
        }
        if { [catch { set ar_max_fall [get_attribute $pin_col max_fall_arrival] } err2] } {
            set status "ERROR: [string map {, ; \n { } \r { }} $err2]"
        }

        puts $arrival_fp "$net_name,$obj_name,$direction,$ar_max_rise,$ar_max_fall,$is_ep,$status"
    }
}

close $arrival_fp
puts "Arrival time report written: $ARRIVAL_RPT_FILE"

exit
