`include "defines.v"

module forwarding(

    // 当前处于 EX 阶段的指令
    input wire[`RegAddrBus] rs1_i,
    input wire[`RegAddrBus] rs2_i,

    // EX/MEM
    input wire ex_mem_reg_we_i,
    input wire[`RegAddrBus] ex_mem_reg_waddr_i,
    input wire ex_mem_result_valid_i,

    // MEM/WB
    input wire mem_wb_reg_we_i,
    input wire[`RegAddrBus] mem_wb_reg_waddr_i,

    // forwarding select
    output reg[1:0] forward_a_o,
    output reg[1:0] forward_b_o

);

    localparam FORWARD_NONE   = 2'b00;
    localparam FORWARD_EX_MEM = 2'b01;
    localparam FORWARD_MEM_WB = 2'b10;


    always @(*) begin

        forward_a_o = FORWARD_NONE;
        forward_b_o = FORWARD_NONE;
        // ==============================
        // rs1
        // ==============================
        if (
            ex_mem_reg_we_i == `WriteEnable &&
            ex_mem_reg_waddr_i != `ZeroReg &&
            ex_mem_reg_waddr_i == rs1_i
        ) begin
            // EX/MEM 是离当前最近的生产者
            if (ex_mem_result_valid_i) begin
                forward_a_o = FORWARD_EX_MEM;
            end
            else begin
                // 最新结果还没产生，不能使用更老的 MEM/WB 数据
                forward_a_o = FORWARD_NONE;
            end
        end
        else if (
            mem_wb_reg_we_i == `WriteEnable &&
            mem_wb_reg_waddr_i != `ZeroReg &&
            mem_wb_reg_waddr_i == rs1_i
        ) begin
            forward_a_o = FORWARD_MEM_WB;
        end
        // ==============================
        // rs2
        // ==============================
        if (
            ex_mem_reg_we_i == `WriteEnable &&
            ex_mem_reg_waddr_i != `ZeroReg &&
            ex_mem_reg_waddr_i == rs2_i
        ) begin
            if (ex_mem_result_valid_i) begin
                forward_b_o = FORWARD_EX_MEM;
            end
            else begin
                forward_b_o = FORWARD_NONE;
            end
        end
        else if (
            mem_wb_reg_we_i == `WriteEnable &&
            mem_wb_reg_waddr_i != `ZeroReg &&
            mem_wb_reg_waddr_i == rs2_i
        ) begin
            forward_b_o = FORWARD_MEM_WB;
        end

    end

endmodule
