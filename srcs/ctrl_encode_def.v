// ============================================================================
// 文件名称：ctrl_encode_def.v
// 文件功能：RISC-V流水线CPU控制信号与常量定义，包含操作码、功能码、控制信号等宏定义
// ============================================================================

// NPC控制信号
`define NPC_PLUS4   3'b000 // PC+4
`define NPC_BRANCH  3'b001 // 分支跳转
`define NPC_JUMP    3'b010 // JAL跳转
`define NPC_JALR    3'b100 // JALR跳转

// ALU控制信号
`define ALU_NOP     5'b00000 // 空操作
`define ALU_ADD     5'b00001 // 加法
`define ALU_SUB     5'b00010 // 减法
`define ALU_AND     5'b00011 // 与
`define ALU_OR      5'b00100 // 或
`define ALU_XOR     5'b00101 // 异或
`define ALU_SLL     5'b00110 // 左移
`define ALU_SRL     5'b00111 // 逻辑右移
`define ALU_SRA     5'b01000 // 算术右移
`define ALU_SLT     5'b01001 // 有符号小于
`define ALU_SLTU    5'b01010 // 无符号小于
`define ALU_LUI     5'b01011 // LUI
`define ALU_AUIPC   5'b01100 // AUIPC
`define ALU_BEQ     5'b01101 // BEQ
`define ALU_BNE     5'b01110 // BNE
`define ALU_BLT     5'b01111 // BLT
`define ALU_BGE     5'b10000 // BGE
`define ALU_BLTU    5'b10001 // BLTU
`define ALU_BGEU    5'b10010 // BGEU

// EXT控制信号
`define EXT_CTRL_ITYPE_SHAMT 6'b100000 // I型移位立即数扩展
`define EXT_CTRL_ITYPE	6'b010000 // I型立即数扩展
`define EXT_CTRL_STYPE	6'b001000 // S型立即数扩展
`define EXT_CTRL_BTYPE	6'b000100 // B型立即数扩展
`define EXT_CTRL_UTYPE	6'b000010 // U型立即数扩展
`define EXT_CTRL_JTYPE	6'b000001 // J型立即数扩展

// 通用寄存器选择
`define GPRSel_RD 2'b00 // 目标寄存器
`define GPRSel_RT 2'b01 // 源寄存器
`define GPRSel_31 2'b10 // 常数31，x31，RISC-V中未用

// 写数据选择
`define WDSel_FromALU 2'b00 // 来自ALU
`define WDSel_FromMEM 2'b01 // 来自内存
`define WDSel_FromPC 2'b10  // 来自PC

// 内存访问类型
`define DM_WORD 3'b000 // 字访问
`define DM_HALFWORD 3'b001 // 半字访问
`define DM_HALFWORD_UNSIGNED 3'b010 // 半字无符号访问
`define DM_BYTE 3'b011 // 字节访问
`define DM_BYTE_UNSIGNED 3'b100 // 字节无符号访问

// RISC-V RV32I操作码
`define OPCODE_LUI     7'b0110111 // LUI
`define OPCODE_AUIPC   7'b0010111 // AUIPC
`define OPCODE_JAL     7'b1101111 // JAL
`define OPCODE_JALR    7'b1100111 // JALR
`define OPCODE_BRANCH  7'b1100011 // 分支
`define OPCODE_LOAD    7'b0000011 // 载入
`define OPCODE_STORE   7'b0100011 // 存储
`define OPCODE_OP_IMM  7'b0010011 // 立即数运算
`define OPCODE_OP      7'b0110011 // 寄存器运算

// RISC-V RV32I Funct3编码
`define FUNCT3_BEQ     3'b000 // BEQ
`define FUNCT3_BNE     3'b001 // BNE
`define FUNCT3_BLT     3'b100 // BLT
`define FUNCT3_BGE     3'b101 // BGE
`define FUNCT3_BLTU    3'b110 // BLTU
`define FUNCT3_BGEU    3'b111 // BGEU
`define FUNCT3_LB      3'b000 // LB
`define FUNCT3_LH      3'b001 // LH
`define FUNCT3_LW      3'b010 // LW
`define FUNCT3_LBU     3'b100 // LBU
`define FUNCT3_LHU     3'b101 // LHU
`define FUNCT3_SB      3'b000 // SB
`define FUNCT3_SH      3'b001 // SH
`define FUNCT3_SW      3'b010 // SW
`define FUNCT3_ADDI    3'b000 // ADDI
`define FUNCT3_SLTI    3'b010 // SLTI
`define FUNCT3_SLTIU   3'b011 // SLTIU
`define FUNCT3_XORI    3'b100 // XORI
`define FUNCT3_ORI     3'b110 // ORI
`define FUNCT3_ANDI    3'b111 // ANDI
`define FUNCT3_SLLI    3'b001 // SLLI
`define FUNCT3_SRLI    3'b101 // SRLI
`define FUNCT3_SRAI    3'b101 // SRAI
`define FUNCT3_ADD     3'b000 // ADD
`define FUNCT3_SUB     3'b000 // SUB
`define FUNCT3_SLL     3'b001 // SLL
`define FUNCT3_SLT     3'b010 // SLT
`define FUNCT3_SLTU    3'b011 // SLTU
`define FUNCT3_XOR     3'b100 // XOR
`define FUNCT3_SRL     3'b101 // SRL
`define FUNCT3_SRA     3'b101 // SRA
`define FUNCT3_OR      3'b110 // OR
`define FUNCT3_AND     3'b111 // AND

// RISC-V RV32I Funct7编码
`define FUNCT7_ADD     7'b0000000 // ADD
`define FUNCT7_SUB     7'b0100000 // SUB
`define FUNCT7_SRL     7'b0000000 // SRL
`define FUNCT7_SRA     7'b0100000 // SRA

