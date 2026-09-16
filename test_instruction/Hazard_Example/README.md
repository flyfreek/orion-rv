# 定向流水线冒险测试

在 Windows PowerShell 中执行（不要在 Questa Transcript 中执行）：

```powershell
powershell -ExecutionPolicy Bypass -File D:\Orion-RV\tb\run_basic_tests.ps1 -Suite Hazard
```

脚本编译当前 RTL 和 TB，逐项启动命令行仿真。报告和每项完整日志位于
`D:/Orion-RV/build/hazard_regression_cli/`。不指定 `-Suite Hazard` 时仍运行原来的基础测试。

每份 `.data` 是可直接加载的 32 位十六进制镜像；同名 `.S` 是对应汇编清单，
注释标出每条指令地址。程序从 PC=0 开始，使用 0x10000000 开始的 TB RAM。
通过时 x27=1、x26=1；失败时 x27=0、x26=1，x3 对应下表编号。

| x3 | 镜像名（inst_ 前缀） | 关键序列 / 期望结果 | 期望暂停次数 |
|---|---|---|---|
| 1 | ex_mem | x5=41 后紧接 add x6,x5,x5，x6=82；两个操作数选 EX/MEM | 0 |
| 2 | mem_wb | x5=37 后隔一条 NOP 再 add，x6=74；两个操作数选 MEM/WB | 0 |
| 3 | dual_sources | x5=17、x7=29 后 add，x6=46；A 选 MEM/WB，B 选 EX/MEM | 0 |
| 4 | latest_priority | 连续写 x5=11、x5=43 后 add，x6=86；最新 EX/MEM 优先 | 0 |
| 5 | load_alu | lw x5 后紧接 add x6,x5,x5，x6=146 | 1 |
| 6 | load_branch | lw x5 后紧接 bne x5,x2,fail，加载后相等，不应跳转 | 1 |
| 7 | load_store_data | lw x5 后紧接 sw x5,4(x1)，读回 73 | 1 |
| 8 | load_store_addr | lw x5 后紧接 sw x2,0(x5)，目标地址读回 73 | 1 |

load 测试先把 x5 设置为 9，再加载不同的值，避免读旧值仍通过。
最终比较前留出间隔，隔离被测依赖序列。store 测试通过随后的 load 检查内存内容。

TB 的可选 `+EXPECT_STALLS` / `+CHECK_PC` / `+CHECK_A` / `+CHECK_B` 参数由脚本传入。
它们检查前递选择、load-use 暂停计数、Hold_If/Flush_Id 控制，以及时钟沿后 PC 和
IF/ID 保持、ID/EX 寄存器写使能清零和 MEM_NONE 气泡。任一检查失败都会使 TEST_FAIL。
只手动加载 `.data` 而不传入这些参数时，仍有程序自身的结果自检，但没有上述时序检查。

2026-09-16 Questa 实测：8 PASS、0 FAIL、0 TIMEOUT、0 ERROR。
四项前递各命中一次目标 PC 检查；四项 load-use 各暂停一次；monitor errors 均为 0。
这组测试不代表穷尽所有冒险场景：尚未覆盖全部字节/半字 load、所有分支方向、
x0/伪依赖排除、可变延迟内存等。测试针对当前固定延迟存储器模型。
