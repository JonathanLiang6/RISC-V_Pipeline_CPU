# RISC-V 五级流水线 CPU 项目

## 项目简介

本项目实现了基于 RISC-V RV32I 指令集的五级流水线 CPU，支持取指（IF）、译码（ID）、执行（EX）、访存（MEM）、写回（WB）五级流水线，具备数据冒险检测与前递、分支预测、寄存器堆、数据存储器、立即数扩展等功能模块。项目可在 Vivado 环境下综合、仿真，并适配 Nexys4DDR 开发板进行 FPGA 上板验证。

---

## 目录结构

```
├── srcs/                # Verilog源代码目录
│   ├── alu.v            # 算术逻辑单元
│   ├── ctrl.v           # 控制单元
│   ├── ctrl_encode_def.v# 控制信号与常量定义
│   ├── dm.v             # 数据存储器
│   ├── EXT.v            # 立即数扩展
│   ├── hazard_units.v   # 冒险检测与前递单元
│   ├── PC.v             # 程序计数器
│   ├── pipeline_regs.v  # 各级流水线寄存器
│   ├── PipelineCPU.v    # 五级流水线CPU顶层
│   ├── RF.v             # 通用寄存器堆
│   ├── sccomp.v         # SoC顶层集成模块
│   └── top_module.v     # FPGA顶层模块（适配Nexys4DDR）
│
├── test/                # 测试与仿真文件
│   ├── sccomp_rom_testbench.v   # SoC顶层仿真平台
│   ├── riscv-studentnosorting.coe # 指令/数据初始化文件（COE格式）
│   └── disasm_output.txt        # 指令反汇编及注释说明
│
├── PipelineCPU/         # Vivado工程目录（含IP核、工程文件等）
│
├── Nexys4DDR_CPU.xdc    # Nexys4DDR开发板引脚约束文件
├── RISCV指令.md         # RISC-V指令集支持说明与格式文档
└── README.md            # 项目说明文档（本文件）
```

---

## 各模块功能简介

- **alu.v**：算术逻辑单元，支持 RV32I 全部算术、逻辑、比较、移位等操作。
- **ctrl.v / ctrl_encode_def.v**：控制单元及信号定义，译码指令并生成各类控制信号。
- **dm.v**：数据存储器，支持字、半字、字节的读写，支持有符号/无符号扩展。
- **EXT.v**：立即数扩展模块，支持 I/S/B/U/J 型等多种格式的符号扩展。
- **hazard_units.v**：流水线冒险检测与前递，支持 Load-Use 冒险、分支冒险、数据前递。
- **PC.v**：程序计数器，支持顺序、分支、跳转、JALR 等多种 PC 更新方式。
- **pipeline_regs.v**：IF/ID、ID/EX、EX/MEM、MEM/WB 各级流水线寄存器。
- **PipelineCPU.v**：五级流水线 CPU 顶层，连接各功能模块，完成数据与控制流。
- **RF.v**：32×32 位通用寄存器堆，支持双端口读、单端口写及调试端口。
- **sccomp.v**：SoC 顶层集成，连接 CPU、数据存储器、ROM，便于仿真与上板。
- **top_module.v**：FPGA 顶层，适配 Nexys4DDR 开发板，集成数码管、开关、按键等外设。

---

## 测试与仿真

### 1. 指令/数据初始化文件

- `test/riscv-studentnosorting.coe`  
  COE 格式，16 进制指令或数据初始化，用于 Vivado 仿真或 Block Memory Generator 初始化。

- `test/disasm_output.txt`  
  指令反汇编及中文注释，便于理解测试程序的功能与冒险场景。

### 2. 仿真平台

- `test/sccomp_rom_testbench.v`  
  SoC 顶层仿真平台，自动生成时钟、复位，实例化`sccomp`模块，支持波形观察和功能验证。

### 3. 仿真方法

1. 在 Vivado 中新建工程，导入`srcs/`和`test/`目录下所有 Verilog 文件。
2. 将`test/riscv-studentnosorting.coe`作为 ROM 初始化文件。
3. 以`sccomp_rom_testbench.v`为顶层，运行仿真，观察 PC、寄存器、内存、数码管等信号波形。
4. 可根据`disasm_output.txt`对比仿真结果与预期。

---

## FPGA 上板说明

- **开发板**：Digilent Nexys4DDR
- **约束文件**：`Nexys4DDR_CPU.xdc`，已适配本项目所有 IO（时钟、复位、开关、数码管等）。
- **顶层文件**：`srcs/top_module.v`
- **IP 核**：Vivado 工程内含`dist_mem_gen_0`（ROM），需正确配置初始化文件。
- **上板步骤**：
  1. 在 Vivado 中综合、实现、生成比特流。
  2. 下载至 Nexys4DDR 开发板，使用开关、数码管等外设进行交互和调试。

---

## 指令支持与文档

- **指令支持**：详见`RISCV指令.md`，支持 RV32I 全部基础指令（算术、逻辑、分支、跳转、访存等）。
- **指令格式**：R/I/S/B/U/J 型，详见`RISCV指令.md`。
- **冒险与前递**：支持数据冒险检测、Load-Use 冒险暂停、分支冒险冲刷、数据前递。

---

## 主要特色

- 完整的五级流水线结构，支持数据/控制冒险处理。
- 代码风格统一，注释专业、简洁、准确，便于维护和二次开发。
- 支持仿真与 FPGA 上板，便于教学、实验和工程应用。
- 适配 Nexys4DDR 开发板，支持丰富的外设交互。

---

## 参考与致谢

- RISC-V 官方文档与开源实现
- Vivado 官方文档与 IP 核手册
- 本项目部分测试程序参考了 RISC-V 教学资料

---

如有问题或建议，欢迎在本项目基础上继续完善与交流！
