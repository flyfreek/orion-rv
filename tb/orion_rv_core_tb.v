`timescale 1ns / 1ps

`include "defines.v"

// Core-only testbench for Orion-RV.
//
// The instruction image can be selected at run time:
//   vsim work.orion_rv_core_tb +PROG=test_instruction/inst.data
//
// The test protocol is kept compatible with tinyriscv_soc_tb.v:
//   x26 == 1 : test has finished
//   x27 == 1 : test passed
//   x3        : failing test number
module orion_rv_core_tb;

    parameter integer IMEM_WORDS     = 256;
    parameter integer DMEM_WORDS     = 4096;
    parameter integer TIMEOUT_CYCLES = 25000;

    reg clk;
    reg rst;

    wire [`MemAddrBus] core_ex_addr;
    reg  [`MemBus]     core_ex_rdata;
    wire [`MemBus]     core_ex_wdata;
    wire               core_ex_req;
    wire               core_ex_we;

    wire [`MemAddrBus] core_pc_addr;
    reg  [`MemBus]     core_pc_rdata;

    // Keep the same high-nibble address map as the old SoC:
    //   0x0xxx_xxxx -> instruction memory
    //   0x1xxx_xxxx -> data memory
    reg [`MemBus] imem [0:IMEM_WORDS-1];
    reg [`MemBus] dmem [0:DMEM_WORDS-1];

    reg [8*512-1:0] prog_file;
    integer i;
    integer cycle_count;
    integer r;
    // Machine-readable regression result: 0 running, 1 pass, 2 fail, 3 timeout.
    integer test_status = 0;
    integer trace_fd = 0;
    integer trace_index;
    reg [8*512-1:0] trace_file;
    integer x0_enabled = 0, x0_errors = 0, x0_loads = 0, expected_x0_loads = 0;
    wire x0_ok = !x0_enabled || (x0_errors == 0 && x0_loads == expected_x0_loads);
    initial begin
        if ($value$plusargs("TRACE=%s", trace_file)) begin
            trace_fd = $fopen(trace_file, "w");
            if (!trace_fd) $fatal(1, "Cannot open reference trace: %0s", trace_file);
        end
        x0_enabled = $test$plusargs("X0_CHECK");
        if ($value$plusargs("EXPECT_X0_LOADS=%d", expected_x0_loads)) begin end
    end
    // Separate side-effect streams: stores occur in MEM, register writes in WB.
    always @(posedge clk) begin
        if (rst == `RstDisable) begin
            if (trace_fd) begin
                if (dut.wb_reg_we_o && dut.wb_reg_waddr_o != 0)
                    $fdisplay(trace_fd, "W %h %h", dut.wb_reg_waddr_o, dut.wb_reg_wdata_o);
                if (core_ex_req && core_ex_we)
                    $fdisplay(trace_fd, "S %h %h", core_ex_addr, core_ex_wdata);
                if (core_ex_req && !core_ex_we)
                    $fdisplay(trace_fd, "R %h %h", core_ex_addr, core_ex_rdata);
            end
            if (x0_enabled) begin
                if (dut.u_regs.regs[0] !== 32'd0 ||
                    (dut.id_reg1_raddr_o == 0 && dut.regs_rdata1_o !== 32'd0) ||
                    (dut.id_reg2_raddr_o == 0 && dut.regs_rdata2_o !== 32'd0) ||
                    (dut.ex_rs1_addr == 0 && dut.forward_a_o !== 2'b00) ||
                    (dut.ex_rs2_addr == 0 && dut.forward_b_o !== 2'b00)) begin
                    x0_errors = x0_errors + 1;
                    $display("X0_ERROR: storage/read port/forwarding violation");
                end
                if (core_ex_req && !core_ex_we && dut.em_inst_o[11:7] == 0)
                    x0_loads = x0_loads + 1;
            end
        end
    end
    integer expected_stalls = -1;
    integer stall_count = 0;
    integer check_pc = -1;
    integer check_a = 0;
    integer check_b = 0;
    integer check_seen = 0;
    integer monitor_errors = 0;
    reg [31:0] saved_pc, saved_if_inst, saved_if_addr;
    initial begin
        if ($value$plusargs("EXPECT_STALLS=%d", expected_stalls)) begin end
        if ($value$plusargs("CHECK_PC=%d", check_pc)) begin end
        if ($value$plusargs("CHECK_A=%d", check_a)) begin end
        if ($value$plusargs("CHECK_B=%d", check_b)) begin end
    end
    // Optional directed-test checks, sampled before the active clock edge.
    always @(posedge clk) begin
        if (rst == `RstDisable && expected_stalls >= 0) begin
            if (check_pc >= 0 && dut.ie_inst_addr_o === check_pc &&
                dut.ie_inst_o != `INST_NOP) begin
                check_seen = check_seen + 1;
                if (dut.forward_a_o !== check_a[1:0] ||
                    dut.forward_b_o !== check_b[1:0]) begin
                    monitor_errors = monitor_errors + 1;
                    $display("HAZARD_ERROR: forwarding pc=%h a=%b b=%b",
                             dut.ie_inst_addr_o, dut.forward_a_o, dut.forward_b_o);
                end
            end
            if (dut.load_use_hazard === 1'b1) begin
                stall_count = stall_count + 1;
                saved_pc = core_pc_addr;
                saved_if_inst = dut.if_inst_o;
                saved_if_addr = dut.if_inst_addr_o;
                if (dut.ctrl_hold_flag_o !== `Hold_If ||
                    dut.ctrl_flush_flag_o !== `Flush_Id)
                    monitor_errors = monitor_errors + 1;
                #1;
                if (core_pc_addr !== saved_pc || dut.if_inst_o !== saved_if_inst ||
                    dut.if_inst_addr_o !== saved_if_addr ||
                    dut.ie_reg_we_o !== 1'b0 || dut.ie_mem_op_o !== `MEM_NONE) begin
                    monitor_errors = monitor_errors + 1;
                    $display("HAZARD_ERROR: PC/IF hold or ID/EX bubble failed");
                end
            end
        end
    end

    // Control regression: independent instruction decode at EX, plus edge checks.
    integer control_enabled = 0;
    integer control_start = 0, control_end = 0;
    integer expect_redirects = 0, expect_not_taken = 0, expect_poison = 0;
    integer expect_older = 0;
    integer redirects_seen = 0, not_taken_seen = 0, older_seen = 0;
    integer poison_reg_seen = 0, poison_mem_seen = 0, control_errors = 0;
    reg control_taken;
    reg [31:0] control_inst, control_pc, control_target;
    reg [31:0] control_fetch, control_decode;
    reg control_mem_we;
    reg [4:0] control_mem_rd;
    reg [31:0] control_mem_data;
    wire control_ok = !control_enabled ||
        (control_errors == 0 && redirects_seen == expect_redirects &&
         not_taken_seen == expect_not_taken && older_seen == expect_older &&
         poison_reg_seen == expect_poison && poison_mem_seen == expect_poison);

    initial begin
        control_enabled = $test$plusargs("CONTROL_CHECK");
        if ($value$plusargs("CONTROL_START=%d", control_start)) begin end
        if ($value$plusargs("CONTROL_END=%d", control_end)) begin end
        if ($value$plusargs("EXPECT_REDIRECTS=%d", expect_redirects)) begin end
        if ($value$plusargs("EXPECT_NOT_TAKEN=%d", expect_not_taken)) begin end
        if ($value$plusargs("EXPECT_POISON=%d", expect_poison)) begin end
        if ($value$plusargs("EXPECT_OLDER=%d", expect_older)) begin end
    end

    task control_error;
        input [8*120-1:0] reason;
        begin
            control_errors = control_errors + 1;
            $display("CONTROL_ERROR: time=%0t EX_PC=%h %0s", $time, control_pc, reason);
        end
    endtask

    // Count actual side-effect edges, not just final state (no restore can hide them).
    always @(posedge clk) begin
        if (rst == `RstDisable && control_enabled) begin
            if (dut.wb_reg_we_o === 1'b1 && dut.wb_reg_waddr_o == 20 &&
                dut.wb_reg_wdata_o === 32'd123)
                poison_reg_seen = poison_reg_seen + 1;
            if (core_ex_req === 1'b1 && core_ex_we === 1'b1 &&
                core_ex_addr === 32'h10000004)
                poison_mem_seen = poison_mem_seen + 1;
        end
    end

    always @(posedge clk) begin
        if (rst == `RstDisable && control_enabled &&
            dut.ie_inst_addr_o >= control_start && dut.ie_inst_addr_o < control_end &&
            (dut.ie_inst_o[6:0] == 7'h63 || dut.ie_inst_o[6:0] == 7'h6f ||
             dut.ie_inst_o[6:0] == 7'h67)) begin
            control_inst = dut.ie_inst_o;
            control_pc = dut.ie_inst_addr_o;
            control_taken = 1'b1;
            case (control_inst[6:0])
                7'h63: begin
                    case (control_inst[14:12])
                        0: control_taken = dut.ex_reg1_rdata_forward == dut.ex_reg2_rdata_forward;
                        1: control_taken = dut.ex_reg1_rdata_forward != dut.ex_reg2_rdata_forward;
                        4: control_taken = $signed(dut.ex_reg1_rdata_forward) < $signed(dut.ex_reg2_rdata_forward);
                        5: control_taken = $signed(dut.ex_reg1_rdata_forward) >= $signed(dut.ex_reg2_rdata_forward);
                        6: control_taken = dut.ex_reg1_rdata_forward < dut.ex_reg2_rdata_forward;
                        7: control_taken = dut.ex_reg1_rdata_forward >= dut.ex_reg2_rdata_forward;
                        default: control_taken = 1'bx;
                    endcase
                    control_target = control_pc + {{19{control_inst[31]}}, control_inst[31],
                        control_inst[7], control_inst[30:25], control_inst[11:8], 1'b0};
                end
                7'h6f: control_target = control_pc + {{11{control_inst[31]}}, control_inst[31],
                    control_inst[19:12], control_inst[20], control_inst[30:21], 1'b0};
                7'h67: control_target = (dut.ex_reg1_rdata_forward +
                    {{20{control_inst[31]}}, control_inst[31:20]}) & 32'hfffffffe;
            endcase
            if (control_taken === 1'b1) begin
                redirects_seen = redirects_seen + 1;
                if (dut.ctrl_jump_flag_o !== 1'b1 ||
                    dut.ctrl_jump_addr_o !== control_target ||
                    dut.ctrl_flush_flag_o !== (`Flush_If | `Flush_Id) ||
                    dut.ctrl_hold_flag_o !== `Hold_None)
                    control_error("redirect target/flush/hold mismatch");
                control_mem_we = dut.mem_reg_we_o;
                control_mem_rd = dut.mem_reg_waddr_o;
                control_mem_data = dut.mem_reg_wdata_o;
                if (expect_older) begin
                    older_seen = older_seen + 1;
                    if (dut.wb_reg_we_o !== 1'b1 || dut.wb_reg_waddr_o !== 5'd18 ||
                        dut.wb_reg_wdata_o !== 32'd55 || core_ex_req !== 1'b1 ||
                        core_ex_we !== 1'b1 || core_ex_addr !== 32'h10000008 ||
                        core_ex_wdata !== 32'd73)
                        control_error("older WB and store must commit on the redirect edge");
                end
                #1;
                if (core_pc_addr !== control_target || dut.if_inst_o !== `INST_NOP ||
                    dut.ie_inst_o !== `INST_NOP || dut.ie_reg_we_o !== 1'b0 ||
                    dut.ie_mem_op_o !== `MEM_NONE || dut.ie_branch_op_o !== `BR_NONE ||
                    dut.ie_jump_op_o !== `JUMP_NONE)
                    control_error("PC redirect or IF/ID and ID/EX flush failed");
                if (dut.em_inst_o !== control_inst || dut.mw_reg_we_o !== control_mem_we ||
                    (control_mem_we && (dut.mw_reg_waddr_o !== control_mem_rd ||
                     dut.mw_reg_wdata_o !== control_mem_data)))
                    control_error("redirect instruction or older MEM result was killed");
                if (expect_older && (dut.u_regs.regs[18] !== 32'd55 || dmem[2] !== 32'd73))
                    control_error("older register/store side effects not preserved");
            end else if (control_taken === 1'b0) begin
                not_taken_seen = not_taken_seen + 1;
                if (dut.ctrl_jump_flag_o !== 1'b0 || dut.ctrl_flush_flag_o !== `Flush_None ||
                    dut.ctrl_hold_flag_o !== `Hold_None)
                    control_error("isolated not-taken branch must not flush or stall");
                control_target = core_pc_addr + 4;
                control_fetch = core_pc_rdata;
                control_decode = dut.if_inst_o;
                #1;
                if (core_pc_addr !== control_target || dut.if_inst_o !== control_fetch ||
                    dut.ie_inst_o !== control_decode)
                    control_error("not-taken sequential flow lost instructions");
            end else control_error("unknown branch comparison");
        end
    end

    wire [`RegBus] x3  = dut.u_regs.regs[3];
    wire [`RegBus] x26 = dut.u_regs.regs[26];
    wire [`RegBus] x27 = dut.u_regs.regs[27];

    always #10 clk = ~clk;  // 50 MHz

    // Asynchronous instruction-memory read. A RISC-V NOP is returned for
    // unmapped/out-of-range addresses so that an accidental fetch is benign.
    always @(*) begin
        core_pc_rdata = 32'h0000_0013;
        if ((core_pc_addr[31:28] == 4'h0) &&
            (core_pc_addr[27:2] < IMEM_WORDS)) begin
            core_pc_rdata = imem[core_pc_addr[27:2]];
        end
    end

    // Asynchronous data read. Reading region 0 also permits programs to load
    // constants from their instruction image, matching the old SoC map.
    always @(*) begin
        core_ex_rdata = `ZeroWord;
        case (core_ex_addr[31:28])
            4'h0: begin
                if (core_ex_addr[27:2] < IMEM_WORDS)
                    core_ex_rdata = imem[core_ex_addr[27:2]];
            end
            4'h1: begin
                if (core_ex_addr[27:2] < DMEM_WORDS)
                    core_ex_rdata = dmem[core_ex_addr[27:2]];
            end
            default: core_ex_rdata = `ZeroWord;
        endcase
    end

    // The core's MEM stage already performs byte/half-word read-modify-write,
    // therefore the external memory model only needs a full 32-bit write port.
    always @(posedge clk) begin
        if ((rst == `RstDisable) && core_ex_req && core_ex_we) begin
            case (core_ex_addr[31:28])
                4'h0: begin
                    if (core_ex_addr[27:2] < IMEM_WORDS)
                        imem[core_ex_addr[27:2]] <= core_ex_wdata;
                    else
                        $display("WARNING: out-of-range IMEM write at 0x%08x",
                                 core_ex_addr);
                end
                4'h1: begin
                    if (core_ex_addr[27:2] < DMEM_WORDS)
                        dmem[core_ex_addr[27:2]] <= core_ex_wdata;
                    else
                        $display("WARNING: out-of-range DMEM write at 0x%08x",
                                 core_ex_addr);
                end
                default: begin
                    $display("WARNING: write to unmapped address 0x%08x",
                             core_ex_addr);
                end
            endcase
        end
    end

    initial begin
        clk = 1'b0;
        rst = `RstEnable;
        cycle_count = 0;

        for (i = 0; i < IMEM_WORDS; i = i + 1)
            imem[i] = 32'h0000_0013;
        for (i = 0; i < DMEM_WORDS; i = i + 1)
            dmem[i] = `ZeroWord;
        // regs.v intentionally has no reset loop. Initialize its storage here
        // to prevent X values from making a self-checking branch falsely pass.
        for (i = 0; i < `RegNum; i = i + 1)
            dut.u_regs.regs[i] = `ZeroWord;

        prog_file = "D:/Orion-RV/test_instruction/inst.data";
        if (!$value$plusargs("PROG=%s", prog_file)) begin
            $display("No +PROG supplied; using default image.");
        end
        $display("Loading program: %0s", prog_file);
        $readmemh(prog_file, imem);

        // Active-low reset, matching defines.v and the old SoC testbench.
        repeat (2) @(posedge clk);
        #1 rst = `RstDisable;
        $display("Orion-RV core test running...");
    end

    // Finish and report using the same register convention as the old TB.
    initial begin
        wait (rst == `RstDisable);
        wait (x26 === 32'd1);
        repeat (5) @(posedge clk);
        #1;

        if (expected_stalls >= 0) begin
            $display("HAZARD_CHECK: stalls=%0d expected=%0d forwarding_checks=%0d errors=%0d",
                     stall_count, expected_stalls, check_seen, monitor_errors);
        end
        if (control_enabled) begin
            $display("CONTROL_CHECK: redirects=%0d/%0d not_taken=%0d/%0d older=%0d/%0d poison_reg=%0d/%0d poison_mem=%0d/%0d errors=%0d",
                redirects_seen, expect_redirects, not_taken_seen, expect_not_taken,
                older_seen, expect_older, poison_reg_seen, expect_poison,
                poison_mem_seen, expect_poison, control_errors);
        end
        if (x0_enabled)
            $display("X0_CHECK: loads=%0d/%0d errors=%0d", x0_loads, expected_x0_loads, x0_errors);
        if (x27 === 32'd1 && control_ok && x0_ok && (expected_stalls < 0 ||
            (stall_count == expected_stalls && monitor_errors == 0 &&
             (check_pc < 0 || check_seen == 1)))) begin
            test_status = 1;
            $display("==================================================");
            $display("TEST_PASS: %0s", prog_file);
            $display("cycles = %0d", cycle_count);
            $display("==================================================");
        end else begin
            test_status = 2;
            $display("==================================================");
            $display("TEST_FAIL: %0s", prog_file);
            $display("fail testnum = %0d (x3 = 0x%08x)", x3, x3);
            $display("==================================================");
            for (r = 0; r < 32; r = r + 1)
                $display("x%0d = 0x%08x", r, dut.u_regs.regs[r]);
        end

        if (trace_fd) begin
            for (trace_index = 0; trace_index < 32; trace_index = trace_index + 1)
                $fdisplay(trace_fd, "F %h %h", trace_index, dut.u_regs.regs[trace_index]);
            for (trace_index = 0; trace_index < DMEM_WORDS; trace_index = trace_index + 1)
                $fdisplay(trace_fd, "D %h %h", trace_index, dmem[trace_index]);
            $fdisplay(trace_fd, "END");
            $fclose(trace_fd);
        end
        $finish;
    end

    // Cycle-based timeout is independent of the selected clock period.
    always @(posedge clk) begin
        if (rst == `RstDisable) begin
            cycle_count <= cycle_count + 1;
            if (cycle_count >= TIMEOUT_CYCLES) begin
                test_status = 3;
                $display("==================================================");
                $display("TEST_TIMEOUT: %0s", prog_file);
                $display("pc = 0x%08x, x26 = 0x%08x, x27 = 0x%08x",
                         core_pc_addr, x26, x27);
                $display("==================================================");
                $finish;
            end
        end
    end

    // Disable with +NO_VCD when only the textual result is needed.
    initial begin
        if (!$test$plusargs("NO_VCD")) begin
            $dumpfile("orion_rv_core_tb.vcd");
            $dumpvars(0, dut);
        end
    end

    orion_rv dut (
        .clk            (clk),
        .rst            (rst),
        .core_ex_addr_o (core_ex_addr),
        .core_ex_data_i (core_ex_rdata),
        .core_ex_data_o (core_ex_wdata),
        .core_ex_req_o  (core_ex_req),
        .core_ex_we_o   (core_ex_we),
        .core_pc_addr_o (core_pc_addr),
        .core_pc_data_i (core_pc_rdata)
    );

endmodule
