OpenRV
======

OpenRV is an open-source FPGA-based RISC-V computer system.

Goals:

- Custom RV64 CPU core
- FPGA SoC implementation
- Linux support
- MMU / Sv39
- Cache hierarchy
- RISC-V privileged architecture
- OpenSBI boot
- Custom compiler
- C/C++ application support

Long-term goal:

C++ Source
    ↓
OpenRV Compiler
    ↓
Linux
    ↓
OpenRV CPU
    ↓
FPGA