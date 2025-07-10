// ============================================================================
// 模块名称：alu
// 模块功能：算术逻辑单元，实现RISC-V指令集的算术与逻辑运算，输出结果及标志位
// ============================================================================
`include "ctrl_encode_def.v"

module alu (
    input  signed [31:0] A,      // 操作数A
    input  signed [31:0] B,      // 操作数B
    input         [4:0]  ALUOp,  // ALU操作类型
    input         [31:0] PC,     // 当前指令地址
    output reg signed [31:0] C,  // 运算结果
    output reg        Zero,      // 零标志
    output reg        Sign,      // 符号标志
    output reg        Overflow,  // 溢出标志
    output reg        Carry      // 进位标志
);
    reg [32:0] temp_result;      // 33位用于检测溢出和进位
    integer i;

    // =====================
    // 运算类型选择
    // =====================
    always @(*) begin
        case (ALUOp)
            `ALU_NOP:   C = A;
            `ALU_LUI:   C = B;
            `ALU_AUIPC: C = PC + B;
            `ALU_ADD:   C = A + B;
            `ALU_SUB:   C = A - B;
            `ALU_AND:   C = A & B;
            `ALU_OR:    C = A | B;
            `ALU_XOR:   C = A ^ B;
            `ALU_SLL:   C = A << B[4:0];
            `ALU_SRL:   C = A >> B[4:0];
            `ALU_SRA:   C = A >>> B[4:0];
            `ALU_SLT:   C = {31'b0, (A < B)};
            `ALU_SLTU:  C = {31'b0, ($unsigned(A) < $unsigned(B))};
            // 分支比较均用减法
            `ALU_BEQ:   C = A - B;
            `ALU_BNE:   C = A - B;
            `ALU_BLT:   C = A - B;
            `ALU_BGE:   C = A - B;
            `ALU_BLTU:  C = $unsigned(A) - $unsigned(B);
            `ALU_BGEU:  C = $unsigned(A) - $unsigned(B);
            default:    C = A;
        endcase

        // =====================
        // 标志位计算
        // =====================
        case (ALUOp)
            `ALU_ADD: begin
                temp_result = {1'b0, A} + {1'b0, B};
                Zero = (C == 32'b0);
                Sign = C[31];
                Overflow = (A[31] == B[31]) && (C[31] != A[31]);
                Carry = temp_result[32];
            end
            `ALU_SUB, `ALU_BEQ, `ALU_BNE, `ALU_BLT, `ALU_BGE: begin
                temp_result = {1'b0, A} - {1'b0, B};
                Zero = (C == 32'b0);
                Sign = C[31];
                Overflow = (A[31] != B[31]) && (C[31] == B[31]);
                Carry = temp_result[32];
            end
            `ALU_BLTU, `ALU_BGEU: begin
                temp_result = {1'b0, $unsigned(A)} - {1'b0, $unsigned(B)};
                Zero = (C == 32'b0);
                Sign = C[31];
                Overflow = 1'b0;  // 无符号运算无溢出
                Carry = temp_result[32];
            end
            default: begin
                Zero = (C == 32'b0);
                Sign = C[31];
                Overflow = 1'b0;
                Carry = 1'b0;
            end
        endcase
    end
endmodule
    
