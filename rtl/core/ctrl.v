`include "defines.v"

// 控制模块
// 负责流水线暂停、冲刷以及PC跳转
module ctrl(

    input wire rst,

    // from EX
    input wire jump_flag_i,
    input wire[`InstAddrBus] jump_addr_i,
    input wire hold_flag_ex_i,

    // from MEM
    input wire hold_flag_mem_i,

    // from RIB
    input wire hold_flag_rib_i,
	 
	 //from Hazard detection
	 input wire load_use_hazard_i,

    // pipeline control
    output reg[`Hold_Flag_Bus] hold_flag_o,
    output reg[`Flush_Flag_Bus] flush_flag_o,

    // to PC
    output reg jump_flag_o,
    output reg[`InstAddrBus] jump_addr_o

);


    always @(*) begin
        hold_flag_o  = `Hold_None;
        flush_flag_o = `Flush_None;
        jump_flag_o = `JumpDisable;
        jump_addr_o = `ZeroWord;

        if (!rst) begin
            hold_flag_o  = `Hold_None;
            flush_flag_o = `Flush_None;
            jump_flag_o = `JumpDisable;
            jump_addr_o = `ZeroWord;
        end
        // MEM暂停优先级最高
        else if (hold_flag_mem_i == `HoldEnable) begin
            // 保持当前正在MEM等待的指令以及所有更年轻指令
            hold_flag_o = `Hold_Ex;
            // MEM结果还没有完成，不能进入MEM/WB
            flush_flag_o = `Flush_Mem;
        end
        // EX多周期执行暂停
        else if (hold_flag_ex_i == `HoldEnable) begin
            // 当前EX指令保持在ID/EX
            hold_flag_o = `Hold_Id;
            // 不让未完成结果进入EX/MEM
            flush_flag_o = `Flush_Ex;
        end
        // Branch / JAL / JALR跳转
        else if (jump_flag_i == `JumpEnable) begin
            jump_flag_o = `JumpEnable;
            jump_addr_o = jump_addr_i;
            // EX中的跳转指令本身继续向后执行
            // 清掉IF和ID中的两条错误路径指令
            flush_flag_o = `Flush_If | `Flush_Id;
        end
		  else if (load_use_hazard_i) begin
            // 当前ID指令留在ID重新等待一拍
            // PC和IF/ID保持
            hold_flag_o = `Hold_If;
            // EX中的Load已经执行完地址计算，
            // 让它继续进入EX/MEM；
            // ID/EX清空，向EX插入一个bubble
            flush_flag_o = `Flush_Id;
        end
        // 取指总线暂停
        else if (hold_flag_rib_i == `HoldEnable) begin 
            // 当前下一条指令还没有取回来
            // PC保持，等待重新取指
            hold_flag_o = `Hold_Pc;
            // 当前IF/ID中的指令已经可以继续进入ID/EX，
            // 所以不能hold IF/ID，否则会重复执行
            flush_flag_o = `Flush_If;
        end
        else begin
            hold_flag_o  = `Hold_None;
            flush_flag_o = `Flush_None;
        end
    end
endmodule
