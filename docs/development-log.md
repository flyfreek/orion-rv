# ORION-RV Development Log

## 2026-09-16 — RV32I implementation snapshot

- Imported the current Verilog RV32I five-stage core, forwarding, load-use detection and control logic.
- Saved the core-only Questa TB, PowerShell runners, test images, assembly listings and Python reference model.
- Verified 56/56 program images: Basic 20, Hazard 8, Control 12, Memory 7, X0 4, Reference 5.
- All 56 matched reference side-effect streams and final register/RAM state; 6 oracle unit tests passed.
- Preserved the original RV64/SoC/OS/compiler roadmap and repository scaffold as future work.
- Saved Quartus/Questa configuration and original design notes/diagrams; excluded generated outputs and local manuals.
- This snapshot adds no CPU architectural change as part of the GitHub publishing step.

## 2026-08-31

- Initialized ORION-RV repository.
- Selected RISC-V RV64 as the target ISA.
- Decided to use SystemVerilog for RTL.
- Development environment: WSL2 Ubuntu.
- FPGA tools will primarily run on Windows.
- Long-term target:
  - Custom RV64 CPU
  - FPGA SoC
  - OrionOS
  - Linux
  - OrionCC
- Current milestone: M0 project infrastructure.
- Next milestone: RV64I core.
