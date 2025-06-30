// RISC-V 流水线CPU控制信号定义文件
// 支持完整的RV32I基本指令集

// NPC控制信号 - 下一条指令地址选择
`define NPC_PLUS4   3'b000  // PC + 4，顺序执行
`define NPC_BRANCH  3'b001  // 分支跳转
`define NPC_JUMP    3'b010  // 无条件跳转
`define NPC_JALR    3'b100  // JALR跳转

// ALU控制信号 - 算术逻辑单元操作类型
`define ALU_NOP     3'b000  // 无操作
`define ALU_ADD     3'b001  // 加法
`define ALU_SUB     3'b010  // 减法
`define ALU_AND     3'b011  // 与运算
`define ALU_OR      3'b100  // 或运算
`define ALU_XOR     3'b101  // 异或运算
`define ALU_SLT     3'b110  // 有符号比较
`define ALU_SLTU    3'b111  // 无符号比较

// 立即数扩展控制信号 - 不同指令格式的立即数处理
`define EXT_CTRL_ITYPE_SHAMT 6'b100000  // I型指令移位操作
`define EXT_CTRL_ITYPE       6'b010000  // I型指令立即数
`define EXT_CTRL_STYPE       6'b001000  // S型指令存储
`define EXT_CTRL_BTYPE       6'b000100  // B型指令分支
`define EXT_CTRL_UTYPE       6'b000010  // U型指令高位立即数
`define EXT_CTRL_JTYPE       6'b000001  // J型指令跳转

// 寄存器选择控制信号
`define GPRSel_RD   2'b00    // 选择rd寄存器
`define GPRSel_RT   2'b01    // 选择rt寄存器
`define GPRSel_31   2'b10    // 选择x31寄存器（用于JAL）

// 写数据选择控制信号
`define WDSel_FromALU 2'b00  // 来自ALU结果
`define WDSel_FromMEM 2'b01  // 来自内存数据
`define WDSel_FromPC  2'b10  // 来自PC+4（用于JAL/JALR）

// ALU操作码定义 - 支持所有RV32I指令
`define ALUOp_nop   5'b00000  // 无操作
`define ALUOp_lui   5'b00001  // LUI - 加载高位立即数
`define ALUOp_auipc 5'b00010  // AUIPC - PC相对高位立即数
`define ALUOp_add   5'b00011  // ADD - 加法
`define ALUOp_sub   5'b00100  // SUB - 减法
`define ALUOp_beq   5'b00101  // BEQ - 相等分支
`define ALUOp_bne   5'b00110  // BNE - 不等分支
`define ALUOp_blt   5'b00111  // BLT - 小于分支（有符号）
`define ALUOp_bge   5'b01000  // BGE - 大于等于分支（有符号）
`define ALUOp_bltu  5'b01001  // BLTU - 小于分支（无符号）
`define ALUOp_bgeu  5'b01010  // BGEU - 大于等于分支（无符号）
`define ALUOp_slt   5'b01011  // SLT - 有符号比较
`define ALUOp_sltu  5'b01100  // SLTU - 无符号比较
`define ALUOp_xor   5'b01101  // XOR - 异或
`define ALUOp_or    5'b01110  // OR - 或
`define ALUOp_and   5'b01111  // AND - 与
`define ALUOp_sll   5'b10000  // SLL - 逻辑左移
`define ALUOp_srl   5'b10001  // SRL - 逻辑右移
`define ALUOp_sra   5'b10010  // SRA - 算术右移
`define ALUOp_addi  5'b10011  // ADDI - 立即数加法
`define ALUOp_slti  5'b10100  // SLTI - 立即数有符号比较
`define ALUOp_sltiu 5'b10101  // SLTIU - 立即数无符号比较
`define ALUOp_xori  5'b10110  // XORI - 立即数异或
`define ALUOp_ori   5'b10111  // ORI - 立即数或
`define ALUOp_andi  5'b11000  // ANDI - 立即数与
`define ALUOp_slli  5'b11001  // SLLI - 立即数逻辑左移
`define ALUOp_srli  5'b11010  // SRLI - 立即数逻辑右移
`define ALUOp_srai  5'b11011  // SRAI - 立即数算术右移

// 内存访问类型控制信号
`define dm_word             3'b000  // 字访问（32位）
`define dm_halfword         3'b001  // 半字访问（16位）
`define dm_halfword_unsigned 3'b010  // 无符号半字访问
`define dm_byte             3'b011  // 字节访问（8位）
`define dm_byte_unsigned    3'b100  // 无符号字节访问

