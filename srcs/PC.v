// ============================================================================
// 模块名称：PC_NPC
// 模块功能：程序计数器PC模块，负责PC的更新和分支跳转
// ============================================================================
`include "ctrl_encode_def.v"

module PC_NPC (
    input         clk,         // 时钟信号
    input         rst,         // 复位信号
    input         stall,       // 暂停信号
    input  [31:0] base_PC,     // 基准PC
    input  [2:0]  NPCOp,       // 下一PC操作类型
    input  [31:0] IMM,         // 立即数
    input  [31:0] aluout,      // ALU输出
    output reg [31:0] PC       // 当前PC
);
    // =====================
    // 下一个PC计算
    // =====================
    wire [31:0] PCPLUS4 = PC + 4;
    reg  [31:0] next_PC;
    always @(*) begin
        case (NPCOp)
            `NPC_PLUS4:  next_PC = PCPLUS4;
            `NPC_BRANCH: next_PC = base_PC + IMM;
            `NPC_JUMP:   next_PC = base_PC + IMM;
            `NPC_JALR:   next_PC = aluout;
            default:     next_PC = PCPLUS4;
        endcase
    end
    // =====================
    // PC寄存器时序逻辑
    // =====================
    always @(posedge clk or posedge rst) begin
        if (rst)
            PC <= 32'h0000_0000;
        else if (!stall)
            PC <= next_PC;
        else
            PC <= PC;
    end
endmodule

