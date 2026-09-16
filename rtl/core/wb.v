`include "defines.v"

module wb(

    input wire[`RegBus] reg_wdata_i,
    input wire reg_we_i,
    input wire[`RegAddrBus] reg_waddr_i,

    input wire illegal_instr_i,

    output wire[`RegBus] reg_wdata_o,
    output wire reg_we_o,
    output wire[`RegAddrBus] reg_waddr_o,

    output wire illegal_instr_o

);

    assign reg_wdata_o = reg_wdata_i;
    assign reg_we_o =
        (reg_we_i == `WriteEnable &&
         illegal_instr_i == 1'b0)
        ? `WriteEnable
        : `WriteDisable;
	 
    assign reg_waddr_o = reg_waddr_i;

    assign illegal_instr_o = illegal_instr_i;

endmodule
