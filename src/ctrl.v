// RISC-V 流水线CPU控制单元 - 支持完整的RV32I指令集
// 负责指令解码和控制信号生成

module ctrl(Op, Funct7, Funct3, Zero, 
            RegWrite, MemWrite,
            EXTOp, ALUOp, NPCOp, 
            ALUSrc, GPRSel, WDSel, DMType);
            
   input  [6:0] Op;       // 操作码
   input  [6:0] Funct7;   // funct7字段
   input  [2:0] Funct3;   // funct3字段
   input        Zero;     // ALU零标志位
   
   output       RegWrite; // 寄存器写使能
   output       MemWrite; // 内存写使能
   output [5:0] EXTOp;    // 立即数扩展控制
   output [4:0] ALUOp;    // ALU操作码
   output [2:0] NPCOp;    // 下一条PC操作
   output       ALUSrc;   // ALU源操作数选择
   output [2:0] DMType;   // 内存访问类型
   output [1:0] GPRSel;   // 寄存器选择
   output [1:0] WDSel;    // 写数据选择
   
   // ==================== 指令类型识别 ====================
   
   // R型指令 (寄存器-寄存器操作)
   wire rtype = ~Op[6]&Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; // 0110011
   
   // I型指令 (立即数操作)
   wire itype_l = ~Op[6]&~Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; // 0000011 (加载)
   wire itype_r = ~Op[6]&~Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];  // 0010011 (立即数运算)
   wire itype_jalr = Op[6]&Op[5]&~Op[4]&~Op[3]&Op[2]&Op[1]&Op[0]; // 1100111 (JALR)
   
   // S型指令 (存储操作)
   wire stype = ~Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; // 0100011
   
   // B型指令 (分支操作)
   wire btype = Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; // 1100011
   
   // U型指令 (高位立即数)
   wire utype_lui = ~Op[6]&Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];   // 0110111 (LUI)
   wire utype_auipc = ~Op[6]&Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&~Op[0]; // 0010111 (AUIPC)
   
   // J型指令 (跳转)
   wire jtype = Op[6]&Op[5]&~Op[4]&Op[3]&Op[2]&Op[1]&Op[0]; // 1101111 (JAL)
   
   // ==================== 具体指令识别 ====================
   
   // R型指令解码
   wire i_add  = rtype & ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // ADD 0000000 000
   wire i_sub  = rtype & ~Funct7[6]&Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // SUB 0100000 000
   wire i_sll  = rtype & ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&Funct3[0]; // SLL 0000000 001
   wire i_slt  = rtype & ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&Funct3[1]&~Funct3[0]; // SLT 0000000 010
   wire i_sltu = rtype & ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&Funct3[1]&Funct3[0]; // SLTU 0000000 011
   wire i_xor  = rtype & ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&Funct3[2]&~Funct3[1]&~Funct3[0]; // XOR 0000000 100
   wire i_srl  = rtype & ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&Funct3[2]&~Funct3[1]&Funct3[0]; // SRL 0000000 101
   wire i_sra  = rtype & ~Funct7[6]&Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&Funct3[2]&~Funct3[1]&Funct3[0]; // SRA 0100000 101
   wire i_or   = rtype & ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&Funct3[2]&Funct3[1]&~Funct3[0]; // OR 0000000 110
   wire i_and  = rtype & ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&Funct3[2]&Funct3[1]&Funct3[0]; // AND 0000000 111
   
   // I型指令解码 (立即数运算)
   wire i_addi  = itype_r & ~Funct3[2]&~Funct3[1]&~Funct3[0]; // ADDI 000
   wire i_slti  = itype_r & ~Funct3[2]&Funct3[1]&~Funct3[0]; // SLTI 010
   wire i_sltiu = itype_r & ~Funct3[2]&Funct3[1]&Funct3[0]; // SLTIU 011
   wire i_xori  = itype_r & Funct3[2]&~Funct3[1]&~Funct3[0]; // XORI 100
   wire i_ori   = itype_r & Funct3[2]&Funct3[1]&~Funct3[0]; // ORI 110
   wire i_andi  = itype_r & Funct3[2]&Funct3[1]&Funct3[0]; // ANDI 111
   wire i_slli  = itype_r & ~Funct3[2]&~Funct3[1]&Funct3[0] & ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]; // SLLI 001 0000000
   wire i_srli  = itype_r & Funct3[2]&~Funct3[1]&Funct3[0] & ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]; // SRLI 101 0000000
   wire i_srai  = itype_r & Funct3[2]&~Funct3[1]&Funct3[0] & ~Funct7[6]&Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]; // SRAI 101 0100000
   
   // I型指令解码 (加载操作)
   wire i_lb  = itype_l & ~Funct3[2]&~Funct3[1]&~Funct3[0]; // LB 000
   wire i_lh  = itype_l & ~Funct3[2]&~Funct3[1]&Funct3[0]; // LH 001
   wire i_lw  = itype_l & ~Funct3[2]&Funct3[1]&~Funct3[0]; // LW 010
   wire i_lbu = itype_l & ~Funct3[2]&Funct3[1]&Funct3[0]; // LBU 100
   wire i_lhu = itype_l & Funct3[2]&~Funct3[1]&~Funct3[0]; // LHU 101
   
   // S型指令解码 (存储操作)
   wire i_sb = stype & ~Funct3[2]&~Funct3[1]&~Funct3[0]; // SB 000
   wire i_sh = stype & ~Funct3[2]&~Funct3[1]&Funct3[0]; // SH 001
   wire i_sw = stype & ~Funct3[2]&Funct3[1]&~Funct3[0]; // SW 010
   
   // B型指令解码 (分支操作)
   wire i_beq  = btype & ~Funct3[2]&~Funct3[1]&~Funct3[0]; // BEQ 000
   wire i_bne  = btype & ~Funct3[2]&~Funct3[1]&Funct3[0]; // BNE 001
   wire i_blt  = btype & ~Funct3[2]&Funct3[1]&~Funct3[0]; // BLT 100
   wire i_bge  = btype & ~Funct3[2]&Funct3[1]&Funct3[0]; // BGE 101
   wire i_bltu = btype & Funct3[2]&~Funct3[1]&~Funct3[0]; // BLTU 110
   wire i_bgeu = btype & Funct3[2]&~Funct3[1]&Funct3[0]; // BGEU 111
   
   // U型和J型指令解码
   wire i_lui = utype_lui;    // LUI指令
   wire i_auipc = utype_auipc; // AUIPC指令
   wire i_jal = jtype;        // JAL指令
   wire i_jalr = itype_jalr;  // JALR指令
   
   // ==================== 控制信号生成 ====================
   
   // 寄存器写使能 - 所有需要写寄存器的指令
   assign RegWrite = rtype | itype_r | itype_l | utype_lui | utype_auipc | jtype | itype_jalr;
   
   // 内存写使能 - 所有存储指令
   assign MemWrite = stype;
   
   // ALU源操作数选择 - 需要立即数的指令
   assign ALUSrc = itype_r | itype_l | stype | utype_lui | utype_auipc | jtype | itype_jalr;
   
   // 立即数扩展控制
   assign EXTOp[5] = i_slli | i_srli | i_srai;                    // 移位指令使用shamt
   assign EXTOp[4] = itype_r | itype_l | itype_jalr;              // I型指令
   assign EXTOp[3] = stype;                                       // S型指令
   assign EXTOp[2] = btype;                                       // B型指令
   assign EXTOp[1] = utype_lui | utype_auipc;                     // U型指令
   assign EXTOp[0] = jtype;                                       // J型指令
   
   // 写数据选择
   assign WDSel[0] = itype_l;                                     // 加载指令从内存读取
   assign WDSel[1] = jtype | itype_jalr;                          // 跳转指令写PC+4
   
   // 下一条PC操作
   assign NPCOp[0] = (btype & Zero & (i_beq | i_bge | i_bgeu)) | (btype & ~Zero & (i_bne | i_blt | i_bltu)); // 分支条件
   assign NPCOp[1] = jtype;                                       // JAL跳转
   assign NPCOp[2] = itype_jalr;                                  // JALR跳转
   
   // ALU操作码生成
   assign ALUOp[0] = i_add | i_addi | i_lui | i_auipc | i_lb | i_lh | i_lw | i_lbu | i_lhu | i_sb | i_sh | i_sw | i_jal | i_jalr;
   assign ALUOp[1] = i_sub | i_slt | i_slti | i_blt | i_bge;
   assign ALUOp[2] = i_sltu | i_sltiu | i_bltu | i_bgeu;
   assign ALUOp[3] = i_xor | i_xori | i_beq | i_bne;
   assign ALUOp[4] = i_or | i_ori | i_and | i_andi | i_sll | i_slli | i_srl | i_srli | i_sra | i_srai;
   
   // 内存访问类型（目前只支持字访问，可扩展）
   assign DMType = `dm_word;
   
   // 寄存器选择（目前固定使用rd）
   assign GPRSel = `GPRSel_RD;

endmodule
