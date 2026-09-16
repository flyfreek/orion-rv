`include "defines.v"

module ex(

    // --------------------------------------------------------
    // from ID/EX
    // --------------------------------------------------------
    input wire[`InstBus] inst_i,
    input wire[`InstAddrBus] inst_addr_i,

    input wire[`RegBus] reg1_rdata_i,
    input wire[`RegBus] reg2_rdata_i,

    input wire[`RegBus] imm_i,

    // EX control
    input wire[`AluOpBus] alu_op_i,
    input wire[`Op1SelBus] op1_sel_i,
    input wire[`Op2SelBus] op2_sel_i,

    // MEM control
    input wire[`MemOpBus] mem_op_i,

    // branch / jump
    input wire[`BranchOpBus] branch_op_i,
    input wire[`JumpOpBus] jump_op_i,

    // WB control
    input wire reg_we_i,
    input wire[`RegAddrBus] reg_waddr_i,

    // exception
    input wire illegal_instr_i,


    // --------------------------------------------------------
    // to EX/MEM
    // --------------------------------------------------------
    output wire[`InstBus] inst_o,

    output wire[`MemOpBus] mem_op_o,

    output reg[`RegBus] store_data_o,

    output reg[`RegBus] alu_result_o,

    output wire reg_we_o,
    output wire[`RegAddrBus] reg_waddr_o,

    output wire illegal_instr_o,

    // 结果当前是否已经可以 forwarding
    output wire result_valid_o,

    // --------------------------------------------------------
    // to CTRL
    // --------------------------------------------------------
    output wire hold_flag_o,
    output reg jump_flag_o,
    output reg[`InstAddrBus] jump_addr_o

);


    // ========================================================
    // internal signals
    // ========================================================

    reg[`RegBus] alu_op1;
    reg[`RegBus] alu_op2;

    wire is_load;
	 
	 wire[31:0] right_shift;
    wire[31:0] right_shift_mask;
    
    assign right_shift =
        alu_op1 >> alu_op2[4:0];
    
    assign right_shift_mask =
        32'hffffffff >> alu_op2[4:0];


    // ========================================================
    // pass-through signals
    // ========================================================

    assign inst_o = inst_i;

    assign mem_op_o = mem_op_i;

    assign reg_we_o    = reg_we_i;
    assign reg_waddr_o = reg_waddr_i;

    assign illegal_instr_o = illegal_instr_i;


    // ========================================================
    // 当前没有 DIV / 多周期执行单元
    // 所以 EX 永远不会主动 stall
    // ========================================================

    assign hold_flag_o = `HoldDisable;


    // ========================================================
    // 判断是否为 Load
    //
    // Load 的真正寄存器结果在 MEM 阶段才产生，
    // 所以 EX/MEM 不能把 alu_result 当作写回值 forwarding。
    // ========================================================

    assign is_load =
        (mem_op_i == `MEM_LB ) ||
        (mem_op_i == `MEM_LH ) ||
        (mem_op_i == `MEM_LW ) ||
        (mem_op_i == `MEM_LBU) ||
        (mem_op_i == `MEM_LHU);


    // 非法指令不能作为 forwarding 的 producer
    assign result_valid_o =
        (!illegal_instr_i) && (!is_load);


    // ========================================================
    // EX combinational logic
    // ========================================================

    always @(*) begin

        alu_op1 = `ZeroWord;
        alu_op2 = `ZeroWord;

        alu_result_o = `ZeroWord;

        store_data_o = reg2_rdata_i;

        jump_flag_o = `JumpDisable;
        jump_addr_o = `ZeroWord;

        // ====================================================
        // Operand 1 selection
        // ====================================================

        case (op1_sel_i)

            `OP1_RS1: begin
                alu_op1 = reg1_rdata_i;
            end

            `OP1_PC: begin
                alu_op1 = inst_addr_i;
            end

            `OP1_ZERO: begin
                alu_op1 = `ZeroWord;
            end

            default: begin
                alu_op1 = `ZeroWord;
            end

        endcase


        // ====================================================
        // Operand 2 selection
        // ====================================================

        case (op2_sel_i)

            `OP2_RS2: begin
                alu_op2 = reg2_rdata_i;
            end

            `OP2_IMM: begin
                alu_op2 = imm_i;
            end

            `OP2_FOUR: begin
                alu_op2 = 32'd4;
            end

            `OP2_ZERO: begin
                alu_op2 = `ZeroWord;
            end

            default: begin
                alu_op2 = `ZeroWord;
            end

        endcase


        // ====================================================
        // ALU
        // ====================================================

        case (alu_op_i)

            `ALU_ADD: begin
                alu_result_o = alu_op1 + alu_op2;
            end

            `ALU_SUB: begin
                alu_result_o = alu_op1 - alu_op2;
            end

            `ALU_SLL: begin
                alu_result_o = alu_op1 << alu_op2[4:0];
            end

            `ALU_SLT: begin
                // 符号不同
                if (alu_op1[31] != alu_op2[31]) begin
                    if (alu_op1[31] == 1'b1)
                        alu_result_o = 32'd1;
                    else
                        alu_result_o = 32'd0;
                end
                // 符号相同，可以直接按照无符号数比较
                else begin
                    if (alu_op1 < alu_op2)
                        alu_result_o = 32'd1;
                    else
                        alu_result_o = 32'd0;
                end
            end

            `ALU_SLTU: begin
                alu_result_o =
                    (alu_op1 < alu_op2)
                    ? 32'd1
                    : 32'd0;
            end

            `ALU_XOR: begin
                alu_result_o = alu_op1 ^ alu_op2;
            end

            `ALU_SRL: begin
                alu_result_o = alu_op1 >> alu_op2[4:0];
            end

            `ALU_SRA: begin
                alu_result_o =
                    (right_shift & right_shift_mask) |
                    ({32{alu_op1[31]}} & (~right_shift_mask));
            end

            `ALU_OR: begin
                alu_result_o = alu_op1 | alu_op2;
            end

            `ALU_AND: begin
                alu_result_o = alu_op1 & alu_op2;
            end

            default: begin
                alu_result_o = `ZeroWord;
            end

        endcase


        // ====================================================
        // Branch / Jump
        //
        // illegal_instr_i = 1 时禁止真正改变PC。
        // 其它候选控制仍然可以继续向后传。
        // ====================================================

        if (!illegal_instr_i) begin

            // ------------------------------------------------
            // Conditional Branch
            // ------------------------------------------------

            case (branch_op_i)

                `BR_BEQ: begin

                    if (reg1_rdata_i == reg2_rdata_i) begin
                        jump_flag_o = `JumpEnable;
                        jump_addr_o = inst_addr_i + imm_i;
                    end

                end


                `BR_BNE: begin

                    if (reg1_rdata_i != reg2_rdata_i) begin
                        jump_flag_o = `JumpEnable;
                        jump_addr_o = inst_addr_i + imm_i;
                    end

                end


                `BR_BLT: begin

                    if ($signed(reg1_rdata_i) <
                        $signed(reg2_rdata_i)) begin

                        jump_flag_o = `JumpEnable;
                        jump_addr_o = inst_addr_i + imm_i;

                    end

                end


                `BR_BGE: begin

                    if ($signed(reg1_rdata_i) >=
                        $signed(reg2_rdata_i)) begin

                        jump_flag_o = `JumpEnable;
                        jump_addr_o = inst_addr_i + imm_i;

                    end

                end


                `BR_BLTU: begin

                    if (reg1_rdata_i < reg2_rdata_i) begin

                        jump_flag_o = `JumpEnable;
                        jump_addr_o = inst_addr_i + imm_i;

                    end

                end


                `BR_BGEU: begin

                    if (reg1_rdata_i >= reg2_rdata_i) begin

                        jump_flag_o = `JumpEnable;
                        jump_addr_o = inst_addr_i + imm_i;

                    end

                end


                default: begin
                end

            endcase


            // ------------------------------------------------
            // Unconditional Jump
            //
            // jump 优先级可以理解为高于 branch。
            // 正常编码下二者不会同时有效。
            // ------------------------------------------------

            case (jump_op_i)

                `JUMP_JAL: begin

                    jump_flag_o = `JumpEnable;
                    jump_addr_o = inst_addr_i + imm_i;

                end

                `JUMP_JALR: begin

                    jump_flag_o = `JumpEnable;

                    jump_addr_o =
                        (reg1_rdata_i + imm_i)
                        & 32'hffff_fffe;

                end


                default: begin
                end

            endcase

        end

    end


endmodule
