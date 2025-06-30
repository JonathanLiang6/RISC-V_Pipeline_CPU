`include "ctrl_encode_def.v"

// 算术逻辑单元模块 - 支持所有RV32I指令的ALU操作
module alu(A, B, ALUOp, C, Zero, PC);
           
   input  signed [31:0] A, B;  // 操作数A和B
   input         [4:0]  ALUOp; // ALU操作码
   input [31:0] PC;            // 程序计数器值（用于AUIPC）
   output signed [31:0] C;     // ALU结果
   output Zero;                // 零标志位
   
   reg [31:0] C;
   integer    i;
       
   always @( * ) begin
      case ( ALUOp )
         // 基础算术运算
         `ALUOp_nop:   C = A;                                    // 无操作，直接传递A
         `ALUOp_lui:   C = B;                                    // LUI - 加载高位立即数
         `ALUOp_auipc: C = PC + B;                               // AUIPC - PC相对高位立即数
         `ALUOp_add:   C = A + B;                                // ADD - 加法
         `ALUOp_sub:   C = A - B;                                // SUB - 减法
         `ALUOp_addi:  C = A + B;                                // ADDI - 立即数加法
         
         // 比较运算
         `ALUOp_slt:   C = {31'b0, (A < B)};                     // SLT - 有符号比较
         `ALUOp_sltu:  C = {31'b0, (A[31] == 0 && B[31] == 1) ? 1'b0 : (A[31] == 1 && B[31] == 0) ? 1'b1 : (A < B)}; // SLTU - 无符号比较
         `ALUOp_slti:  C = {31'b0, (A < B)};                     // SLTI - 立即数有符号比较
         `ALUOp_sltiu: C = {31'b0, (A[31] == 0 && B[31] == 1) ? 1'b0 : (A[31] == 1 && B[31] == 0) ? 1'b1 : (A < B)}; // SLTIU - 立即数无符号比较
         
         // 逻辑运算
         `ALUOp_xor:   C = A ^ B;                                // XOR - 异或
         `ALUOp_or:    C = A | B;                                // OR - 或
         `ALUOp_and:   C = A & B;                                // AND - 与
         `ALUOp_xori:  C = A ^ B;                                // XORI - 立即数异或
         `ALUOp_ori:   C = A | B;                                // ORI - 立即数或
         `ALUOp_andi:  C = A & B;                                // ANDI - 立即数与
         
         // 移位运算
         `ALUOp_sll:   C = A << B[4:0];                          // SLL - 逻辑左移
         `ALUOp_srl:   C = A >> B[4:0];                          // SRL - 逻辑右移
         `ALUOp_sra:   C = A >>> B[4:0];                         // SRA - 算术右移
         `ALUOp_slli:  C = A << B[4:0];                          // SLLI - 立即数逻辑左移
         `ALUOp_srli:  C = A >> B[4:0];                          // SRLI - 立即数逻辑右移
         `ALUOp_srai:  C = A >>> B[4:0];                         // SRAI - 立即数算术右移
         
         // 分支比较运算（用于分支指令）
         `ALUOp_beq:   C = {31'b0, (A == B)};                    // BEQ - 相等比较
         `ALUOp_bne:   C = {31'b0, (A != B)};                    // BNE - 不等比较
         `ALUOp_blt:   C = {31'b0, (A < B)};                     // BLT - 有符号小于比较
         `ALUOp_bge:   C = {31'b0, (A >= B)};                    // BGE - 有符号大于等于比较
         `ALUOp_bltu:  C = {31'b0, (A[31] == 0 && B[31] == 1) ? 1'b0 : (A[31] == 1 && B[31] == 0) ? 1'b1 : (A < B)}; // BLTU - 无符号小于比较
         `ALUOp_bgeu:  C = {31'b0, (A[31] == 0 && B[31] == 1) ? 1'b1 : (A[31] == 1 && B[31] == 0) ? 1'b0 : (A >= B)}; // BGEU - 无符号大于等于比较
         
         default:      C = A;                                    // 默认情况，传递A
      endcase
   end // end always
   
   // 零标志位 - 当结果为0时置1
   assign Zero = (C == 32'b0);

endmodule
    
