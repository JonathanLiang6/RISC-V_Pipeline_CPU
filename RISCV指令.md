### RISC-V基本指令集概述
RISC-V指令集采用简洁的设计理念，具有多种指令格式，不同格式的指令在字段组成和功能上各有特点，以下是对其基本指令集的详细介绍：

### RISC-V指令格式
RISC-V指令根据操作数和功能的不同，主要分为以下几种格式,各格式的字段组成如下：
- **R-type（寄存器型）**
    - 字段构成：funct7（7位）、rs2（5位）、rs1（5位）、funct3（3位）、rd（5位）、opcode（7位）。
    - 用途：通常用于算术逻辑运算等需要两个寄存器操作数和一个结果寄存器的指令。
- **I-type（立即数型）**
    - 字段构成：imm[11:0]（12位立即数）、rs1（5位）、funct3（3位）、rd（5位）、opcode（7位）。
    - 用途：用于加载操作、立即数运算等，操作数包含一个寄存器和一个12位立即数。
- **S-type（存储型）**
    - 字段构成：imm[11:5]（7位立即数高位）、rs2（5位）、rs1（5位）、funct3（3位）、imm[4:0]（5位立即数低位）、opcode（7位）。
    - 用途：主要用于存储操作，如字节存储、半字存储、字存储等，立即数用于计算存储地址。
- **B-type（分支型）**
    - 字段构成：imm[12]（1位立即数）、imm[10:5]（6位立即数）、rs2（5位）、rs1（5位）、funct3（3位）、imm[4:1]（4位立即数）、imm[11]（1位立即数）、opcode（7位）。
    - 用途：用于条件分支指令，如相等分支、不等分支、小于分支等，立即数用于计算分支目标地址。
- **U-type（上层立即数型）**
    - 字段构成：imm[31:12]（20位立即数）、rd（5位）、opcode（7位）。
    - 用途：用于生成高层地址，如加载高位立即数指令（LUI），将20位立即数左移12位后存入目标寄存器。
- **J-type（跳转型）**
    - 字段构成：imm[20]（1位立即数）、imm[10:1]（10位立即数）、imm[11]（1位立即数）、imm[19:12]（8位立即数）、rd（5位）、opcode（7位）。
    - 用途：用于无条件跳转指令（JAL），立即数用于计算跳转目标地址。

### RV32I基本指令集详情
|指令类型|指令助记符|操作数|功能描述|
| ---- | ---- | ---- | ---- |
|U-type|LUI|rd, imm[31:12]|将20位立即数左移12位后存入rd寄存器，用于生成高位地址|
|U-type|AUIPC|rd, imm[31:12]|将20位立即数左移12位后与pc值相加，结果存入rd寄存器|
|J-type|JAL|rd, imm|计算跳转目标地址（pc + 符号扩展后的21位立即数），将当前pc+4存入rd，然后跳转到目标地址|
|I-type|JALR|rd, rs1, imm|计算跳转目标地址（rs1 + 符号扩展后的12位立即数），将当前pc+4存入rd，然后跳转到目标地址|
|B-type|BEQ|rs1, rs2, imm|如果rs1等于rs2，跳转到pc + 符号扩展后的12位立即数指定的地址|
|B-type|BNE|rs1, rs2, imm|如果rs1不等于rs2，跳转到pc + 符号扩展后的12位立即数指定的地址|
|B-type|BLT|rs1, rs2, imm|如果rs1小于rs2（有符号比较），跳转到pc + 符号扩展后的12位立即数指定的地址|
|B-type|BGE|rs1, rs2, imm|如果rs1大于或等于rs2（有符号比较），跳转到pc + 符号扩展后的12位立即数指定的地址|
|B-type|BLTU|rs1, rs2, imm|如果rs1小于rs2（无符号比较），跳转到pc + 符号扩展后的12位立即数指定的地址|
|B-type|BGEU|rs1, rs2, imm|如果rs1大于或等于rs2（无符号比较），跳转到pc + 符号扩展后的12位立即数指定的地址|
|I-type|LB|rd, rs1, imm|从内存地址（rs1 + 符号扩展后的12位立即数）读取1字节，符号扩展后存入rd|
|I-type|LH|rd, rs1, imm|从内存地址（rs1 + 符号扩展后的12位立即数）读取半字（2字节），符号扩展后存入rd|
|I-type|LW|rd, rs1, imm|从内存地址（rs1 + 符号扩展后的12位立即数）读取字（4字节），存入rd|
|I-type|LBU|rd, rs1, imm|从内存地址（rs1 + 符号扩展后的12位立即数）读取1字节，零扩展后存入rd|
|I-type|LHU|rd, rs1, imm|从内存地址（rs1 + 符号扩展后的12位立即数）读取半字（2字节），零扩展后存入rd|
|S-type|SB|rs2, rs1, imm|将rs2的低8位存储到内存地址（rs1 + 符号扩展后的12位立即数）|
|S-type|SH|rs2, rs1, imm|将rs2的低16位存储到内存地址（rs1 + 符号扩展后的12位立即数）|
|S-type|SW|rs2, rs1, imm|将rs2的低32位存储到内存地址（rs1 + 符号扩展后的12位立即数）|
|I-type|ADDI|rd, rs1, imm|将rs1的值与符号扩展后的12位立即数相加，结果存入rd|
|I-type|SLTI|rd, rs1, imm|将rs1的值与符号扩展后的12位立即数进行有符号比较，若rs1小于立即数，rd置1，否则置0|
|I-type|SLTIU|rd, rs1, imm|将rs1的值与符号扩展后的12位立即数进行无符号比较，若rs1小于立即数，rd置1，否则置0|
|I-type|XORI|rd, rs1, imm|将rs1的值与符号扩展后的12位立即数进行异或运算，结果存入rd|
|I-type|ANDI|rd, rs1, imm|将rs1的值与符号扩展后的12位立即数进行与运算，结果存入rd|
|I-type|SLLI|rd, rs1, shamt|将rs1的值左移shamt位（shamt为5位立即数），低位补0，结果存入rd|
|I-type|SRLI|rd, rs1, shamt|将rs1的值逻辑右移shamt位（shamt为5位立即数），高位补0，结果存入rd|
|I-type|SRAI|rd, rs1, shamt|将rs1的值算术右移shamt位（shamt为5位立即数），高位补符号位，结果存入rd|
|I-type|SRAI| rd, rs1, shamt| 将rs1的值算术右移shamt位（shamt为5位立即数），高位补符号位，结果存入rd|
|R-type|ADD|rd, rs1, rs2|将rs1和rs2的值相加，结果存入rd|
|R-type|SUB|rd, rs1, rs2|将rs1的值减去rs2的值，结果存入rd|
|R-type|SLL|rd, rs1, rs2|将rs1的值左移rs2的低5位所指定的位数，低位补0，结果存入rd|
|R-type|SLT|rd, rs1, rs2|对rs1和rs2的值进行有符号比较，若rs1小于rs2，rd置1，否则置0|
|R-type|SLTU|rd, rs1, rs2|对rs1和rs2的值进行无符号比较，若rs1小于rs2，rd置1，否则置0|
|R-type|XOR|rd, rs1, rs2|对rs1和rs2的值进行异或运算，结果存入rd|
|R-type|SRL|rd, rs1, rs2|将rs1的值逻辑右移rs2的低5位所指定的位数，高位补0，结果存入rd|
|R-type|SRA|rd, rs1, rs2|将rs1的值算术右移rs2的低5位所指定的位数，高位补符号位，结果存入rd|
|R-type|OR|rd, rs1, rs2|对rs1和rs2的值进行或运算，结果存入rd|
|R-type|AND|rd, rs1, rs2|对rs1和rs2的值进行与运算，结果存入rd|