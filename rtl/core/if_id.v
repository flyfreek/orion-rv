`include "defines.v"

// 将指令向译码模块传递
module if_id(

    input wire clk,
    input wire rst,

    // from IF
    input wire[`InstBus] inst_i,
    input wire[`InstAddrBus] inst_addr_i,

    // from CTRL
    input wire[`Hold_Flag_Bus] hold_flag_i,
    input wire[`Flush_Flag_Bus] flush_flag_i,

    // to ID
    output wire[`InstBus] inst_o,
    output wire[`InstAddrBus] inst_addr_o

    );


    // IF/ID 是否保持
    wire hold_en = (hold_flag_i >= `Hold_If);

    // flush_flag bit0 对应 IF/ID
    wire flush_en = flush_flag_i[0];


    gen_pipe_dff #(32) inst_ff(clk, rst, hold_en, flush_en, `INST_NOP, inst_i, inst_o);
    gen_pipe_dff #(32) inst_addr_ff(clk, rst, hold_en, flush_en, `ZeroWord, inst_addr_i, inst_addr_o);


endmodule