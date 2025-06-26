# RISC-V 五级流水线 CPU (FPGA/Verilog)

## 项目简介

本项目实现了基于 RISC-V RV32I 指令集的五级流水线 CPU，包括完整的数据通路、控制器、寄存器堆、ALU、指令/数据存储器等模块，支持所有 I-type 和 R-type 算术逻辑指令。适用于 FPGA 课程设计、体系结构实验与仿真验证。

## 目录结构

```
├── src/                # Verilog源代码（CPU、控制器、数据通路等）
├── programs/           # 测试程序及机器码文件
├── PipelineCPU/        # Vivado工程目录及生成文件
├── constraints/        # FPGA约束文件
├── coe/                # 存储器初始化文件
├── RISCV指令.md        # 指令集说明
```

## 主要功能

- 支持 RISC-V RV32I 全部 I-type 与 R-type 算术逻辑指令
- 五级经典流水线（IF/ID/EX/MEM/WB）
- 完整的寄存器堆、ALU、控制器、数据通路
- 支持仿真与 FPGA 综合

## 仿真与验证

1. 使用 Vivado 打开`PipelineCPU`工程。
2. 将测试程序（如`riscv32_sim1.dat`）放入仿真目录（如`PipelineCPU.sim/sim_1/behav/xsim/`）。
3. 运行"Run Behavioral Simulation"。
4. 通过波形窗口或$display 语句观察各流水线寄存器、寄存器堆、ALU 等信号。
5. 可用`programs/`目录下的 dat 文件或自行编写 RISC-V 汇编测试。

## 贡献方式

- 欢迎提交 Pull Request、Issue，或补充更多指令/冒险处理/前递等功能。
- 建议遵循模块化、注释清晰的 Verilog 编码风格。

## License

MIT
