`include "defines.v"

// 将访存阶段结果传递到写回阶段
module mem_wb(

    input wire clk,
    input wire rst,

    // from MEM
    input wire[`RegBus] reg_wdata_i,
    input wire reg_we_i,
    input wire[`RegAddrBus] reg_waddr_i,

    input wire illegal_instr_i,

    // from CTRL
    input wire[`Hold_Flag_Bus] hold_flag_i,
    input wire[`Flush_Flag_Bus] flush_flag_i,

    // to WB
    output wire[`RegBus] reg_wdata_o,
    output wire reg_we_o,
    output wire[`RegAddrBus] reg_waddr_o,

    output wire illegal_instr_o

);


    // MEM/WB 流水寄存器控制
    wire hold_en  = (hold_flag_i >= `Hold_Mem);
    wire flush_en = flush_flag_i[3];


    gen_pipe_dff #(32) reg_wdata_ff(clk, rst, hold_en, flush_en, `ZeroWord, reg_wdata_i, reg_wdata_o);

    gen_pipe_dff #(1) reg_we_ff(clk, rst, hold_en, flush_en, `WriteDisable, reg_we_i, reg_we_o);

    gen_pipe_dff #(5) reg_waddr_ff(clk, rst, hold_en, flush_en, `ZeroReg, reg_waddr_i, reg_waddr_o);

    gen_pipe_dff #(1) illegal_instr_ff(clk, rst, hold_en, flush_en, 1'b0, illegal_instr_i, illegal_instr_o);


endmodule