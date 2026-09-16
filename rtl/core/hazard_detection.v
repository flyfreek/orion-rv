`include "defines.v"

// Load-Use Hazard Detection
module hazard_detection(

    // 当前处于 EX 阶段的上一条指令，来自 ID/EX
    input wire[`MemOpBus] ex_mem_op_i,
    input wire ex_reg_we_i,
    input wire[`RegAddrBus] ex_reg_waddr_i,
    input wire ex_illegal_instr_i,

    // 当前处于 ID 阶段的指令
    input wire[`RegAddrBus] id_rs1_i,
    input wire[`RegAddrBus] id_rs2_i,
    input wire id_uses_rs1_i,
    input wire id_uses_rs2_i,

    // to CTRL
    output wire load_use_hazard_o

);


    wire ex_is_load;

    // 判断当前 EX 阶段的上一条指令是不是 Load
    assign ex_is_load =
        (ex_mem_op_i == `MEM_LB ) ||
        (ex_mem_op_i == `MEM_LH ) ||
        (ex_mem_op_i == `MEM_LW ) ||
        (ex_mem_op_i == `MEM_LBU) ||
        (ex_mem_op_i == `MEM_LHU);


    // Load-Use Hazard:
    //
    // 1. EX阶段是Load
    // 2. Load会写寄存器
    // 3. rd不是x0
    // 4. 当前ID指令使用这个rd作为rs1或者rs2
    assign load_use_hazard_o =
        ex_is_load &&
        (ex_reg_we_i == `WriteEnable) &&
        (!ex_illegal_instr_i) &&
        (ex_reg_waddr_i != `ZeroReg) &&
        (
            (id_uses_rs1_i && (ex_reg_waddr_i == id_rs1_i)) ||
            (id_uses_rs2_i && (ex_reg_waddr_i == id_rs2_i))
        );


endmodule
