# ORION-RV Roadmap

ORION-RV is organized around milestones. Each milestone should produce a
clear, testable result before the project depends on it.

## M0 - Project Infrastructure

- Repository structure
- WSL environment
- Verilator
- Build system
- CI
- Documentation

## M1 - RV64I Core

Goal:

```text
RV64I ISA tests PASS
```

Includes:

- PC
- Register File
- Immediate Generator
- Decoder
- ALU
- Branch
- Load/Store
- Control
- Five-stage pipeline

## M2 - Bare-Metal SoC

Includes:

- RAM
- UART
- Simple interconnect
- Timer

Goal:

```text
Hello ORION!
```

## M3 - RV64IMAC

Add:

- M
- A
- C

## M4 - Cache and DDR

- I-Cache
- D-Cache
- DDR interface

## M5 - Privileged Architecture

- M-mode
- S-mode
- U-mode
- CSR
- Exception
- Trap
- Interrupt

## M6 - Sv39 MMU

- TLB
- Page Table Walker
- Sv39

## M7 - OrionOS

- Physical memory allocator
- Virtual memory
- Scheduler
- Process
- Syscall
- ELF loader
- ramfs
- shell

## M8 - Linux

- Device Tree
- OpenSBI
- Linux
- BusyBox

Final target:

```text
/ #
```

## M9 - OrionCC

Start with a simple C subset:

- Lexer
- Parser
- AST
- Semantic Analysis
- IR
- RV64 Backend

Gradually support C++ after the C subset is stable.

## M10 - Advanced CPU

Consider these after Linux is stable:

- Branch predictor
- Superscalar
- Out-of-order
- Register renaming
- ROB
- Reservation station
- Advanced cache
- Prefetcher
- RVV
