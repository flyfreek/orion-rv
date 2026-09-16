`include "defines.v"

// 将执行阶段结果传递到访存阶段
module ex_mem(

    input wire clk,
    input wire rst,

    // from EX
    input wire[`InstBus] inst_i,

    input wire[`MemOpBus] mem_op_i,

    input wire reg_we_i,
    input wire[`RegAddrBus] reg_waddr_i,

    input wire[`RegBus] store_data_i,
    input wire[`RegBus] alu_result_i,

    input wire illegal_instr_i,
    input wire result_valid_i,

    // from CTRL
    input wire[`Hold_Flag_Bus] hold_flag_i,
    input wire[`Flush_Flag_Bus] flush_flag_i,

    // to MEM
    output wire[`InstBus] inst_o,

    output wire[`MemOpBus] mem_op_o,

    output wire reg_we_o,
    output wire[`RegAddrBus] reg_waddr_o,

    output wire[`RegBus] store_data_o,
    output wire[`RegBus] alu_result_o,

    output wire illegal_instr_o,

    // to forwarding
    output wire result_valid_o

);


    // EX/MEM 流水寄存器控制
    wire hold_en  = (hold_flag_i >= `Hold_Ex);
    wire flush_en = flush_flag_i[2];


    gen_pipe_dff #(32) inst_ff(clk, rst, hold_en, flush_en, `INST_NOP, inst_i, inst_o);

    gen_pipe_dff #(4) mem_op_ff(clk, rst, hold_en, flush_en, `MEM_NONE, mem_op_i, mem_op_o);

    gen_pipe_dff #(1) reg_we_ff(clk, rst, hold_en, flush_en, `WriteDisable, reg_we_i, reg_we_o);
    gen_pipe_dff #(5) reg_waddr_ff(clk, rst, hold_en, flush_en, `ZeroReg, reg_waddr_i, reg_waddr_o);

    gen_pipe_dff #(32) store_data_ff(clk, rst, hold_en, flush_en, `ZeroWord, store_data_i, store_data_o);
    gen_pipe_dff #(32) alu_result_ff(clk, rst, hold_en, flush_en, `ZeroWord, alu_result_i, alu_result_o);

    gen_pipe_dff #(1) illegal_instr_ff(clk, rst, hold_en, flush_en, 1'b0, illegal_instr_i, illegal_instr_o);

    gen_pipe_dff #(1) result_valid_ff(clk, rst, hold_en, flush_en, 1'b0, result_valid_i, result_valid_o);


endmodule
