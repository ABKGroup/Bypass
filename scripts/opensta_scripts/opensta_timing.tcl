
set LIB_FILE     $::env(LIB_FILE)
set EXTRA_LIBS   $::env(EXTRA_LIBS)
set NETLIST_FILE $::env(NETLIST_FILE)
set LINK_NAME    $::env(LINK_NAME)
set CLOCK_PERIOD $::env(CLOCK_PERIOD)
set SPEF_FILE    $::env(SPEF_FILE)
set REPORT_DIR   $::env(REPORT_DIR)
set MODEL_NAME   $::env(MODEL_NAME)
set NOCRPR       $::env(NOCRPR)
set TOPN 500
if { [info exists ::env(TOPN)] } { set TOPN $::env(TOPN) }

set OUTPUT_CSV  [file join $REPORT_DIR elmore_delays.csv]
set SUMMARY_CSV [file join $REPORT_DIR summary.csv]
set ARRIVAL_CSV [file join $REPORT_DIR arrival_times.csv]
set SLACK_CSV   [file join $REPORT_DIR endpoint_slack.csv]
set PATHS_RPT   [file join $REPORT_DIR top_paths.rpt]

read_liberty $LIB_FILE
foreach lib $EXTRA_LIBS { read_liberty $lib }
read_verilog $NETLIST_FILE
link_design  $LINK_NAME

# Clock port of the design
if { $LINK_NAME eq "aes_cipher_top" || $LINK_NAME eq "jpeg_encoder" || $LINK_NAME eq "gcd" || $LINK_NAME eq "usbf_top" || $LINK_NAME eq "vga_enh_top" || $LINK_NAME eq "ldpc_decoder_mod" || $LINK_NAME eq "tate_pairing" || $LINK_NAME eq "nova" || $LINK_NAME eq "mpeg2_top" || $LINK_NAME eq "swerv_wrapper" } {
    set CLOCK_NAME "clk"
} elseif { $LINK_NAME eq "ibex_core" } {
    set CLOCK_NAME "clk_i"
} else {
    puts "ERROR: Unknown design '$LINK_NAME'. Cannot choose clock name."
    exit 1
}
create_clock -period $CLOCK_PERIOD [get_ports $CLOCK_NAME]
set_delay_calculator dmp_ceff_elmore
read_spef $SPEF_FILE
if { $NOCRPR == 1 } { sta::set_crpr_enabled 0 }
set_propagated_clock [all_clocks]
sta::find_delays

# Interconnect (Elmore) delay of every driver -> load arc  #
set out [open $OUTPUT_CSV w]
puts $out "net,driver_pin,load_pin,elmore_rise_s,elmore_fall_s"
set count 0
foreach net [get_nets -hierarchical *] {
    set net_name [get_full_name $net]
    set drvr_pins [sta::net_driver_pins $net]
    if {[llength $drvr_pins] == 0} continue
    set drvr_pin [lindex $drvr_pins 0]
    foreach load_pin [sta::net_load_pins $net] {
        set er [sta::find_elmore $drvr_pin $load_pin rise max]
        set ef [sta::find_elmore $drvr_pin $load_pin fall max]
        if {$er eq "" || $er <= 0.0} continue
        puts $out "${net_name},[get_full_name $drvr_pin],[get_full_name $load_pin],${er},${ef}"
        incr count
    }
}
close $out
puts "Done: $count rows -> {$OUTPUT_CSV}"

# WNS / TNS summary #
set wns [worst_slack -max]
set tns [total_negative_slack -max]

# Endpoint set (register D pins + output ports) #
array unset is_endpoint_arr
array set is_endpoint_arr {}
set num_violations 0
foreach ep [concat [all_registers -data_pins] [all_outputs]] {
    set is_endpoint_arr([get_full_name $ep]) 1
    if { [catch { set sl [get_property $ep slack_max] } errv] } { continue }
    if { $sl < 0.0 } { incr num_violations }
}

set summary_out [open $SUMMARY_CSV w]
puts $summary_out "design,version,wns,tns,num_violations,spef"
puts $summary_out "${LINK_NAME},${MODEL_NAME},$wns,$tns,$num_violations,{$SPEF_FILE}"
close $summary_out
puts "Summary written: {$SUMMARY_CSV}  wns=$wns tns=$tns violations=$num_violations"

# Per-pin arrival report #
set arr_out [open $ARRIVAL_CSV w]
puts $arr_out "net_name,pin,direction,max_rise_arrival,max_fall_arrival,is_endpoint,status"
array unset seen_arr_pins
array set seen_arr_pins {}
foreach net2 [get_nets -hierarchical *] {
    set net_name2 [get_full_name $net2]
    set all_pins [concat [sta::net_driver_pins $net2] [sta::net_load_pins $net2]]
    foreach p $all_pins {
        set pname [get_full_name $p]
        if { [info exists seen_arr_pins($pname)] } { continue }
        set seen_arr_pins($pname) 1

        set dir ""
        catch { set dir [get_property $p direction] }
        set is_ep [expr {[info exists is_endpoint_arr($pname)] ? 1 : 0}]

        set ar_r "NA"; set ar_f "NA"; set st "ok"
        if { [catch { set ar_r [get_property $p arrival_max_rise] } e1] } {
            set st "ERROR: [string map {, ; \n { } \r { }} $e1]"
        }
        if { [catch { set ar_f [get_property $p arrival_max_fall] } e2] } {
            set st "ERROR: [string map {, ; \n { } \r { }} $e2]"
        }
        puts $arr_out "${net_name2},${pname},${dir},${ar_r},${ar_f},${is_ep},${st}"
    }
}
close $arr_out
puts "Arrival report written: {$ARRIVAL_CSV}"

set sl_out [open $SLACK_CSV w]
puts $sl_out "pin,slack_max_ns"
foreach ep [concat [all_registers -data_pins] [all_outputs]] {
    if { [catch { set sl [get_property $ep slack_max] }] } { continue }
    if { $sl eq "INF" || $sl eq "-INF" } { continue }
    puts $sl_out "[get_full_name $ep],$sl"
}
close $sl_out
catch { report_checks -path_delay max -group_count $TOPN -endpoint_count 1 -format summary -digits 4 > $PATHS_RPT } perr
puts "Endpoint slack / top paths written: {$SLACK_CSV} {$PATHS_RPT} $perr"

exit 0
