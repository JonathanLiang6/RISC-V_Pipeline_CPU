// ============================================================================
// 模块名称：ctrl
// 模块功能：控制单元，根据指令操作码和功能码生成各类控制信号，驱动流水线各模块
// ============================================================================
`include "ctrl_encode_def.v"

module ctrl (
    input  [6:0] Op,        // 操作码
    input  [6:0] Funct7,    // 功能码funct7
    input  [2:0] Funct3,    // 功能码funct3
    output       RegWrite,  // 寄存器写使能
    output       MemWrite,  // 内存写使能
    output       MemRead,   // 内存读使能
    output [5:0] EXTOp,     // 立即数扩展控制
    output [4:0] ALUOp,     // ALU操作类型
    output       ALUSrc,    // ALU操作数来源选择
    output [2:0] DMType,    // 数据存储类型
    output [1:0] WDSel      // 写回数据选择
);
    // =====================
    // 指令类型检测
    // =====================
    wire lui     = (Op == `OPCODE_LUI);
    wire auipc   = (Op == `OPCODE_AUIPC);
    wire jal     = (Op == `OPCODE_JAL);
    wire jalr    = (Op == `OPCODE_JALR);
    wire branch  = (Op == `OPCODE_BRANCH);
    wire load    = (Op == `OPCODE_LOAD);
    wire store   = (Op == `OPCODE_STORE);
    wire op_imm  = (Op == `OPCODE_OP_IMM);
    wire op      = (Op == `OPCODE_OP);

    // 分支指令
    wire beq     = branch & (Funct3 == `FUNCT3_BEQ);
    wire bne     = branch & (Funct3 == `FUNCT3_BNE);
    wire blt     = branch & (Funct3 == `FUNCT3_BLT);
    wire bge     = branch & (Funct3 == `FUNCT3_BGE);
    wire bltu    = branch & (Funct3 == `FUNCT3_BLTU);
    wire bgeu    = branch & (Funct3 == `FUNCT3_BGEU);

    // 载入指令
    wire lb      = load & (Funct3 == `FUNCT3_LB);
    wire lh      = load & (Funct3 == `FUNCT3_LH);
    wire lw      = load & (Funct3 == `FUNCT3_LW);
    wire lbu     = load & (Funct3 == `FUNCT3_LBU);
    wire lhu     = load & (Funct3 == `FUNCT3_LHU);

    // 存储指令
    wire sb      = store & (Funct3 == `FUNCT3_SB);
    wire sh      = store & (Funct3 == `FUNCT3_SH);
    wire sw      = store & (Funct3 == `FUNCT3_SW);

    // 立即数算术/逻辑指令
    wire addi    = op_imm & (Funct3 == `FUNCT3_ADDI);
    wire slti    = op_imm & (Funct3 == `FUNCT3_SLTI);
    wire sltiu   = op_imm & (Funct3 == `FUNCT3_SLTIU);
    wire xori    = op_imm & (Funct3 == `FUNCT3_XORI);
    wire ori     = op_imm & (Funct3 == `FUNCT3_ORI);
    wire andi    = op_imm & (Funct3 == `FUNCT3_ANDI);
    wire slli    = op_imm & (Funct3 == `FUNCT3_SLLI);
    wire srli    = op_imm & (Funct3 == `FUNCT3_SRLI) & (Funct7 == `FUNCT7_SRL);
    wire srai    = op_imm & (Funct3 == `FUNCT3_SRAI) & (Funct7 == `FUNCT7_SRA);

    // 寄存器算术/逻辑指令
    wire add     = op & (Funct3 == `FUNCT3_ADD) & (Funct7 == `FUNCT7_ADD);
    wire sub     = op & (Funct3 == `FUNCT3_SUB) & (Funct7 == `FUNCT7_SUB);
    wire sll     = op & (Funct3 == `FUNCT3_SLL);
    wire slt     = op & (Funct3 == `FUNCT3_SLT);
    wire sltu    = op & (Funct3 == `FUNCT3_SLTU);
    wire xor_op  = op & (Funct3 == `FUNCT3_XOR);
    wire srl     = op & (Funct3 == `FUNCT3_SRL) & (Funct7 == `FUNCT7_SRL);
    wire sra     = op & (Funct3 == `FUNCT3_SRA) & (Funct7 == `FUNCT7_SRA);
    wire or_op   = op & (Funct3 == `FUNCT3_OR);
    wire and_op  = op & (Funct3 == `FUNCT3_AND);

    // =====================
    // 控制信号生成
    // =====================
    assign RegWrite = lui | auipc | jal | jalr | load | addi | slti | sltiu | xori | ori | andi | slli | srli | srai | add | sub | sll | slt | sltu | xor_op | srl | sra | or_op | and_op;
    assign MemWrite = store;
    assign MemRead = load;
    assign ALUSrc = auipc | jal | jalr | load | store | addi | slti | sltiu | xori | ori | andi | slli | srli | srai;

    // 立即数扩展控制
    assign EXTOp[5] = slli | srli | srai;  // I型移位立即数扩展
    assign EXTOp[4] = addi | slti | sltiu | xori | ori | andi | jalr;  // I型立即数扩展
    assign EXTOp[3] = store;  // S型立即数扩展
    assign EXTOp[2] = branch;  // B型立即数扩展
    assign EXTOp[1] = lui | auipc;  // U型立即数扩展
    assign EXTOp[0] = jal;  // J型立即数扩展

    // 写回数据选择
    assign WDSel[1] = jal | jalr;
    assign WDSel[0] = load;

    // ALU操作类型编码
    assign ALUOp = (beq) ? `ALU_BEQ :
                   (bne) ? `ALU_BNE :
                   (blt) ? `ALU_BLT :
                   (bge) ? `ALU_BGE :
                   (bltu) ? `ALU_BLTU :
                   (bgeu) ? `ALU_BGEU :
                   (lui) ? `ALU_LUI :
                   (auipc) ? `ALU_AUIPC :
                   (addi | add | load | store | jalr) ? `ALU_ADD :
                   (sub) ? `ALU_SUB :
                   (slti | slt) ? `ALU_SLT :
                   (sltiu | sltu) ? `ALU_SLTU :
                   (xori | xor_op) ? `ALU_XOR :
                   (ori | or_op) ? `ALU_OR :
                   (andi | and_op) ? `ALU_AND :
                   (slli | sll) ? `ALU_SLL :
                   (srli | srl) ? `ALU_SRL :
                   (srai | sra) ? `ALU_SRA : `ALU_NOP;

    // 数据存储类型
    assign DMType[2] = lbu | lhu;
    assign DMType[1] = lh | lhu | sh;
    assign DMType[0] = lb | lbu | sb;
endmodule