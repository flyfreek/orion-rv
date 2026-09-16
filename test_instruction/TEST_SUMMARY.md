# Orion-RV 测试指令与回归总表

统计日期：2026-09-16。下表为当前正式回归的 **56 个测试镜像**，不是 56 条不同的 ISA 指令。测试名称列是主要目标，不代表镜像内只执行该指令。

当前实测：**56 PASS、0 FAIL、0 TIMEOUT、0 ERROR；56 个镜像均完成参考模型对比并得到 REF_PASS。**

参考对比检查三类有序事件（寄存器写回、load、store）以及最终全部 32 个寄存器和 4096 个 RAM word。Hazard/Control/X0 另含相应周期行为检查。

## 全部测试

| 编号 | 分组 | 测试镜像 | 主要指令/序列 | 检查内容 | 仿真 | 参考模型 |
|---:|---|---|---|---|---|---|
| 1 | Basic | [inst_add.data](Baisc_Inst_Example/inst_add.data) | ADD | 寄存器加法及测试程序内的数据依赖 | PASS | REF_PASS |
| 2 | Basic | [inst_andi.data](Baisc_Inst_Example/inst_andi.data) | ANDI | 立即数按位与 | PASS | REF_PASS |
| 3 | Basic | [inst_auipc.data](Baisc_Inst_Example/inst_auipc.data) | AUIPC | PC 加高位立即数 | PASS | REF_PASS |
| 4 | Basic | [inst_beq.data](Baisc_Inst_Example/inst_beq.data) | BEQ | 相等条件分支 | PASS | REF_PASS |
| 5 | Basic | [inst_bge.data](Baisc_Inst_Example/inst_bge.data) | BGE | 有符号大于等于分支 | PASS | REF_PASS |
| 6 | Basic | [inst_bgeu.data](Baisc_Inst_Example/inst_bgeu.data) | BGEU | 无符号大于等于分支 | PASS | REF_PASS |
| 7 | Basic | [inst_blt.data](Baisc_Inst_Example/inst_blt.data) | BLT | 有符号小于分支 | PASS | REF_PASS |
| 8 | Basic | [inst_bltu.data](Baisc_Inst_Example/inst_bltu.data) | BLTU | 无符号小于分支 | PASS | REF_PASS |
| 9 | Basic | [inst_bne.data](Baisc_Inst_Example/inst_bne.data) | BNE | 不相等条件分支 | PASS | REF_PASS |
| 10 | Basic | [inst_jal.data](Baisc_Inst_Example/inst_jal.data) | JAL | 直接跳转与返回地址 | PASS | REF_PASS |
| 11 | Basic | [inst_jalr.data](Baisc_Inst_Example/inst_jalr.data) | JALR | 寄存器间接跳转与返回地址 | PASS | REF_PASS |
| 12 | Basic | [inst_lui.data](Baisc_Inst_Example/inst_lui.data) | LUI | 高位立即数写入 | PASS | REF_PASS |
| 13 | Basic | [inst_ori.data](Baisc_Inst_Example/inst_ori.data) | ORI | 立即数按位或 | PASS | REF_PASS |
| 14 | Basic | [inst_simple.data](Baisc_Inst_Example/inst_simple.data) | ADDI、JAL | 最小程序与 x26/x27 测试结束协议 | PASS | REF_PASS |
| 15 | Basic | [inst_slli.data](Baisc_Inst_Example/inst_slli.data) | SLLI | 立即数逻辑左移 | PASS | REF_PASS |
| 16 | Basic | [inst_slti.data](Baisc_Inst_Example/inst_slti.data) | SLTI | 有符号立即数比较 | PASS | REF_PASS |
| 17 | Basic | [inst_sltiu.data](Baisc_Inst_Example/inst_sltiu.data) | SLTIU | 无符号立即数比较 | PASS | REF_PASS |
| 18 | Basic | [inst_srai.data](Baisc_Inst_Example/inst_srai.data) | SRAI | 立即数算术右移 | PASS | REF_PASS |
| 19 | Basic | [inst_srli.data](Baisc_Inst_Example/inst_srli.data) | SRLI | 立即数逻辑右移 | PASS | REF_PASS |
| 20 | Basic | [inst_xori.data](Baisc_Inst_Example/inst_xori.data) | XORI | 立即数按位异或 | PASS | REF_PASS |
| 21 | Hazard | [inst_ex_mem.data](Hazard_Example/inst_ex_mem.data) | ADDI → ADD | 两个操作数均从 EX/MEM 前递；结果 82，0 stall | PASS | REF_PASS |
| 22 | Hazard | [inst_mem_wb.data](Hazard_Example/inst_mem_wb.data) | ADDI → NOP → ADD | 两个操作数均从 MEM/WB 前递；结果 74，0 stall | PASS | REF_PASS |
| 23 | Hazard | [inst_dual_sources.data](Hazard_Example/inst_dual_sources.data) | ADDI、ADDI → ADD | A 来自 MEM/WB、B 来自 EX/MEM；结果 46 | PASS | REF_PASS |
| 24 | Hazard | [inst_latest_priority.data](Hazard_Example/inst_latest_priority.data) | 连续写同一寄存器 → ADD | EX/MEM 新值优先于 MEM/WB 旧值；结果 86 | PASS | REF_PASS |
| 25 | Hazard | [inst_load_alu.data](Hazard_Example/inst_load_alu.data) | LW → ADD | 紧邻使用加载结果；结果 146，1 stall | PASS | REF_PASS |
| 26 | Hazard | [inst_load_branch.data](Hazard_Example/inst_load_branch.data) | LW → BNE | 加载后比较相等，分支不跳转；1 stall | PASS | REF_PASS |
| 27 | Hazard | [inst_load_store_data.data](Hazard_Example/inst_load_store_data.data) | LW → SW | 加载结果作为 store 数据；读回 73，1 stall | PASS | REF_PASS |
| 28 | Hazard | [inst_load_store_addr.data](Hazard_Example/inst_load_store_addr.data) | LW → SW | 加载结果作为 store 地址；目标读回 73，1 stall | PASS | REF_PASS |
| 29 | Control | [inst_taken_store_reg.data](Control_Hazard/inst_taken_store_reg.data) | BEQ → 错误路径 SW、ADDI | taken 时两条错误路径均不提交 | PASS | REF_PASS |
| 30 | Control | [inst_taken_reg_store.data](Control_Hazard/inst_taken_reg_store.data) | BEQ → 错误路径 ADDI、SW | 交换错误路径顺序，覆盖两个被冲刷流水级 | PASS | REF_PASS |
| 31 | Control | [inst_not_taken.data](Control_Hazard/inst_not_taken.data) | BNE → SW、ADDI | not-taken 时无冲刷，后续两条指令各提交一次 | PASS | REF_PASS |
| 32 | Control | [inst_jal.data](Control_Hazard/inst_jal.data) | JAL | 目标、PC+4 返回地址及错误路径取消 | PASS | REF_PASS |
| 33 | Control | [inst_jalr.data](Control_Hazard/inst_jalr.data) | JALR | 目标最低位清零、PC+4 返回地址及错误路径取消 | PASS | REF_PASS |
| 34 | Control | [inst_alu_branch.data](Control_Hazard/inst_alu_branch.data) | ADDI → taken BEQ | 分支比较使用紧邻 ALU 的新值 | PASS | REF_PASS |
| 35 | Control | [inst_alu_jalr.data](Control_Hazard/inst_alu_jalr.data) | ADDI → JALR | 使用刚计算的跳转目标并写回正确返回地址 | PASS | REF_PASS |
| 36 | Control | [inst_load_branch.data](Control_Hazard/inst_load_branch.data) | LW → taken BEQ | 1 stall 后正确跳转、冲刷 | PASS | REF_PASS |
| 37 | Control | [inst_load_jalr.data](Control_Hazard/inst_load_jalr.data) | LW → JALR | 1 stall 后正确跳转、写回返回地址 | PASS | REF_PASS |
| 38 | Control | [inst_older_commit.data](Control_Hazard/inst_older_commit.data) | ADDI、SW → BEQ | redirect 当拍较老的 x18=55 和 store=73 均正常提交 | PASS | REF_PASS |
| 39 | Control | [inst_chain.data](Control_Hazard/inst_chain.data) | JAL → BEQ → JAL | 目标入口连续跳转，3 次 redirect，返回地址正确 | PASS | REF_PASS |
| 40 | Control | [inst_wrong_path_jump.data](Control_Hazard/inst_wrong_path_jump.data) | BEQ → 错误路径 JAL、SW | 错误路径 JAL 不改变控制流、不写返回地址，SW 不提交 | PASS | REF_PASS |
| 41 | Memory | [inst_load_bytes.data](Memory_Example/inst_load_bytes.data) | LB、LBU | offset 0/1/2/3；00、7f、80、ff 的符号/零扩展 | PASS | REF_PASS |
| 42 | Memory | [inst_load_halves.data](Memory_Example/inst_load_halves.data) | LH、LHU | offset 0/2；0000、7fff、8000、ffff 的符号/零扩展 | PASS | REF_PASS |
| 43 | Memory | [inst_words.data](Memory_Example/inst_words.data) | SW、LW | 0、ffffffff、80000000、7fffffff；多字地址及负立即数寻址 | PASS | REF_PASS |
| 44 | Memory | [inst_store_bytes.data](Memory_Example/inst_store_bytes.data) | SW、SB、LW | 四种 byte offset；仅更新目标 byte，截断源高 24 位 | PASS | REF_PASS |
| 45 | Memory | [inst_store_halves.data](Memory_Example/inst_store_halves.data) | SW、SH、LW | 两种对齐 halfword offset；仅更新目标 halfword，截断源高 16 位 | PASS | REF_PASS |
| 46 | Memory | [inst_store_mixed.data](Memory_Example/inst_store_mixed.data) | 连续 SB/SB/SH、LW | 读改写保留此前更新，相邻 word 不受影响 | PASS | REF_PASS |
| 47 | Memory | [inst_bounds_rom.data](Memory_Example/inst_bounds_rom.data) | SW、SB、SH、LH、LW、LBU | RAM 最后 word/byte/halfword，数据端口读 ROM | PASS | REF_PASS |
| 48 | X0 | [inst_alu_discard.data](X0_Example/inst_alu_discard.data) | ADDI、10 种寄存器 ALU → x0 | 丢弃写入，紧邻读取仍为 0；不对 x0 前递 | PASS | REF_PASS |
| 49 | X0 | [inst_load_discard.data](X0_Example/inst_load_discard.data) | LB/LBU/LH/LHU/LW → x0 | 5 次真实读请求，丢弃写回；不产生假 load-use，0 stall | PASS | REF_PASS |
| 50 | X0 | [inst_jump_discard.data](X0_Example/inst_jump_discard.data) | JAL/JALR rd=x0 | 跳转有效，丢弃返回地址，x0 保持 0 | PASS | REF_PASS |
| 51 | X0 | [inst_read_store_branch.data](X0_Example/inst_read_store_branch.data) | SW、LW、BNE，操作数含 x0 | x0 作写入数据、分支操作数和 ROM 地址基址 | PASS | REF_PASS |
| 52 | Reference | [inst_alu_edges.data](Reference_Example/inst_alu_edges.data) | SLT、SLTU、SRA、SRL、ADD、SUB、BGE、BLTU | 80000000/7fffffff/ffffffff 边界，有符号与无符号语义 | PASS | REF_PASS |
| 53 | Reference | [inst_mixed_seed_1.data](Reference_Example/inst_mixed_seed_1.data) | ALU、立即数、load/store、分支、JAL/JALR | seed=1；80 次混合操作选择，软件参考模型计算期望结果 | PASS | REF_PASS |
| 54 | Reference | [inst_mixed_seed_7.data](Reference_Example/inst_mixed_seed_7.data) | ALU、立即数、load/store、分支、JAL/JALR | seed=7；80 次混合操作选择，软件参考模型计算期望结果 | PASS | REF_PASS |
| 55 | Reference | [inst_mixed_seed_42.data](Reference_Example/inst_mixed_seed_42.data) | ALU、立即数、load/store、分支、JAL/JALR | seed=42；80 次混合操作选择，软件参考模型计算期望结果 | PASS | REF_PASS |
| 56 | Reference | [inst_mixed_seed_2026.data](Reference_Example/inst_mixed_seed_2026.data) | ALU、立即数、load/store、分支、JAL/JALR | seed=2026；80 次混合操作选择，软件参考模型计算期望结果 | PASS | REF_PASS |

## 分组与运行

在 Windows PowerShell 中执行（不是 Questa Transcript）：

```powershell
powershell -ExecutionPolicy Bypass -File D:\Orion-RV\tb\run_basic_tests.ps1 -Suite Memory
```

将 `Memory` 换成 `Basic`、`Hazard`、`Control`、`X0` 或 `Reference` 即可运行对应组。Basic/Hazard/Control 需再加 `-Reference` 才启用参考对比；Memory/X0/Reference 默认启用。

| Suite | 镜像数 | 镜像目录 | 结果文件 |
|---|---:|---|---|
| Basic | 20 | Baisc_Inst_Example | [results.txt](../build/basic_regression_cli/results.txt) |
| Hazard | 8 | Hazard_Example | [results.txt](../build/hazard_regression_cli/results.txt) |
| Control | 12 | Control_Hazard | [results.txt](../build/control_regression_cli/results.txt) |
| Memory | 7 | Memory_Example | [results.txt](../build/memory_regression_cli/results.txt) |
| X0 | 4 | X0_Example | [results.txt](../build/x0_regression_cli/results.txt) |
| Reference | 5 | Reference_Example | [results.txt](../build/reference_regression_cli/results.txt) |

## 不计入上述 56 项的文件和检查

| 项目 | 状态/说明 |
|---|---|
| test_instruction/inst.data | 默认单程序入口，之前已验证通过；不额外计入本轮 56 项 |
| inst_div.data、inst_divu.data、inst_rem.data、inst_remu.data | 基础目录中保留，但当前 core 未实现 RV32M，正式回归跳过；此前运行在用例 2 失败 |
| Extend_Inst_Example、Other_Example | 原 SoC 的扩展/外设程序，未纳入上述 core 回归；不宣称已通过 |
| test_rv32i_reference.py | 参考模型自身的 6 项单元测试全部通过，包含故意错误记录的拒绝测试；不是额外的 CPU 指令镜像 |

## 验证范围

以上为当前固定延迟内存环境下的定向与有限混合程序验证，不是完整 ISA 合规或穷尽验证。访存用例采用自然对齐地址，不覆盖未对齐异常、CSR/中断、M 扩展或可变延迟总线。

新分组中的 `.S` 是对应 `.data` 的汇编阅读清单；详细机制和参考模型边界见 [REFERENCE_CHECKING.md](../tb/REFERENCE_CHECKING.md)。

