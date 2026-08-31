# Contributing to ORION-RV

ORION-RV is an early-stage hardware and systems project. Contributions should
favor clarity, reproducibility, and small reviewable steps.

## Development Principles

- Keep source code in the WSL Ubuntu filesystem, such as `~/orion-rv`.
- Do not move the repository into `/mnt/c/...`.
- Prefer generated Vivado projects from RTL, XDC, and TCL scripts instead of
  committing temporary Vivado project output.
- Keep changes focused on one subsystem when possible.
- Document design decisions in `docs/`.
- Add tests or runnable examples when changing behavior.

## Expected Tooling

- Git
- SystemVerilog
- Verilator
- C/C++
- Python
- CMake / Make
- RISC-V GCC
- LLVM
- Linux, OpenSBI, BusyBox
- Spike and/or QEMU

## Commit Style

Use short, descriptive commit messages. Examples:

```text
rtl: add initial fetch stage skeleton
sim: add verilator smoke test target
docs: describe boot flow
```

## Pull Request Checklist

- The change is scoped and documented.
- Generated build output is not committed.
- New source files are placed in the expected subsystem directory.
- Tests, scripts, or manual verification steps are described.
