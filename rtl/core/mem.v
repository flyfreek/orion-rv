`include "defines.v"

module mem(

    // --------------------------------------------------------
    // from EX/MEM
    // --------------------------------------------------------

    input wire[`MemOpBus] mem_op_i,

    input wire reg_we_i,
    input wire[`RegAddrBus] reg_waddr_i,

    input wire[`RegBus] store_data_i,

    input wire[`RegBus] alu_result_i,

    input wire illegal_instr_i,


    // --------------------------------------------------------
    // from memory
    // --------------------------------------------------------

    input wire[`MemBus] mem_rdata_i,


    // --------------------------------------------------------
    // to memory
    // --------------------------------------------------------

    output reg[`MemBus] mem_wdata_o,
    output wire[`MemAddrBus] mem_addr_o,

    output reg mem_we_o,
    output reg mem_req_o,


    // --------------------------------------------------------
    // to MEM/WB
    // --------------------------------------------------------

    output reg[`RegBus] reg_wdata_o,

    output wire reg_we_o,
    output wire[`RegAddrBus] reg_waddr_o,

    output wire illegal_instr_o,


    // --------------------------------------------------------
    // to CTRL
    // 当前固定单周期访存，所以不会产生stall
    // --------------------------------------------------------

    output wire hold_flag_o

);


    // ========================================================
    // address information
    // ========================================================

    wire[1:0] mem_addr_index;

    assign mem_addr_index = alu_result_i[1:0];

    // EX已经算好有效地址
    assign mem_addr_o = alu_result_i;

    // ========================================================
    // pass through
    // ========================================================

    // 非法指令禁止写寄存器
    assign reg_we_o = illegal_instr_i ? `WriteDisable : reg_we_i;
    assign reg_waddr_o = reg_waddr_i;
    assign illegal_instr_o = illegal_instr_i;

    // ========================================================
    // 当前假设memory固定1 cycle
    // ========================================================

    assign hold_flag_o = `HoldDisable;

    // ========================================================
    // MEM logic
    // ========================================================

    always @(*) begin
        reg_wdata_o = alu_result_i;

        mem_req_o = `RIB_NREQ;
        mem_we_o  = `WriteDisable;

        mem_wdata_o = `ZeroWord;
        if (!illegal_instr_i) begin
            case (mem_op_i)
    
                // =================================================
                // LOAD BYTE
                // signed
                // =================================================
    
                `MEM_LB: begin
                    mem_req_o = `RIB_REQ;
                    case (mem_addr_index)
    
                        2'b00:
                            reg_wdata_o = {
                                {24{mem_rdata_i[7]}},
                                mem_rdata_i[7:0]
                            };
    
                        2'b01:
                            reg_wdata_o = {
                                {24{mem_rdata_i[15]}},
                                mem_rdata_i[15:8]
                            };
    
                        2'b10:
                            reg_wdata_o = {
                                {24{mem_rdata_i[23]}},
                                mem_rdata_i[23:16]
                            };
    
                        2'b11:
                            reg_wdata_o = {
                                {24{mem_rdata_i[31]}},
                                mem_rdata_i[31:24]
                            };
	 	   						
                    endcase
                end
    
                `MEM_LH: begin
                    mem_req_o = `RIB_REQ;
                    if (mem_addr_index[1] == 1'b0) begin
                        reg_wdata_o = {  {16{mem_rdata_i[15]}},  mem_rdata_i[15:0]   };
                    end
                    else begin
                        reg_wdata_o = { {16{mem_rdata_i[31]}},    mem_rdata_i[31:16]};
                    end
                end
    
                `MEM_LW: begin
                    mem_req_o = `RIB_REQ;
                    reg_wdata_o = mem_rdata_i;
                end
    
    
                // =================================================
                // LOAD BYTE UNSIGNED
                // =================================================
    
                `MEM_LBU: begin
                    mem_req_o = `RIB_REQ;
                    case (mem_addr_index)
    
                        2'b00:
                            reg_wdata_o = {
                                24'b0,
                                mem_rdata_i[7:0]
                            };
    
                        2'b01:
                            reg_wdata_o = {
                                24'b0,
                                mem_rdata_i[15:8]
                            };
    
                        2'b10:
                            reg_wdata_o = {
                                24'b0,
                                mem_rdata_i[23:16]
                            };
    
                        2'b11:
                            reg_wdata_o = {
                                24'b0,
                                mem_rdata_i[31:24]
                            };
    
                    endcase
                end
    
    
                // =================================================
                // LOAD HALF WORD UNSIGNED
                // =================================================
    
                `MEM_LHU: begin
                    mem_req_o = `RIB_REQ;
                    if (mem_addr_index[1] == 1'b0) begin
                        reg_wdata_o = {16'b0,   mem_rdata_i[15:0]  };
                    end
                    else begin
                        reg_wdata_o = {  16'b0,  mem_rdata_i[31:16] };
                    end
                end
    
                `MEM_SB: begin
                    mem_req_o = `RIB_REQ;
                    mem_we_o  = `WriteEnable;
                    case (mem_addr_index)
                        2'b00: begin
                            mem_wdata_o = {   mem_rdata_i[31:8],   store_data_i[7:0]  };
                        end
    
                        2'b01: begin
                            mem_wdata_o = { mem_rdata_i[31:16],   store_data_i[7:0],    mem_rdata_i[7:0]   };
                        end
    
                        2'b10: begin
                            mem_wdata_o = {  mem_rdata_i[31:24], store_data_i[7:0],  mem_rdata_i[15:0]  };
                        end
    
                        2'b11: begin
                            mem_wdata_o = {   store_data_i[7:0],  mem_rdata_i[23:0] };
                        end
                    endcase
                end
    
                `MEM_SH: begin
                    mem_req_o = `RIB_REQ;
                    mem_we_o  = `WriteEnable;
                    if (mem_addr_index[1] == 1'b0) begin
                        mem_wdata_o = {    mem_rdata_i[31:16],   store_data_i[15:0]    };
                    end
                    else begin
                        mem_wdata_o = {    store_data_i[15:0],   mem_rdata_i[15:0]   };
                    end
                end
    
                `MEM_SW: begin
                    mem_req_o = `RIB_REQ;
                    mem_we_o  = `WriteEnable;
                    mem_wdata_o = store_data_i;
                end
                // =================================================
                // Not a memory instruction
                //
                // ADD / SUB / JAL / LUI / AUIPC...
                //
                // reg_wdata_o已经默认等于alu_result_i
                // =================================================
                `MEM_NONE: begin
                end
    
                default: begin
                end
    
            endcase
        end
    end

endmodule
