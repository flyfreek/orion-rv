 /*                                                                      
 Copyright 2019 Blue Liang, liangkangnan@163.com
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
 Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */
 

`define CpuResetAddr 32'h0

`define RstEnable 1'b0
`define RstDisable 1'b1
`define ZeroWord 32'h0
`define ZeroReg 5'h0
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define True 1'b1
`define False 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0
`define JumpEnable 1'b1
`define JumpDisable 1'b0
`define DivResultNotReady 1'b0
`define DivResultReady 1'b1
`define DivStart 1'b1
`define DivStop 1'b0
`define HoldEnable 1'b1
`define HoldDisable 1'b0
`define Stop 1'b1
`define NoStop 1'b0
`define RIB_ACK 1'b1
`define RIB_NACK 1'b0
`define RIB_REQ 1'b1
`define RIB_NREQ 1'b0
`define INT_ASSERT 1'b1
`define INT_DEASSERT 1'b0

`define INT_BUS 7:0
`define INT_NONE 8'h0
`define INT_RET 8'hff
`define INT_TIMER0 8'b00000001
`define INT_TIMER0_ENTRY_ADDR 32'h4

// ============================================================
// Pipeline Hold Control
//
// 数值越大，暂停的流水级越多
// ============================================================

`define Hold_Flag_Bus  2:0

`define Hold_None      3'b000
`define Hold_Pc        3'b001
`define Hold_If        3'b010
`define Hold_Id        3'b011
`define Hold_Ex        3'b100
`define Hold_Mem       3'b101

// ============================================================
// FLUSH
// bit0 : IF/ID
// bit1 : ID/EX
// bit2 : EX/MEM
// bit3 : MEM/WB
// ============================================================

`define Flush_Flag_Bus 3:0

`define Flush_None     4'b0000
`define Flush_If       4'b0001
`define Flush_Id       4'b0010
`define Flush_Ex       4'b0100
`define Flush_Mem      4'b1000


// I type inst
`define INST_TYPE_I 7'b0010011
`define INST_ADDI   3'b000
`define INST_SLTI   3'b010
`define INST_SLTIU  3'b011
`define INST_XORI   3'b100
`define INST_ORI    3'b110
`define INST_ANDI   3'b111
`define INST_SLLI   3'b001
`define INST_SRI    3'b101

// L type inst
`define INST_TYPE_L 7'b0000011
`define INST_LB     3'b000
`define INST_LH     3'b001
`define INST_LW     3'b010
`define INST_LBU    3'b100
`define INST_LHU    3'b101

// S type inst
`define INST_TYPE_S 7'b0100011
`define INST_SB     3'b000
`define INST_SH     3'b001
`define INST_SW     3'b010

// R and M type inst
`define INST_TYPE_R_M 7'b0110011
// R type inst
`define INST_ADD_SUB 3'b000
`define INST_SLL    3'b001
`define INST_SLT    3'b010
`define INST_SLTU   3'b011
`define INST_XOR    3'b100
`define INST_SR     3'b101
`define INST_OR     3'b110
`define INST_AND    3'b111
// M type inst
`define INST_MUL    3'b000
`define INST_MULH   3'b001
`define INST_MULHSU 3'b010
`define INST_MULHU  3'b011
`define INST_DIV    3'b100
`define INST_DIVU   3'b101
`define INST_REM    3'b110
`define INST_REMU   3'b111

// J type inst
`define INST_JAL    7'b1101111
`define INST_JALR   7'b1100111

`define INST_LUI    7'b0110111
`define INST_AUIPC  7'b0010111
`define INST_NOP    32'h00000001
`define INST_NOP_OP 7'b0000001
`define INST_MRET   32'h30200073
`define INST_RET    32'h00008067

`define INST_FENCE  7'b0001111
`define INST_ECALL  32'h73
`define INST_EBREAK 32'h00100073

// J type inst
`define INST_TYPE_B 7'b1100011
`define INST_BEQ    3'b000
`define INST_BNE    3'b001
`define INST_BLT    3'b100
`define INST_BGE    3'b101
`define INST_BLTU   3'b110
`define INST_BGEU   3'b111

// CSR inst
`define INST_CSR    7'b1110011
`define INST_CSRRW  3'b001
`define INST_CSRRS  3'b010
`define INST_CSRRC  3'b011
`define INST_CSRRWI 3'b101
`define INST_CSRRSI 3'b110
`define INST_CSRRCI 3'b111

// CSR reg addr
`define CSR_CYCLE   12'hc00
`define CSR_CYCLEH  12'hc80
`define CSR_MTVEC   12'h305
`define CSR_MCAUSE  12'h342
`define CSR_MEPC    12'h341
`define CSR_MIE     12'h304
`define CSR_MSTATUS 12'h300
`define CSR_MSCRATCH 12'h340

//`define RomNum 4096  // rom depth(how many words)
`define RomNum 256

//`define MemNum 4096  // memory depth(how many words)
`define MemNum 16

`define MemBus 31:0
`define MemAddrBus 31:0

`define InstBus 31:0
`define InstAddrBus 31:0

// common regs
`define RegAddrBus 4:0
`define RegBus 31:0
`define DoubleRegBus 63:0
`define RegWidth 32
`define RegNum 32        // reg num
`define RegNumLog2 5

// ============================================================
// ALU operation
// ============================================================

`define AluOpBus 3:0

`define ALU_ADD   4'b0000
`define ALU_SUB   4'b0001
`define ALU_SLL   4'b0010
`define ALU_SLT   4'b0011
`define ALU_SLTU  4'b0100
`define ALU_XOR   4'b0101
`define ALU_SRL   4'b0110
`define ALU_SRA   4'b0111
`define ALU_OR    4'b1000
`define ALU_AND   4'b1001

`define ALU_NONE  4'b1111


// ============================================================
// ALU operand 1 source
// ============================================================

`define Op1SelBus 1:0

`define OP1_RS1   2'b00
`define OP1_PC    2'b01
`define OP1_ZERO  2'b10


// ============================================================
// ALU operand 2 source
// ============================================================

`define Op2SelBus 1:0

`define OP2_RS2   2'b00
`define OP2_IMM   2'b01
`define OP2_FOUR  2'b10
`define OP2_ZERO  2'b11


// ============================================================
// Memory operation
// ============================================================

`define MemOpBus 3:0

`define MEM_NONE  4'b0000

// Load
`define MEM_LB    4'b0001
`define MEM_LH    4'b0010
`define MEM_LW    4'b0011
`define MEM_LBU   4'b0100
`define MEM_LHU   4'b0101

// Store
`define MEM_SB    4'b0110
`define MEM_SH    4'b0111
`define MEM_SW    4'b1000


// ============================================================
// Branch operation
// ============================================================

`define BranchOpBus 2:0

`define BR_NONE   3'b000
`define BR_BEQ    3'b001
`define BR_BNE    3'b010
`define BR_BLT    3'b011
`define BR_BGE    3'b100
`define BR_BLTU   3'b101
`define BR_BGEU   3'b110


// ============================================================
// Jump operation
// ============================================================

`define JumpOpBus 1:0

`define JUMP_NONE 2'b00
`define JUMP_JAL  2'b01
`define JUMP_JALR 2'b10
