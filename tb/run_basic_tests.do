# GUI: do D:/Orion-RV/tb/run_basic_tests.do
# Uses a private library; never deletes the project's work library.
# Questa 'do' does not provide a reliable Tcl info-script path.
# Change this one line if the repository is moved.
set regression_root D:/Orion-RV
proc orion_basic_regression {root} {
    set out [file join $root build basic_regression]
    file mkdir $out
    set lib [file join $out work]
    if {![file exists $lib]} {vlib $lib}
    catch {quit -sim}
    set sources [list [file join $root rtl utils gen_dff.v]]
    foreach name {pc_reg if_id id id_ex ex ex_mem forwarding mem mem_wb wb regs ctrl orion_rv} {
        lappend sources [file join $root rtl core ${name}.v]
    }
    lappend sources [file join $root tb orion_rv_core_tb.v]
    vlog -work $lib +incdir+$root/rtl/core {*}$sources

    set report [open [file join $out results.txt] w]
    puts $report "Regression started. Complete only when SUMMARY is present."
    flush $report
    set passed 0
    set failed 0
    set timedout 0
    set errors 0
    # Explicit RV32I image list; M-extension images are intentionally excluded.
    foreach name {add andi auipc beq bge bgeu blt bltu bne jal jalr lui ori simple slli slti sltiu srai srli xori} {
        set program [file join $root test_instruction Baisc_Inst_Example inst_${name}.data]
        set result ERROR
        set detail ""
        if {[catch {
            if {![file readable $program]} {error "Missing image: $program"}
            vsim -onfinish stop -voptargs=+acc -wlf [file join $out last.wlf] $lib.orion_rv_core_tb +PROG=$program +NO_VCD
            run -all
            set status [string trim [examine -radix decimal sim:/orion_rv_core_tb/test_status]]
            switch -- $status {
                1 {set result PASS; incr passed}
                2 {set result FAIL; incr failed}
                3 {set result TIMEOUT; incr timedout}
                default {error "Simulation stopped without a completed result: $status"}
            }
            set detail "x3=[examine -radix unsigned sim:/orion_rv_core_tb/x3] cycles=[examine -radix decimal sim:/orion_rv_core_tb/cycle_count]"
        } message]} {
            incr errors
            set detail $message
        }
        set row [format "%-22s %-8s %s" inst_${name}.data $result $detail]
        puts $row
        puts $report $row
        flush $report
        catch {quit -sim}
    }
    set summary "SUMMARY: $passed PASS, $failed FAIL, $timedout TIMEOUT, $errors ERROR"
    puts $summary
    puts $report $summary
    close $report
    puts "Report: [file join $out results.txt]"
}
# Continue the macro when the TB calls $finish; do not quit the GUI.
onbreak {resume}
orion_basic_regression $regression_root
onbreak {}
