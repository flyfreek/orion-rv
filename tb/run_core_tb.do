# Run this script from the Orion-RV repository root:
#   vsim -c -do tb/run_core_tb.do

if {[file exists work]} {
    vdel -all -lib work
}
vlib work

vlog +incdir+rtl/core \
    rtl/utils/gen_dff.v \
    rtl/core/pc_reg.v \
    rtl/core/if_id.v \
    rtl/core/id.v \
    rtl/core/id_ex.v \
    rtl/core/ex.v \
    rtl/core/ex_mem.v \
    rtl/core/forwarding.v \
    rtl/core/mem.v \
    rtl/core/mem_wb.v \
    rtl/core/wb.v \
    rtl/core/regs.v \
    rtl/core/ctrl.v \
    rtl/core/orion_rv.v \
    tb/orion_rv_core_tb.v

vsim -voptargs=+acc work.orion_rv_core_tb
run -all
quit -f
