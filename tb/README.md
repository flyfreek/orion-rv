# Orion-RV core 仿真

## Memory / x0 / 参考模型

新增 `-Suite Memory`（7 项）、`-Suite X0`（4 项）、`-Suite Reference`（5 项），
均默认对比独立 Python RV32I 参考模型。原有 Basic/Hazard/Control 可加 `-Reference` 启用。
检查事件流、全部 32 个寄存器和 4096 个 RAM word；用法与范围见 [REFERENCE_CHECKING.md](REFERENCE_CHECKING.md)。

## Control Hazard 回归（PowerShell）

```powershell
powershell -ExecutionPolicy Bypass -File D:\Orion-RV\tb\run_basic_tests.ps1 -Suite Control
```

12 项跳转/冲刷定向测试，检查错误路径无副作用、较老指令继续提交、JAL/JALR 返回地址、
ALU/load 依赖、连续跳转和错误路径跳转。2026-09-16 实测 12 PASS。
镜像、汇编清单、参数和详细说明位于 `test_instruction/Control_Hazard`；
结果位于 `build/control_regression_cli/results.txt`。本轮未修改 core RTL。

## 专项冒险回归（PowerShell）

```powershell
powershell -ExecutionPolicy Bypass -File D:\Orion-RV\tb\run_basic_tests.ps1 -Suite Hazard
```

运行 `test_instruction/Hazard_Example` 中的 8 个测试，检查前递选择、load-use 暂停和结果。
2026-09-16 实测全部通过。详情见该目录 README.md；报告见 `build/hazard_regression_cli/results.txt`。

## GUI 批量运行 20 个基础测试

在 Questa 的 Transcript 输入：

```tcl
do D:/Orion-RV/tb/run_basic_tests.do
```

脚本会结束当前仿真、自动编译全部 core 和 TB，再独立运行 20 个 RV32I 基础镜像，
跳过 DIV/DIVU/REM/REMU。结束后保留 GUI，结果保存在
`D:/Orion-RV/build/basic_regression/results.txt`，包含每项 PASS/FAIL/TIMEOUT/ERROR、
x3、周期数及 SUMMARY。没有 SUMMARY 表示运行未完整结束。
脚本使用独立编译库，不删除 GUI 工程的 work 库；重复执行会更新上次报告。
项目移动后只需修改脚本开头的 `regression_root`。

TB 新增 `test_status` 供脚本判断：0=运行中，1=通过，2=失败，3=超时。
本次脚本编译已通过，但命令行加载设计被本机许可证 `Invalid host` 阻止，
尚未完成该脚本的端到端回归验证。若 GUI 同样报此错误，需先解决 Questa 许可证问题。

`orion_rv_core_tb.v` 只例化 `orion_rv` core，不包含原先的 SoC、RIB、JTAG 和外设。
TB 自带零等待的指令存储器与数据存储器模型，并沿用旧测试程序的判定协议：

- `x26 == 1`：程序执行结束
- `x27 == 1`：测试通过
- 测试失败时，`x3` 是失败用例编号

## 默认程序

请在工程根目录 `D:/Orion-RV` 运行：

```powershell
vsim -c -do tb/run_core_tb.do
```

默认加载：

```text
test_instruction/inst.data
```

## 切换测试程序

先按 `run_core_tb.do` 中的 `vlog` 命令完成编译，然后通过 `+PROG` 选择镜像，例如：

```powershell
vsim -c work.orion_rv_core_tb `
  +PROG=test_instruction/Baisc_Inst_Example/inst_add.data `
  -do "run -all; quit -f"
```

若不需要生成 `orion_rv_core_tb.vcd`，再添加 `+NO_VCD`。

## 存储器模型

- `0x0xxx_xxxx`：指令存储区，默认 256 个 32-bit word
- `0x1xxx_xxxx`：数据存储区，默认 4096 个 32-bit word
- 指令和数据均为组合读，数据写入发生在时钟上升沿
- core 已在 `mem.v` 内完成 `SB`/`SH` 的读改写，因此 TB 的 RAM 按整字写入

这些行为与 core 当前“固定单周期访存”的假设相匹配。

## 当前验证结果与范围

- 默认 `test_instruction/inst.data`：`TEST_PASS`（311 cycles）
- `Baisc_Inst_Example` 中现有 RV32I 算术、分支、跳转和移位镜像：通过
- `inst_div.data`、`inst_divu.data`、`inst_rem.data`、`inst_remu.data`：在用例 2 报
  `TEST_FAIL`；当前 core 的 `id.v`/`ex.v` 尚未实现 RV32M 执行单元，这是预期的设计能力差异
- `Other_Example` 中依赖 LED、PWM 等 MMIO 外设的程序不能仅靠 core TB 完整验证；这类程序仍需
  外设模型或 SoC TB

TB 会在仿真开始时把寄存器堆存储初始化为 0。该操作只存在于 TB 中，用于避免未初始化的
`X` 值让自检分支产生“假通过”，不影响综合出的 core。
