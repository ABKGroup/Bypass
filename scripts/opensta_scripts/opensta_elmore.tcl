set LINK_NAME    $::env(LINK_NAME)
set CLOCK_PERIOD $::env(CLOCK_PERIOD)
set NETLIST_FILE $::env(NETLIST_FILE)
set SPEF_FILE    $::env(SPEF_FILE)
set OUTPUT_CSV   $::env(OUTPUT_CSV)

foreach lib $::env(LIB_FILES) { read_liberty $lib }
read_verilog  $NETLIST_FILE
link_design   $LINK_NAME

set CLOCK_NAME ""
foreach cand {clk clk_i CLK clock} {
    if { [llength [get_ports -quiet $cand]] > 0 } { set CLOCK_NAME $cand; break }
}
if { $CLOCK_NAME eq "" } {
    puts "WARNING: no clock port found for $LINK_NAME; skipping create_clock"
} else {
    create_clock -period $CLOCK_PERIOD [get_ports $CLOCK_NAME]
}
set_delay_calculator dmp_ceff_elmore
read_spef     $SPEF_FILE
if { [llength [all_clocks]] > 0 } { set_propagated_clock [all_clocks] }
sta::find_delays

set out [open $OUTPUT_CSV w]
puts $out "net,driver_pin,load_pin,elmore_rise_s,elmore_fall_s"
set count 0

# Iterate over all nets via pin-based traversal.
# get_nets -hierarchical returns all nets including submodule nets.
foreach net [get_nets -hierarchical *] {
    set net_name [get_full_name $net]

    set drvr_pins [sta::net_driver_pins $net]
    if {[llength $drvr_pins] == 0} continue
    set drvr_pin [lindex $drvr_pins 0]

    foreach load_pin [sta::net_load_pins $net] {
        set er [sta::find_elmore $drvr_pin $load_pin rise max]
        set ef [sta::find_elmore $drvr_pin $load_pin fall max]
        if {$er eq "" || $er <= 0.0} continue
        set drvr_name [get_full_name $drvr_pin]
        set load_name [get_full_name $load_pin]
        puts $out "${net_name},${drvr_name},${load_name},${er},${ef}"
        incr count
    }
}

close $out
puts "Done: $count rows written to {$OUTPUT_CSV}"
exit 0
