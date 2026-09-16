`include "defines.v"

module id(

    input wire[`InstBus] inst_i,
    input wire[`InstAddrBus] inst_addr_i,

    input wire[`RegBus] reg1_rdata_i,
    input wire[`RegBus] reg2_rdata_i,

    output reg[`RegAddrBus] reg1_raddr_o,
    output reg[`RegAddrBus] reg2_raddr_o,

    output reg[`InstBus] inst_o,
    output reg[`InstAddrBus] inst_addr_o,

    output reg[`RegBus] reg1_rdata_o,
    output reg[`RegBus] reg2_rdata_o,

    output reg uses_rs1_o,
    output reg uses_rs2_o,

    output reg[`RegBus] imm_o,

    output reg[`AluOpBus] alu_op_o,
    output reg[`Op1SelBus] op1_sel_o,
    output reg[`Op2SelBus] op2_sel_o,

    output reg[`MemOpBus] mem_op_o,

    output reg[`BranchOpBus] branch_op_o,
    output reg[`JumpOpBus] jump_op_o,

    output reg reg_we_o,
    output reg[`RegAddrBus] reg_waddr_o,

    output reg illegal_instr_o
);

    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] funct3 = inst_i[14:12];
    wire[6:0] funct7 = inst_i[31:25];

    wire[`RegAddrBus] rd  = inst_i[11:7];
    wire[`RegAddrBus] rs1 = inst_i[19:15];
    wire[`RegAddrBus] rs2 = inst_i[24:20];

    always @(*) begin
        inst_o      = inst_i;
        inst_addr_o = inst_addr_i;

        reg1_rdata_o = reg1_rdata_i;
        reg2_rdata_o = reg2_rdata_i;

        reg1_raddr_o = `ZeroReg;
        reg2_raddr_o = `ZeroReg;

        uses_rs1_o = 1'b0;
        uses_rs2_o = 1'b0;

        imm_o = `ZeroWord;

        alu_op_o  = `ALU_NONE;
        op1_sel_o = `OP1_ZERO;
        op2_sel_o = `OP2_ZERO;

        mem_op_o = `MEM_NONE;

        branch_op_o = `BR_NONE;
        jump_op_o   = `JUMP_NONE;

        reg_we_o    = `WriteDisable;
        reg_waddr_o = `ZeroReg;

        // 默认非法
        illegal_instr_o = 1'b1;

        case (opcode)
            // =================================================
            // I-type ALU
            // =================================================
            `INST_TYPE_I: begin

                reg1_raddr_o = rs1;

                uses_rs1_o = 1'b1;
                uses_rs2_o = 1'b0;

                reg_we_o    = `WriteEnable;
                reg_waddr_o = rd;

                imm_o = { {20{inst_i[31]}}, inst_i[31:20] };

                op1_sel_o = `OP1_RS1;
                op2_sel_o = `OP2_IMM;

                case (funct3)

                    `INST_ADDI: begin
                        alu_op_o = `ALU_ADD;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_SLTI: begin
                        alu_op_o = `ALU_SLT;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_SLTIU: begin
                        alu_op_o = `ALU_SLTU;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_XORI: begin
                        alu_op_o = `ALU_XOR;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_ORI: begin
                        alu_op_o = `ALU_OR;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_ANDI: begin
                        alu_op_o = `ALU_AND;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_SLLI: begin
                        imm_o = {27'b0, inst_i[24:20] };
                        if (funct7 == 7'b0000000) begin
                            alu_op_o = `ALU_SLL;
                            illegal_instr_o = 1'b0;
                        end
                    end
						  
                    `INST_SRI: begin

                        imm_o = {27'b0, inst_i[24:20]  };
                        if (funct7 == 7'b0000000) begin
                            alu_op_o = `ALU_SRL;
                            illegal_instr_o = 1'b0;
                        end
                        else if (funct7 == 7'b0100000) begin
                            alu_op_o = `ALU_SRA;
                            illegal_instr_o = 1'b0;
                        end
                    end

                    default: begin
                    end
						  
                endcase
            end


            // =================================================
            // R-type / M-type opcode class
            // 保留 INST_TYPE_R_M
            // 当前只实现RV32I部分
            // =================================================
            `INST_TYPE_R_M: begin

                reg1_raddr_o = rs1;
                reg2_raddr_o = rs2;

                uses_rs1_o = 1'b1;
                uses_rs2_o = 1'b1;

                reg_we_o    = `WriteEnable;
                reg_waddr_o = rd;

                op1_sel_o = `OP1_RS1;
                op2_sel_o = `OP2_RS2;


                case ({funct7, funct3})

                    {7'b0000000, `INST_ADD_SUB}: begin
                        alu_op_o = `ALU_ADD;
                        illegal_instr_o = 1'b0;
                    end

                    {7'b0100000, `INST_ADD_SUB}: begin
                        alu_op_o = `ALU_SUB;
                        illegal_instr_o = 1'b0;
                    end

                    {7'b0000000, `INST_SLL}: begin
                        alu_op_o = `ALU_SLL;
                        illegal_instr_o = 1'b0;
                    end

                    {7'b0000000, `INST_SLT}: begin
                        alu_op_o = `ALU_SLT;
                        illegal_instr_o = 1'b0;
                    end

                    {7'b0000000, `INST_SLTU}: begin
                        alu_op_o = `ALU_SLTU;
                        illegal_instr_o = 1'b0;
                    end

                    {7'b0000000, `INST_XOR}: begin
                        alu_op_o = `ALU_XOR;
                        illegal_instr_o = 1'b0;
                    end

                    {7'b0000000, `INST_SR}: begin
                        alu_op_o = `ALU_SRL;
                        illegal_instr_o = 1'b0;
                    end

                    {7'b0100000, `INST_SR}: begin
                        alu_op_o = `ALU_SRA;
                        illegal_instr_o = 1'b0;
                    end

                    {7'b0000000, `INST_OR}: begin
                        alu_op_o = `ALU_OR;
                        illegal_instr_o = 1'b0;
                    end

                    {7'b0000000, `INST_AND}: begin
                        alu_op_o = `ALU_AND;
                        illegal_instr_o = 1'b0;
                    end

                    default: begin
                    end

                endcase

            end


            // =================================================
            // LOAD
            // =================================================
            `INST_TYPE_L: begin

                reg1_raddr_o = rs1;

                uses_rs1_o = 1'b1;
                uses_rs2_o = 1'b0;

                reg_we_o    = `WriteEnable;
                reg_waddr_o = rd;

                imm_o = { {20{inst_i[31]}}, inst_i[31:20]};

                alu_op_o  = `ALU_ADD;
                op1_sel_o = `OP1_RS1;
                op2_sel_o = `OP2_IMM;


                case (funct3)

                    `INST_LB: begin
                        mem_op_o = `MEM_LB;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_LH: begin
                        mem_op_o = `MEM_LH;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_LW: begin
                        mem_op_o = `MEM_LW;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_LBU: begin
                        mem_op_o = `MEM_LBU;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_LHU: begin
                        mem_op_o = `MEM_LHU;
                        illegal_instr_o = 1'b0;
                    end

                    default: begin
                    end

                endcase

            end


            // =================================================
            // STORE
            // =================================================
            `INST_TYPE_S: begin

                reg1_raddr_o = rs1;
                reg2_raddr_o = rs2;

                uses_rs1_o = 1'b1;
                uses_rs2_o = 1'b1;

                imm_o = { {20{inst_i[31]}}, inst_i[31:25],  inst_i[11:7]    };

                alu_op_o  = `ALU_ADD;
                op1_sel_o = `OP1_RS1;
                op2_sel_o = `OP2_IMM;

                case (funct3)

                    `INST_SB: begin
                        mem_op_o = `MEM_SB;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_SH: begin
                        mem_op_o = `MEM_SH;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_SW: begin
                        mem_op_o = `MEM_SW;
                        illegal_instr_o = 1'b0;
                    end

                    default: begin
                    end

                endcase

            end


            // =================================================
            // BRANCH
            // =================================================
            `INST_TYPE_B: begin

                reg1_raddr_o = rs1;
                reg2_raddr_o = rs2;

                uses_rs1_o = 1'b1;
                uses_rs2_o = 1'b1;

                imm_o = { {20{inst_i[31]}},  inst_i[7],   inst_i[30:25],   inst_i[11:8],   1'b0  };

                alu_op_o  = `ALU_ADD;
                op1_sel_o = `OP1_PC;
                op2_sel_o = `OP2_IMM;

                case (funct3)

                    `INST_BEQ: begin
                        branch_op_o = `BR_BEQ;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_BNE: begin
                        branch_op_o = `BR_BNE;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_BLT: begin
                        branch_op_o = `BR_BLT;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_BGE: begin
                        branch_op_o = `BR_BGE;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_BLTU: begin
                        branch_op_o = `BR_BLTU;
                        illegal_instr_o = 1'b0;
                    end

                    `INST_BGEU: begin
                        branch_op_o = `BR_BGEU;
                        illegal_instr_o = 1'b0;
                    end

                    default: begin
                    end

                endcase

            end


            // =================================================
            // JAL
            // =================================================
            `INST_JAL: begin

                reg_we_o    = `WriteEnable;
                reg_waddr_o = rd;
					 
                imm_o = { {12{inst_i[31]}}, inst_i[19:12], inst_i[20],  inst_i[30:21], 1'b0 };

                alu_op_o  = `ALU_ADD;
                op1_sel_o = `OP1_PC;
                op2_sel_o = `OP2_FOUR;

                jump_op_o = `JUMP_JAL;

                illegal_instr_o = 1'b0;

            end


            // =================================================
            // JALR
            // =================================================
            `INST_JALR: begin

                reg1_raddr_o = rs1;

                uses_rs1_o = 1'b1;

                reg_we_o    = `WriteEnable;
                reg_waddr_o = rd;

                imm_o = { {20{inst_i[31]}},   inst_i[31:20]
                };

                alu_op_o  = `ALU_ADD;
                op1_sel_o = `OP1_PC;
                op2_sel_o = `OP2_FOUR;//这个是为了地址正常pc+4的操作数，跳转时需要将pc+4存入到rd中

                jump_op_o = `JUMP_JALR;

                if (funct3 == 3'b000)
                    illegal_instr_o = 1'b0;

            end


            // =================================================
            // LUI
            // =================================================
            `INST_LUI: begin

                reg_we_o    = `WriteEnable;
                reg_waddr_o = rd;

                imm_o = {   inst_i[31:12],  12'b0 };

                alu_op_o  = `ALU_ADD;
                op1_sel_o = `OP1_ZERO;
                op2_sel_o = `OP2_IMM;

                illegal_instr_o = 1'b0;

            end


            // =================================================
            // AUIPC
            // =================================================
            `INST_AUIPC: begin

                reg_we_o    = `WriteEnable;
                reg_waddr_o = rd;

                imm_o = {  inst_i[31:12],  12'b0 };

                alu_op_o  = `ALU_ADD;
                op1_sel_o = `OP1_PC;
                op2_sel_o = `OP2_IMM;

                illegal_instr_o = 1'b0;

            end


            // =================================================
            // FENCE
            // 第一版先不真正实现memory ordering
            // =================================================
            `INST_FENCE: begin

                if (funct3 == 3'b000)
                    illegal_instr_o = 1'b0;

            end


            default: begin
            end

        endcase

    end

endmodule
