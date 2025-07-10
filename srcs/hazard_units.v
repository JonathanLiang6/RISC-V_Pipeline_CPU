// ============================================================================
// 模块名称：hazard_units
// 模块功能：冒险检测与前递单元，检测流水线中的数据冒险和控制冒险，生成暂停、冲刷、前递等控制信号
// ============================================================================
`include "ctrl_encode_def.v"

// --------------------
// 冒险检测单元
// --------------------
module HazardDetectionUnit(
    input  [4:0]  rs1_ID, rs2_ID,    // ID阶段源寄存器地址
    input  [4:0]  rd_EX, rd_MEM,     // EX/MEM阶段目标寄存器地址
    input         MemRead_EX,        // EX阶段是否为Load指令
    input         RegWrite_EX, RegWrite_MEM, // EX/MEM阶段是否写寄存器
    input  [6:0]  opcode_EX,         // EX阶段操作码
    input  [2:0]  funct3_EX,         // EX阶段funct3
    input         branch_taken_EX,   // EX阶段分支是否采纳
    input  [6:0]  opcode_ID,         // ID阶段操作码
    input  [31:0] imm_EX,            // EX阶段立即数
    input  [31:0] imm_ID,            // ID阶段立即数
    input  [31:0] alu_result_EX,     // EX阶段ALU输出（JALR用）
    input  [31:0] PC_EX,             // EX阶段PC
    input  [31:0] PC_ID,             // ID阶段PC
    output reg    stall_IF,          // IF阶段暂停信号
    output reg    flush_ID,          // ID阶段冲刷信号
    output reg    flush_EX,          // EX阶段冲刷信号
    output reg [2:0]  NPCOp_out,     // 下一PC操作类型
    output reg [31:0] NPCImm_out,    // 下一PC立即数
    output reg [31:0] base_PC_out    // 下一PC基址
);
    // =====================
    // Load-Use冒险检测
    // =====================
    always @(*) begin
        if (MemRead_EX &&
            ((rd_EX == rs1_ID && rs1_ID != 5'b0) ||
             (rd_EX == rs2_ID && rs2_ID != 5'b0))) begin
            stall_IF = 1'b1;
            flush_ID = 1'b0;
            flush_EX = 1'b1;
        end else if (opcode_EX == `OPCODE_JALR) begin
            stall_IF = 1'b0;
            flush_ID = 1'b1;
            flush_EX = 1'b0;
        end else if ((opcode_EX == `OPCODE_BRANCH) && branch_taken_EX) begin
            stall_IF = 1'b0;
            flush_ID = 1'b1;
            flush_EX = 1'b1;
        end else if (opcode_ID == `OPCODE_JAL) begin
            stall_IF = 1'b0;
            flush_ID = 1'b1;
            flush_EX = 1'b0;
        end else begin
            stall_IF = 1'b0;
            flush_ID = 1'b0;
            flush_EX = 1'b0;
        end
        // =====================
        // 下一PC控制信号优先级
        // =====================
        if (opcode_EX == `OPCODE_JALR) begin
            NPCOp_out = `NPC_JALR;
            NPCImm_out = 32'b0;
            base_PC_out = PC_EX;
        end else if ((opcode_EX == `OPCODE_BRANCH) && branch_taken_EX) begin
            NPCOp_out = `NPC_BRANCH;
            NPCImm_out = imm_EX;
            base_PC_out = PC_EX;
        end else if (opcode_ID == `OPCODE_JAL) begin
            NPCOp_out = `NPC_JUMP;
            NPCImm_out = imm_ID;
            base_PC_out = PC_ID;
        end else begin
            NPCOp_out = `NPC_PLUS4;
            NPCImm_out = 32'b0;
            base_PC_out = PC_EX;
        end
    end
endmodule

// --------------------
// 前递单元
// --------------------
module ForwardingUnit(
    input  [4:0]  rs1_EX, rs2_EX,    // EX阶段源寄存器地址
    input  [4:0]  rs1_ID, rs2_ID,    // ID阶段源寄存器地址
    input  [4:0]  rd_MEM, rd_WB,     // MEM/WB阶段目标寄存器地址
    input         RegWrite_MEM, RegWrite_WB, // MEM/WB阶段是否写寄存器
    output reg [1:0] forward_rs1_EX, // EX阶段rs1前递控制
    output reg [1:0] forward_rs2_EX, // EX阶段rs2前递控制
    output reg       forward_rs1_ID, // ID阶段rs1前递控制
    output reg       forward_rs2_ID  // ID阶段rs2前递控制
);
    always @(*) begin
        // EX阶段rs1前递
        if (RegWrite_MEM && rd_MEM != 5'b0 && rd_MEM == rs1_EX)
            forward_rs1_EX = 2'b01;
        else if (RegWrite_WB && rd_WB != 5'b0 && rd_WB == rs1_EX)
            forward_rs1_EX = 2'b10;
        else
            forward_rs1_EX = 2'b00;
        // EX阶段rs2前递
        if (RegWrite_MEM && rd_MEM != 5'b0 && rd_MEM == rs2_EX)
            forward_rs2_EX = 2'b01;
        else if (RegWrite_WB && rd_WB != 5'b0 && rd_WB == rs2_EX)
            forward_rs2_EX = 2'b10;
        else
            forward_rs2_EX = 2'b00;
        // ID阶段rs1前递
        if (RegWrite_WB && rd_WB != 5'b0 && rd_WB == rs1_ID)
            forward_rs1_ID = 1'b1;
        else
            forward_rs1_ID = 1'b0;
        // ID阶段rs2前递
        if (RegWrite_WB && rd_WB != 5'b0 && rd_WB == rs2_ID)
            forward_rs2_ID = 1'b1;
        else
            forward_rs2_ID = 1'b0;
    end
endmodule 