`include "defines.v"

// ID/EX 流水寄存器
module id_ex(

    input wire clk,
    input wire rst,

    // from ID
    input wire[`InstBus] inst_i,
    input wire[`InstAddrBus] inst_addr_i,

    input wire[`RegBus] reg1_rdata_i,
    input wire[`RegBus] reg2_rdata_i,

    input wire uses_rs1_i,
    input wire uses_rs2_i,

    input wire[`RegBus] imm_i,

    input wire[`AluOpBus] alu_op_i,
    input wire[`Op1SelBus] op1_sel_i,
    input wire[`Op2SelBus] op2_sel_i,

    input wire[`MemOpBus] mem_op_i,

    input wire[`BranchOpBus] branch_op_i,
    input wire[`JumpOpBus] jump_op_i,

    input wire reg_we_i,
    input wire[`RegAddrBus] reg_waddr_i,

    input wire illegal_instr_i,

    // from CTRL
    input wire[`Hold_Flag_Bus] hold_flag_i,
    input wire[`Flush_Flag_Bus] flush_flag_i,

    // to EX
    output wire[`InstBus] inst_o,
    output wire[`InstAddrBus] inst_addr_o,

    output wire[`RegBus] reg1_rdata_o,
    output wire[`RegBus] reg2_rdata_o,

    output wire uses_rs1_o,
    output wire uses_rs2_o,

    output wire[`RegBus] imm_o,

    output wire[`AluOpBus] alu_op_o,
    output wire[`Op1SelBus] op1_sel_o,
    output wire[`Op2SelBus] op2_sel_o,

    output wire[`MemOpBus] mem_op_o,

    output wire[`BranchOpBus] branch_op_o,
    output wire[`JumpOpBus] jump_op_o,

    output wire reg_we_o,
    output wire[`RegAddrBus] reg_waddr_o,

    output wire illegal_instr_o

);


    wire hold_en  = (hold_flag_i >= `Hold_Id);
    wire flush_en = flush_flag_i[1];


    gen_pipe_dff #(32) inst_ff(clk, rst, hold_en, flush_en, `INST_NOP, inst_i, inst_o);
    gen_pipe_dff #(32) inst_addr_ff(clk, rst, hold_en, flush_en, `ZeroWord, inst_addr_i, inst_addr_o);

    gen_pipe_dff #(32) reg1_rdata_ff(clk, rst, hold_en, flush_en, `ZeroWord, reg1_rdata_i, reg1_rdata_o);
    gen_pipe_dff #(32) reg2_rdata_ff(clk, rst, hold_en, flush_en, `ZeroWord, reg2_rdata_i, reg2_rdata_o);

    gen_pipe_dff #(1) uses_rs1_ff(clk, rst, hold_en, flush_en, 1'b0, uses_rs1_i, uses_rs1_o);
    gen_pipe_dff #(1) uses_rs2_ff(clk, rst, hold_en, flush_en, 1'b0, uses_rs2_i, uses_rs2_o);

    gen_pipe_dff #(32) imm_ff(clk, rst, hold_en, flush_en, `ZeroWord, imm_i, imm_o);

    gen_pipe_dff #(4) alu_op_ff(clk, rst, hold_en, flush_en, `ALU_NONE, alu_op_i, alu_op_o);
    gen_pipe_dff #(2) op1_sel_ff(clk, rst, hold_en, flush_en, `OP1_ZERO, op1_sel_i, op1_sel_o);
    gen_pipe_dff #(2) op2_sel_ff(clk, rst, hold_en, flush_en, `OP2_ZERO, op2_sel_i, op2_sel_o);

    gen_pipe_dff #(4) mem_op_ff(clk, rst, hold_en, flush_en, `MEM_NONE, mem_op_i, mem_op_o);

    gen_pipe_dff #(3) branch_op_ff(clk, rst, hold_en, flush_en, `BR_NONE, branch_op_i, branch_op_o);
    gen_pipe_dff #(2) jump_op_ff(clk, rst, hold_en, flush_en, `JUMP_NONE, jump_op_i, jump_op_o);

    gen_pipe_dff #(1) reg_we_ff(clk, rst, hold_en, flush_en, `WriteDisable, reg_we_i, reg_we_o);
    gen_pipe_dff #(5) reg_waddr_ff(clk, rst, hold_en, flush_en, `ZeroReg, reg_waddr_i, reg_waddr_o);

    gen_pipe_dff #(1) illegal_instr_ff(clk, rst, hold_en, flush_en, 1'b0, illegal_instr_i, illegal_instr_o);


endmodule
