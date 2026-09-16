# Control Hazard regression

## 运行

在 **Windows PowerShell**（不是 Questa Transcript）中执行：

```powershell
powershell -ExecutionPolicy Bypass -File D:\Orion-RV\tb\run_basic_tests.ps1 -Suite Control
```

脚本重新编译当前 core RTL 和 TB，并以 `vsim -c` 独立运行每个镜像。结果和完整日志保存在
`D:/Orion-RV/build/control_regression_cli/`。以 `results.txt` 最后的 SUMMARY 为完整回归结果。
每个 `.data` 配有同名 `.S` 汇编清单；清单注释包含地址和实际机器码。
清单中的标签地址立即数由生成镜像时解析，`.S` 是阅读清单，不是经特定工具链验证的构建输入。
`tests.json` 保存每项的检查 PC 范围、预期跳转/暂停/提交次数。

## 12 项定向测试

| x3 编号 | 镜像（inst_ 前缀） | 核心检查 |
|---|---|---|
| 1 | taken_store_reg | taken BEQ：紧随其后的 store 和寄存器写入均被取消 |
| 2 | taken_reg_store | 交换两条错误路径指令，覆盖 IF、ID 两个位置 |
| 3 | not_taken | not-taken BNE：后续 store 和寄存器写入各提交一次 |
| 4 | jal | 跳转目标、PC+4 返回地址、错误路径取消 |
| 5 | jalr | 无紧邻数据依赖的 JALR；目标寄存器最低位为 1，跳转清零该位 |
| 6 | alu_branch | ADDI 后紧接 taken BEQ，分支使用新值 |
| 7 | alu_jalr | ADDI 后紧接 JALR，使用刚计算的目标并写回正确返回地址 |
| 8 | load_branch | LW 后紧接 taken BEQ，暂停 1 拍后跳转并冲刷 |
| 9 | load_jalr | LW 后紧接 JALR，暂停 1 拍后跳转，返回地址正确 |
| 10 | older_commit | redirect 当拍，WB 的 x18=55 和 MEM 的 store=73 必须都完成 |
| 11 | chain | JAL → BEQ → JAL，三个目标入口立即继续跳转；检查两次返回地址 |
| 12 | wrong_path_jump | taken BEQ 的错误路径包含 JAL；JAL 不能跳转或写回返回地址 |

## 检查方式

- 所有程序自身检查目标路径标记 x6、受保护寄存器 x20、受保护 RAM word，以及适用的
  返回地址和较老指令结果。错误时 x27=0、x26=1，x3 是上表编号。
- x20 初值为 9，错误路径尝试写 123；RAM `0x10000004` 初值为 0，错误路径尝试写 73。
  TB 在每个真实写入时钟沿统计这两种副作用，不只是比较最终值，不能通过事后恢复掩盖错误。
  taken 测试预期两种提交都为 0；not-taken 测试预期各为 1。
- 在 tests.json 指定的被测 EX PC 范围内，TB 独立从指令编码重建分支/JAL/JALR 目标和条件，
  检查 redirect、`Flush_If | Flush_Id`、`Hold_None`；时钟沿后检查 PC、IF/ID 和 ID/EX 气泡。
  该解码使用 DUT 的前递后操作数，不是独立 ISA 参考模型；程序中的预期值补充检查数据正确性。
- taken 时，EX 指令本身必须继续进入 EX/MEM，较老的 MEM 写回结果必须继续进入 MEM/WB。
  older_commit 进一步检查同一个 redirect 时钟沿的 WB 写使能/目的寄存器/数据和 store
  请求/写使能/地址/数据，并在沿后检查寄存器和 RAM 实际更新。
- isolated not-taken 测试要求无冲刷、无暂停，PC 顺序前进，IF 和 ID 指令正常推进。
  这里没有同时发生其他控制事件，因此这条检查不能推广为任意情形下 not-taken 都禁止 flush。
- load-use 使用已有 TB 检查：PC/IF 保持、ID/EX 气泡以及预期暂停次数。
- 程序自检区域和末尾死循环不计入被测 redirect 次数，避免末尾 JAL 伪造覆盖。
- 任一计数或时序检查不满足，即使 x27=1，TB 也会报 TEST_FAIL。

## 实测结果与范围

2026-09-16：Questa 编译 0 errors、0 warnings；12 PASS、0 FAIL、0 TIMEOUT、0 ERROR。
每项 CONTROL_CHECK errors=0；load_branch/load_jalr 各暂停 1 拍；chain 命中 3 次 redirect；
older_commit 命中 1 次同拍较老指令提交。
同一轮还重跑了共用 TB 的原有两组：Basic 20 PASS、Hazard 8 PASS；三组共 40 项，
均无 FAIL、TIMEOUT 或 ERROR。

这些测试针对当前 EX 级决定跳转、固定延迟存储器的实现，不覆盖所有条件分支编码、
所有正负跳转偏移、异常/中断、总线等待或多周期执行组合。本次未修改 core RTL。

## GUI 查看其中一项

先运行上述回归以建立独立编译库，再在 Questa Transcript 中执行以下示例：

```tcl
vsim -onfinish stop -voptargs=+acc D:/Orion-RV/build/control_regression_cli/work.orion_rv_core_tb +PROG=D:/Orion-RV/test_instruction/Control_Hazard/inst_load_branch.data +NO_VCD +CONTROL_CHECK +EXPECT_STALLS=1 +CONTROL_START=72 +CONTROL_END=92 +EXPECT_REDIRECTS=1 +EXPECT_NOT_TAKEN=0 +EXPECT_POISON=0 +EXPECT_OLDER=0
add wave -r sim:/orion_rv_core_tb/*
run -all
```

其他镜像的参数从 tests.json 读取，或复制对应日志中的 vsim 命令并将 `-c -onfinish exit`
改为 `-onfinish stop`，移除 `-do` 中的 `quit -f`。
