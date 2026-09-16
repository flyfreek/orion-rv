# Memory、x0 与 RV32I 参考模型

## 2026-09-16 实测结果

| Suite | RTL 回归 | 参考对比 |
|---|---|---|
| Basic | 20 PASS | 20 REF_PASS |
| Hazard | 8 PASS | 8 REF_PASS |
| Control | 12 PASS | 12 REF_PASS |
| Memory | 7 PASS | 7 REF_PASS |
| X0 | 4 PASS | 4 REF_PASS |
| Reference | 5 PASS | 5 REF_PASS |
| 合计 | 56 PASS，0 FAIL/TIMEOUT/ERROR | 56 REF_PASS |

参考模型自身的 6 项单元测试全部通过（包括比较器拒绝错误记录的负例）。
本轮只修改测试镜像、TB、脚本和文档，没有修改 core RTL。

## 运行

在 Windows PowerShell 中执行，新三组默认启用参考模型：

```powershell
powershell -ExecutionPolicy Bypass -File D:\Orion-RV\tb\run_basic_tests.ps1 -Suite Memory
powershell -ExecutionPolicy Bypass -File D:\Orion-RV\tb\run_basic_tests.ps1 -Suite X0
powershell -ExecutionPolicy Bypass -File D:\Orion-RV\tb\run_basic_tests.ps1 -Suite Reference
```

原有三组可通过 `-Reference` 启用同样的对比：

```powershell
powershell -ExecutionPolicy Bypass -File D:\Orion-RV\tb\run_basic_tests.ps1 -Suite Basic -Reference
powershell -ExecutionPolicy Bypass -File D:\Orion-RV\tb\run_basic_tests.ps1 -Suite Hazard -Reference
powershell -ExecutionPolicy Bypass -File D:\Orion-RV\tb\run_basic_tests.ps1 -Suite Control -Reference
```

需要 Python 3（只用标准库）。默认使用 `python`，也可传 `-PythonExe C:/path/to/python.exe`。
每次运行先编译 RTL，再仿真；TB 必须 PASS，参考对比也必须 REF_PASS，汇总才会显示 PASS。
原有三组不传 `-Reference` 时保持原来的行为。

## 新增覆盖

### Memory：7 项

| 镜像 | 覆盖 |
|---|---|
| load_bytes | LB/LBU 的 offset 0/1/2/3；00、7f、80、ff 的符号/零扩展 |
| load_halves | LH/LHU 的 offset 0/2；0000、7fff、8000、ffff |
| words | SW/LW 的 0、ffffffff、80000000、7fffffff，多字地址及负立即数寻址 |
| store_bytes | SB 四种 offset；只替换目标字节，丢弃源寄存器高 24 位 |
| store_halves | SH 两种对齐 offset；只替换目标半字，丢弃源寄存器高 16 位 |
| store_mixed | 连续 SB/SB/SH 的整字读改写，检查同一字中之前的更新和相邻字未损坏 |
| bounds_rom | RAM 最后一个 word/byte/halfword；通过数据端口读取低地址指令 ROM |

每个镜像有 `.S` 阅读清单和 `.data`。这里的访存均自然对齐；LB/LBU/SB 可用任意 byte offset。
未对未对齐 LH/LW/SH/SW 作成功语义假设，也没有验证异常处理。

### x0：4 项

| 镜像 | 覆盖 |
|---|---|
| alu_discard | ADDI 和 10 种寄存器 ALU 指令写 x0，后续紧邻读取仍是零 |
| load_discard | LB/LBU/LH/LHU/LW 写 x0 仍执行读请求；紧邻读取不产生假 load-use |
| jump_discard | JAL/JALR 的 rd=x0 丢弃返回地址，跳转仍执行 |
| read_store_branch | 使用 x0 作 store 数据、比较操作数、ROM 地址基址 |

TB 逐周期检查寄存器存储、读端口、前递选择。全组要求暂停次数为 0；load_discard 要求真实
load 请求数为 5。寄存器初值沿用现有 TB 的零初始化，这不证明综合硬件带寄存器复位。

### Reference：5 项

- alu_edges：有符号/无符号比较、算术/逻辑右移，80000000/7fffffff/ffffffff 边界。
- mixed_seed_1、7、42、2026：每个程序生成 80 次随机操作选择，包含 ALU、立即数、
  所有 load/store 宽度、条件分支、JAL/JALR。控制流仅向前，保证终止；每项选择可能展开成多条指令。
- 混合程序不手写每一步答案。它们最后设置通过标记，是否正确由参考模型的完整事件和状态对比决定。

## 参考模型如何工作

`rv32i_reference.py` 不读取 RTL，也不使用 DUT 的译码控制或 ALU 结果执行程序。它从同一
`.data` 镜像取指，以独立的顺序解释器执行 RV32I 算术、逻辑、load/store、分支和跳转。
RAM 是字节数组；SB/SH 按字节更新，独立推导该 word 的最终值，以检查 DUT 的整字读改写总线。

TB 通过 `+TRACE=绝对路径` 输出：

- `W rd value`：真实 WB 寄存器写入（不记录写 x0，因为没有架构副作用）。
- `R address word`：MEM load 请求和读回整字，包含 rd=x0 的 load。
- `S address word`：MEM store 请求和实际写出的整字。
- `F index value`：结束时所有 32 个寄存器。
- `D index word`：结束时全部 4096 个 RAM word。
- `END`：完整结束标记；没有 END 不能通过。

由于该核的 store 在 MEM 提交、寄存器在 WB 提交，三类事件分别按流内顺序比较，
不把跨流水级的墙钟顺序误当作 ISA 提交顺序。会检查重复/遗漏/多余事件、每个值，以及最终状态。
这不是带指令 PC/valid 的逐条退休接口，也不是流水线时序模型；原有 Hazard/Control 监视器
继续负责暂停、冲刷和 PC 等微架构检查。

执行到 `jal x0,0` 且 x26=1、x27=1 时参考模型结束。超过步数、程序自检失败、未支持指令、
未对齐或越界访问均报 REF_FAIL，不静默跳过。ROM 为 1 KiB，RAM 为 16 KiB，复位 PC=0，
寄存器和 RAM 初值与 TB 一致。尚不支持 CSR、异常/中断、M 扩展、FENCE、自修改代码或 MMIO。
这是项目内的轻量参考实现，不等同于 Spike/Sail 或正式 ISA 合规验证。

## 日志与复现

每组输出在 `build/<suite小写>_regression_cli/`：

- `compile.log`：编译记录。
- `results.txt`：汇总。
- `inst_<name>.log`：仿真记录。
- `inst_<name>.trace`：原始 DUT 事件和最终状态。
- `inst_<name>.reference.json`：REF_PASS/REF_FAIL、事件数量或首个不一致位置。

单独复查参考结果：

```powershell
python D:/Orion-RV/tb/rv32i_reference.py --program D:/Orion-RV/test_instruction/Memory_Example/inst_load_bytes.data --trace D:/Orion-RV/build/memory_regression_cli/inst_load_bytes.trace --report D:/Orion-RV/build/memory_regression_cli/inst_load_bytes.reference.json
```

在工程根目录运行模型自身测试：

```powershell
python -m unittest discover -s tb -p test_rv32i_reference.py -v
```

六项测试使用手工编码向量，覆盖符号扩展、部分写保留、JALR 同源目的寄存器、x0 load、
不支持访问及比较器负例。负例故意改错寄存器写回、x0、RAM、加入额外 store 和删除 END，
均应被拒绝。

`generate_extended_tests.py` 使用固定 seed 生成这三组镜像/阅读清单/manifest 的 apply_patch 文本，
输出到 stdout 供审阅后应用；正常运行回归不需要重新生成。
