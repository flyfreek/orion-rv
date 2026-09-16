`include "defines.v"

module orion_rv(

    input wire clk,
    input wire rst,

    // data memory
    output wire[`MemAddrBus] core_ex_addr_o,
    input  wire[`MemBus] core_ex_data_i,
    output wire[`MemBus] core_ex_data_o,
    output wire core_ex_req_o,
    output wire core_ex_we_o,

    // instruction memory
    output wire[`MemAddrBus] core_pc_addr_o,
    input  wire[`MemBus] core_pc_data_i

);


    // ========================================================
    // PC
    // ========================================================

    wire[`InstAddrBus] pc_pc_o;


    // ========================================================
    // IF/ID
    // ========================================================

    wire[`InstBus] if_inst_o;
    wire[`InstAddrBus] if_inst_addr_o;


    // ========================================================
    // ID
    // ========================================================

    wire[`RegAddrBus] id_reg1_raddr_o;
    wire[`RegAddrBus] id_reg2_raddr_o;

    wire[`InstBus] id_inst_o;
    wire[`InstAddrBus] id_inst_addr_o;

    wire[`RegBus] id_reg1_rdata_o;
    wire[`RegBus] id_reg2_rdata_o;

    wire id_uses_rs1_o;
    wire id_uses_rs2_o;

    wire[`RegBus] id_imm_o;

    wire[`AluOpBus] id_alu_op_o;
    wire[`Op1SelBus] id_op1_sel_o;
    wire[`Op2SelBus] id_op2_sel_o;

    wire[`MemOpBus] id_mem_op_o;

    wire[`BranchOpBus] id_branch_op_o;
    wire[`JumpOpBus] id_jump_op_o;

    wire id_reg_we_o;
    wire[`RegAddrBus] id_reg_waddr_o;

    wire id_illegal_instr_o;


    // ========================================================
    // ID/EX
    // ========================================================

    wire[`InstBus] ie_inst_o;
    wire[`InstAddrBus] ie_inst_addr_o;

    wire[`RegBus] ie_reg1_rdata_o;
    wire[`RegBus] ie_reg2_rdata_o;

    wire ie_uses_rs1_o;
    wire ie_uses_rs2_o;

    wire[`RegBus] ie_imm_o;

    wire[`AluOpBus] ie_alu_op_o;
    wire[`Op1SelBus] ie_op1_sel_o;
    wire[`Op2SelBus] ie_op2_sel_o;

    wire[`MemOpBus] ie_mem_op_o;

    wire[`BranchOpBus] ie_branch_op_o;
    wire[`JumpOpBus] ie_jump_op_o;

    wire ie_reg_we_o;
    wire[`RegAddrBus] ie_reg_waddr_o;

    wire ie_illegal_instr_o;


    // ========================================================
    // EX
    // ========================================================

    wire[`InstBus] ex_inst_o;

    wire[`MemOpBus] ex_mem_op_o;

    wire[`RegBus] ex_store_data_o;
    wire[`RegBus] ex_alu_result_o;

    wire ex_reg_we_o;
    wire[`RegAddrBus] ex_reg_waddr_o;

    wire ex_illegal_instr_o;

    wire ex_result_valid_o;

    wire ex_hold_flag_o;

    wire ex_jump_flag_o;
    wire[`InstAddrBus] ex_jump_addr_o;


    // ========================================================
    // EX/MEM
    // ========================================================

    wire[`InstBus] em_inst_o;

    wire[`MemOpBus] em_mem_op_o;

    wire em_reg_we_o;
    wire[`RegAddrBus] em_reg_waddr_o;

    wire[`RegBus] em_store_data_o;
    wire[`RegBus] em_alu_result_o;

    wire em_illegal_instr_o;

    wire em_result_valid_o;


    // ========================================================
    // Forwarding
    // ========================================================

    wire[1:0] forward_a_o;
    wire[1:0] forward_b_o;

    wire[`RegBus] ex_reg1_rdata_forward;
    wire[`RegBus] ex_reg2_rdata_forward;

    // Declared before the forwarding muxes that use it.
    wire[`RegBus] mw_reg_wdata_o;

    wire[`RegAddrBus] ex_rs1_addr;
    wire[`RegAddrBus] ex_rs2_addr;


    // 如果当前EX指令根本不使用rs1/rs2，
    // 就把地址置为x0，避免产生无意义forwarding
    assign ex_rs1_addr =
        ie_uses_rs1_o ? ie_inst_o[19:15] : `ZeroReg;

    assign ex_rs2_addr =
        ie_uses_rs2_o ? ie_inst_o[24:20] : `ZeroReg;


    assign ex_reg1_rdata_forward =
        (forward_a_o == 2'b01) ? em_alu_result_o :
        (forward_a_o == 2'b10) ? mw_reg_wdata_o :
                                 ie_reg1_rdata_o;


    assign ex_reg2_rdata_forward =
        (forward_b_o == 2'b01) ? em_alu_result_o :
        (forward_b_o == 2'b10) ? mw_reg_wdata_o :
                                 ie_reg2_rdata_o;


    // ========================================================
    // MEM
    // ========================================================

    wire[`RegBus] mem_reg_wdata_o;
    wire mem_reg_we_o;
    wire[`RegAddrBus] mem_reg_waddr_o;

    wire mem_illegal_instr_o;

    wire[`MemBus] mem_mem_wdata_o;
    wire[`MemAddrBus] mem_mem_addr_o;

    wire mem_mem_we_o;
    wire mem_mem_req_o;

    wire mem_hold_flag_o;


    // ========================================================
    // MEM/WB
    // ========================================================

    wire mw_reg_we_o;
    wire[`RegAddrBus] mw_reg_waddr_o;

    wire mw_illegal_instr_o;


    // ========================================================
    // WB
    // ========================================================

    wire[`RegBus] wb_reg_wdata_o;
    wire wb_reg_we_o;
    wire[`RegAddrBus] wb_reg_waddr_o;

    wire wb_illegal_instr_o;


    // ========================================================
    // Register File
    // ========================================================

    wire[`RegBus] regs_rdata1_o;
    wire[`RegBus] regs_rdata2_o;


    // ========================================================
    // CTRL
    // ========================================================

    wire[`Hold_Flag_Bus] ctrl_hold_flag_o;
    wire[`Flush_Flag_Bus] ctrl_flush_flag_o;

    wire ctrl_jump_flag_o;
    wire[`InstAddrBus] ctrl_jump_addr_o;


    // ========================================================
    // external interfaces
    // ========================================================

    assign core_ex_we_o   = mem_mem_we_o;
    assign core_ex_addr_o = mem_mem_addr_o;
    assign core_ex_data_o = mem_mem_wdata_o;
    assign core_ex_req_o  = mem_mem_req_o;

    assign core_pc_addr_o = pc_pc_o;


    // ========================================================
    // PC
    // ========================================================

    pc_reg u_pc_reg(

        .clk(clk),
        .rst(rst),

        .pc_o(pc_pc_o),

        .hold_flag_i(ctrl_hold_flag_o),

        .jump_flag_i(ctrl_jump_flag_o),
        .jump_addr_i(ctrl_jump_addr_o)

    );


    // ========================================================
    // CTRL
    // ========================================================

    ctrl u_ctrl(

        .rst(rst),

        .jump_flag_i(ex_jump_flag_o),
        .jump_addr_i(ex_jump_addr_o),

        .hold_flag_ex_i(ex_hold_flag_o),
        .hold_flag_mem_i(mem_hold_flag_o),
        .hold_flag_rib_i(`HoldDisable),
		  
		  .load_use_hazard_i(load_use_hazard),

        .hold_flag_o(ctrl_hold_flag_o),
        .flush_flag_o(ctrl_flush_flag_o),

        .jump_flag_o(ctrl_jump_flag_o),
        .jump_addr_o(ctrl_jump_addr_o)

    );


    // ========================================================
    // Register File
    // ========================================================

    regs u_regs(

        .clk(clk),
        .rst(rst),

        .we_i(wb_reg_we_o),
        .waddr_i(wb_reg_waddr_o),
        .wdata_i(wb_reg_wdata_o),

        .raddr1_i(id_reg1_raddr_o),
        .rdata1_o(regs_rdata1_o),

        .raddr2_i(id_reg2_raddr_o),
        .rdata2_o(regs_rdata2_o)

    );


    // ========================================================
    // IF/ID
    // ========================================================

    if_id u_if_id(

        .clk(clk),
        .rst(rst),

        .inst_i(core_pc_data_i),
        .inst_addr_i(pc_pc_o),

        .hold_flag_i(ctrl_hold_flag_o),
        .flush_flag_i(ctrl_flush_flag_o),

        .inst_o(if_inst_o),
        .inst_addr_o(if_inst_addr_o)

    );


    // ========================================================
    // ID
    // ========================================================

    id u_id(

        .inst_i(if_inst_o),
        .inst_addr_i(if_inst_addr_o),

        .reg1_rdata_i(regs_rdata1_o),
        .reg2_rdata_i(regs_rdata2_o),

        .reg1_raddr_o(id_reg1_raddr_o),
        .reg2_raddr_o(id_reg2_raddr_o),

        .inst_o(id_inst_o),
        .inst_addr_o(id_inst_addr_o),

        .reg1_rdata_o(id_reg1_rdata_o),
        .reg2_rdata_o(id_reg2_rdata_o),

        .uses_rs1_o(id_uses_rs1_o),
        .uses_rs2_o(id_uses_rs2_o),

        .imm_o(id_imm_o),

        .alu_op_o(id_alu_op_o),
        .op1_sel_o(id_op1_sel_o),
        .op2_sel_o(id_op2_sel_o),

        .mem_op_o(id_mem_op_o),

        .branch_op_o(id_branch_op_o),
        .jump_op_o(id_jump_op_o),

        .reg_we_o(id_reg_we_o),
        .reg_waddr_o(id_reg_waddr_o),

        .illegal_instr_o(id_illegal_instr_o)

    );

    // ========================================================
    // Hazard detection
    // ========================================================
	 
	 hazard_detection u_hazard_detection(

        // 上一条指令：现在在EX，也就是ID/EX输出
        .ex_mem_op_i(ie_mem_op_o),
        .ex_reg_we_i(ie_reg_we_o),
        .ex_reg_waddr_i(ie_reg_waddr_o),
        .ex_illegal_instr_i(ie_illegal_instr_o),
    
        // 当前指令：现在在ID
        .id_rs1_i(id_reg1_raddr_o),
        .id_rs2_i(id_reg2_raddr_o),
        .id_uses_rs1_i(id_uses_rs1_o),
        .id_uses_rs2_i(id_uses_rs2_o),
    
        .load_use_hazard_o(load_use_hazard)

    );
	 
    // ========================================================
    // ID/EX
    // ========================================================

    id_ex u_id_ex(

        .clk(clk),
        .rst(rst),

        .inst_i(id_inst_o),
        .inst_addr_i(id_inst_addr_o),

        .reg1_rdata_i(id_reg1_rdata_o),
        .reg2_rdata_i(id_reg2_rdata_o),

        .uses_rs1_i(id_uses_rs1_o),
        .uses_rs2_i(id_uses_rs2_o),

        .imm_i(id_imm_o),

        .alu_op_i(id_alu_op_o),
        .op1_sel_i(id_op1_sel_o),
        .op2_sel_i(id_op2_sel_o),

        .mem_op_i(id_mem_op_o),

        .branch_op_i(id_branch_op_o),
        .jump_op_i(id_jump_op_o),

        .reg_we_i(id_reg_we_o),
        .reg_waddr_i(id_reg_waddr_o),

        .illegal_instr_i(id_illegal_instr_o),

        .hold_flag_i(ctrl_hold_flag_o),
        .flush_flag_i(ctrl_flush_flag_o),

        .inst_o(ie_inst_o),
        .inst_addr_o(ie_inst_addr_o),

        .reg1_rdata_o(ie_reg1_rdata_o),
        .reg2_rdata_o(ie_reg2_rdata_o),

        .uses_rs1_o(ie_uses_rs1_o),
        .uses_rs2_o(ie_uses_rs2_o),

        .imm_o(ie_imm_o),

        .alu_op_o(ie_alu_op_o),
        .op1_sel_o(ie_op1_sel_o),
        .op2_sel_o(ie_op2_sel_o),

        .mem_op_o(ie_mem_op_o),

        .branch_op_o(ie_branch_op_o),
        .jump_op_o(ie_jump_op_o),

        .reg_we_o(ie_reg_we_o),
        .reg_waddr_o(ie_reg_waddr_o),

        .illegal_instr_o(ie_illegal_instr_o)

    );


    // ========================================================
    // EX
    // ========================================================

    ex u_ex(

        .inst_i(ie_inst_o),
        .inst_addr_i(ie_inst_addr_o),

        // forwarding之后的数据
        .reg1_rdata_i(ex_reg1_rdata_forward),
        .reg2_rdata_i(ex_reg2_rdata_forward),

        .imm_i(ie_imm_o),

        .alu_op_i(ie_alu_op_o),
        .op1_sel_i(ie_op1_sel_o),
        .op2_sel_i(ie_op2_sel_o),

        .mem_op_i(ie_mem_op_o),

        .branch_op_i(ie_branch_op_o),
        .jump_op_i(ie_jump_op_o),

        .reg_we_i(ie_reg_we_o),
        .reg_waddr_i(ie_reg_waddr_o),

        .illegal_instr_i(ie_illegal_instr_o),

        .inst_o(ex_inst_o),

        .mem_op_o(ex_mem_op_o),

        .store_data_o(ex_store_data_o),
        .alu_result_o(ex_alu_result_o),

        .reg_we_o(ex_reg_we_o),
        .reg_waddr_o(ex_reg_waddr_o),

        .illegal_instr_o(ex_illegal_instr_o),

        .result_valid_o(ex_result_valid_o),

        .hold_flag_o(ex_hold_flag_o),

        .jump_flag_o(ex_jump_flag_o),
        .jump_addr_o(ex_jump_addr_o)

    );


    // ========================================================
    // EX/MEM
    // ========================================================

    ex_mem u_ex_mem(

        .clk(clk),
        .rst(rst),

        .inst_i(ex_inst_o),

        .mem_op_i(ex_mem_op_o),

        .reg_we_i(ex_reg_we_o),
        .reg_waddr_i(ex_reg_waddr_o),

        .store_data_i(ex_store_data_o),
        .alu_result_i(ex_alu_result_o),

        .illegal_instr_i(ex_illegal_instr_o),

        .result_valid_i(ex_result_valid_o),

        .hold_flag_i(ctrl_hold_flag_o),
        .flush_flag_i(ctrl_flush_flag_o),

        .inst_o(em_inst_o),

        .mem_op_o(em_mem_op_o),

        .reg_we_o(em_reg_we_o),
        .reg_waddr_o(em_reg_waddr_o),

        .store_data_o(em_store_data_o),
        .alu_result_o(em_alu_result_o),

        .illegal_instr_o(em_illegal_instr_o),

        .result_valid_o(em_result_valid_o)

    );


    // ========================================================
    // Forwarding
    // ========================================================

    forwarding u_forwarding(

        // 当前EX指令
        .rs1_i(ex_rs1_addr),
        .rs2_i(ex_rs2_addr),

        // EX/MEM
        .ex_mem_reg_we_i(em_reg_we_o),
        .ex_mem_reg_waddr_i(em_reg_waddr_o),
        .ex_mem_result_valid_i(em_result_valid_o),

        // MEM/WB
        .mem_wb_reg_we_i(mw_reg_we_o),
        .mem_wb_reg_waddr_i(mw_reg_waddr_o),

        .forward_a_o(forward_a_o),
        .forward_b_o(forward_b_o)

    );


    // ========================================================
    // MEM
    // ========================================================

    mem u_mem(

        .mem_op_i(em_mem_op_o),

        .reg_we_i(em_reg_we_o),
        .reg_waddr_i(em_reg_waddr_o),

        .store_data_i(em_store_data_o),
        .alu_result_i(em_alu_result_o),

        .illegal_instr_i(em_illegal_instr_o),

        .mem_rdata_i(core_ex_data_i),

        .mem_wdata_o(mem_mem_wdata_o),
        .mem_addr_o(mem_mem_addr_o),

        .mem_we_o(mem_mem_we_o),
        .mem_req_o(mem_mem_req_o),

        .reg_wdata_o(mem_reg_wdata_o),

        .reg_we_o(mem_reg_we_o),
        .reg_waddr_o(mem_reg_waddr_o),

        .illegal_instr_o(mem_illegal_instr_o),

        .hold_flag_o(mem_hold_flag_o)

    );


    // ========================================================
    // MEM/WB
    // ========================================================

    mem_wb u_mem_wb(

        .clk(clk),
        .rst(rst),

        .reg_wdata_i(mem_reg_wdata_o),
        .reg_we_i(mem_reg_we_o),
        .reg_waddr_i(mem_reg_waddr_o),

        .illegal_instr_i(mem_illegal_instr_o),

        .hold_flag_i(ctrl_hold_flag_o),
        .flush_flag_i(ctrl_flush_flag_o),

        .reg_wdata_o(mw_reg_wdata_o),
        .reg_we_o(mw_reg_we_o),
        .reg_waddr_o(mw_reg_waddr_o),

        .illegal_instr_o(mw_illegal_instr_o)

    );


    // ========================================================
    // WB
    // ========================================================

    wb u_wb(

        .reg_wdata_i(mw_reg_wdata_o),
        .reg_we_i(mw_reg_we_o),
        .reg_waddr_i(mw_reg_waddr_o),

        .illegal_instr_i(mw_illegal_instr_o),

        .reg_wdata_o(wb_reg_wdata_o),
        .reg_we_o(wb_reg_we_o),
        .reg_waddr_o(wb_reg_waddr_o),

        .illegal_instr_o(wb_illegal_instr_o)

    );


endmodule
