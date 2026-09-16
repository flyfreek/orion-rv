# ORION-RV

ORION-RV is an open-source RISC-V computing platform built from the ground up.

CPU · FPGA · Operating System · Linux · Compiler

ORION-RV is currently in early development. The repository is being organized
for long-term work on a custom RV64 CPU, FPGA SoC, firmware, operating systems,
compiler, and applications.

## Current Implementation — RV32I Core (2026-09-16)

The current working implementation is a **32-bit, five-stage RV32I core** in
Verilog. The RV64/Linux architecture below remains a long-term goal, not an
implemented capability of this snapshot.

- IF/ID/EX/MEM/WB pipeline with EX/MEM and MEM/WB forwarding.
- Load-use hazard detection, pipeline hold/bubble insertion and branch/jump flush.
- Byte/halfword/word loads and stores, using the current fixed-latency memory interface.
- Core-only Questa testbench, PowerShell regressions and an independent Python reference model.
- **56 program images passed simulation and reference comparison** on 2026-09-16;
  6 reference-model unit tests also passed.
- M-extension, CSR, traps/interrupts, MMU and Linux boot are not implemented here.

| Suite | Programs | Result |
|---|---:|---|
| Basic | 20 | PASS + REF_PASS |
| Hazard | 8 | PASS + REF_PASS |
| Control | 12 | PASS + REF_PASS |
| Memory | 7 | PASS + REF_PASS |
| X0 | 4 | PASS + REF_PASS |
| Reference | 5 | PASS + REF_PASS |

See the [complete test table](test_instruction/TEST_SUMMARY.md),
[verification guide](tb/REFERENCE_CHECKING.md), and
[saved regression results](docs/cpu/regression-results-2026-09-16.json).
This is directed and finite mixed-program verification, not exhaustive ISA certification.

### Run the current Windows/Questa flow

From the repository root, in PowerShell (not the Questa Transcript):

```powershell
powershell -ExecutionPolicy Bypass -File .\tb\run_basic_tests.ps1 -Suite Basic -Reference
powershell -ExecutionPolicy Bypass -File .\tb\run_basic_tests.ps1 -Suite Hazard -Reference
powershell -ExecutionPolicy Bypass -File .\tb\run_basic_tests.ps1 -Suite Control -Reference
powershell -ExecutionPolicy Bypass -File .\tb\run_basic_tests.ps1 -Suite Memory
powershell -ExecutionPolicy Bypass -File .\tb\run_basic_tests.ps1 -Suite X0
powershell -ExecutionPolicy Bypass -File .\tb\run_basic_tests.ps1 -Suite Reference
python -m unittest discover -s tb -p test_rv32i_reference.py -v
```

Requires licensed Questa and Python 3. Use `-QuestaBin C:/path/to/questa/win64`
and `-PythonExe C:/path/to/python.exe` if needed. The batch script resolves the
repository path automatically. Historical GUI project files and older `.do`
examples retain local Windows paths; the PowerShell runner is the tested entry point.

Current implementation paths are `rtl/core`, `rtl/utils`, `tb`, `test_instruction`,
`prj/quartus`, `prj/questa` and `word` (design notes/diagrams). The other scaffold
directories below are preserved for future work. Generated libraries, waveforms,
logs, FPGA outputs and local reference PDFs are excluded from Git.

Third-party source headers retain their original notices; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). The existing repository MIT
license does not replace separately identified upstream notices.

## Architecture

```text
C / C++ Applications
        |
     OrionCC
        |
 +------+------+
 |             |
OrionOS       Linux
 |             |
 +------+------+
        |
OpenSBI / Firmware
        |
OrionSoC
        |
OrionCore
        |
FPGA
```

## Long-Term Goals

- RV64 CPU
- FPGA implementation
- Custom SoC
- Cache hierarchy
- Privileged Architecture
- Sv39 MMU
- Boot OpenSBI.
- Boot Linux with BusyBox.
- OrionOS
- OrionCC
- C/C++ applications

## Repository Layout

- `rtl/`: SystemVerilog CPU, cache, SoC, and top-level RTL.
- `sim/`: Verilator simulation, testbenches, and differential testing.
- `fpga/`: FPGA constraints and scripts.
- `firmware/`: Boot ROM and OpenSBI integration.
- `os/`: OrionOS kernel, libc, user programs, and headers.
- `linux/`: Linux configs and device trees.
- `compiler/`: OrionCC compiler sources.
- `software/`: Bare-metal programs and software tests.
- `tests/`: ISA, CPU, SoC, and OS tests.
- `docs/`: Architecture notes, design documents, and development logs.
- `scripts/`: Development automation.

## Development Environment

Source code should live in the WSL Ubuntu filesystem, for example:

```sh
~/orion-rv
```

Daily development is expected to happen in WSL with Git, SystemVerilog,
Verilator, C/C++, Python, CMake/Make, RISC-V GCC, LLVM, Linux, OpenSBI,
BusyBox, Spike/QEMU, and automated tests.

Windows is mainly used for VS Code Remote WSL, Vivado GUI, FPGA programming,
and serial debugging.
