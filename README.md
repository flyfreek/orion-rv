# ORION-RV

ORION-RV is an open-source RISC-V computing platform built from the ground up.

CPU · FPGA · Operating System · Linux · Compiler

ORION-RV is currently in early development. The repository is being organized
for long-term work on a custom RV64 CPU, FPGA SoC, firmware, operating systems,
compiler, and applications.

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
