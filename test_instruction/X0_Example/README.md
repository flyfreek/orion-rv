# x0 regression

4 项覆盖 ALU/load/jump 丢弃写回、x0 读端口、前递排除、无假 load-use，以及 x0 作 store 数据/地址基址。
运行 `powershell -ExecutionPolicy Bypass -File D:\Orion-RV\tb\run_basic_tests.ps1 -Suite X0`。
默认包含参考模型对比；详细覆盖、日志位置与限制见 [参考模型说明](../../tb/REFERENCE_CHECKING.md)。
