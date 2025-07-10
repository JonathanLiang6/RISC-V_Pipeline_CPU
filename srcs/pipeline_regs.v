// ============================================================================
// 文件名称：pipeline_regs.v
// 文件功能：流水线寄存器模块，保存各阶段数据和控制信号，实现5级流水线数据传递
// ============================================================================

// --------------------
// IF/ID流水线寄存器
// --------------------
module IF_ID_Reg(
    input         clk,         // 时钟信号
    input         rst,         // 复位信号
    input         flush,       // 冲刷信号
    input         stall,       // 暂停信号
    input  [31:0] PC_in,       // 输入PC
    input  [31:0] instr_in,    // 输入指令
    output reg [31:0] PC_out,  // 输出PC
    output reg [31:0] instr_out// 输出指令
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC_out <= 32'h0;
            instr_out <= 32'h00000013;
        end else if (flush) begin
            PC_out <= 32'h0;
            instr_out <= 32'h00000013;
        end else if (!stall) begin
            PC_out <= PC_in;
            instr_out <= instr_in;
        end
    end
endmodule

// --------------------
// ID/EX流水线寄存器
// --------------------
module ID_EX_Reg(
    input         clk,
    input         rst,
    input         flush,
    input  [31:0] PC_in,
    input  [31:0] instr_in,
    input  [31:0] rs1_data_in,
    input  [31:0] rs2_data_in,
    input  [31:0] imm_in,
    input         RegWrite_in,
    input         MemWrite_in,
    input         MemRead_in,
    input  [4:0]  ALUOp_in,
    input         ALUSrc_in,
    input  [1:0]  WDSel_in,
    input  [2:0]  DMType_in,
    output reg [31:0] PC_out,
    output reg [31:0] instr_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] imm_out,
    output reg        RegWrite_out,
    output reg        MemWrite_out,
    output reg        MemRead_out,
    output reg [4:0]  ALUOp_out,
    output reg        ALUSrc_out,
    output reg [1:0]  WDSel_out,
    output reg [2:0]  DMType_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC_out <= 32'h0;
            instr_out <= 32'h00000013;
            rs1_data_out <= 32'h0;
            rs2_data_out <= 32'h0;
            imm_out <= 32'h0;
            RegWrite_out <= 1'b0;
            MemWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            ALUOp_out <= 5'h0;
            ALUSrc_out <= 1'b0;
            WDSel_out <= 2'h0;
            DMType_out <= 3'h0;
        end else if (flush) begin
            PC_out <= 32'h0;
            instr_out <= 32'h00000013;
            rs1_data_out <= 32'h0;
            rs2_data_out <= 32'h0;
            imm_out <= 32'h0;
            RegWrite_out <= 1'b0;
            MemWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            ALUOp_out <= 5'h0;
            ALUSrc_out <= 1'b0;
            WDSel_out <= 2'h0;
            DMType_out <= 3'h0;
        end else begin
            PC_out <= PC_in;
            instr_out <= instr_in;
            rs1_data_out <= rs1_data_in;
            rs2_data_out <= rs2_data_in;
            imm_out <= imm_in;
            RegWrite_out <= RegWrite_in;
            MemWrite_out <= MemWrite_in;
            MemRead_out <= MemRead_in;
            ALUOp_out <= ALUOp_in;
            ALUSrc_out <= ALUSrc_in;
            WDSel_out <= WDSel_in;
            DMType_out <= DMType_in;
        end
    end
endmodule

// --------------------
// EX/MEM流水线寄存器
// --------------------
module EX_MEM_Reg(
    input         clk,
    input         rst,
    input  [31:0] alu_result_in,
    input  [31:0] rs2_data_in,
    input  [31:0] instr_in,
    input         RegWrite_in,
    input         MemWrite_in,
    input         MemRead_in,
    input  [1:0]  WDSel_in,
    input  [2:0]  DMType_in,
    input  [31:0] PC_in,
    output reg [31:0] alu_result_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] instr_out,
    output reg        RegWrite_out,
    output reg        MemWrite_out,
    output reg        MemRead_out,
    output reg [1:0]  WDSel_out,
    output reg [2:0]  DMType_out,
    output reg [31:0] PC_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_out <= 32'h0;
            rs2_data_out <= 32'h0;
            instr_out <= 32'h00000013;
            RegWrite_out <= 1'b0;
            MemWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            WDSel_out <= 2'h0;
            DMType_out <= 3'h0;
            PC_out <= 32'h0;
        end else begin
            alu_result_out <= alu_result_in;
            rs2_data_out <= rs2_data_in;
            instr_out <= instr_in;
            RegWrite_out <= RegWrite_in;
            MemWrite_out <= MemWrite_in;
            MemRead_out <= MemRead_in;
            WDSel_out <= WDSel_in;
            DMType_out <= DMType_in;
            PC_out <= PC_in;
        end
    end
endmodule

// --------------------
// MEM/WB流水线寄存器
// --------------------
module MEM_WB_Reg(
    input         clk,
    input         rst,
    input  [31:0] alu_result_in,
    input  [31:0] mem_data_in,
    input  [31:0] instr_in,
    input         RegWrite_in,
    input  [1:0]  WDSel_in,
    input  [31:0] PC_in,
    output reg [31:0] alu_result_out,
    output reg [31:0] mem_data_out,
    output reg [31:0] instr_out,
    output reg        RegWrite_out,
    output reg [1:0]  WDSel_out,
    output reg [31:0] PC_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_out <= 32'h0;
            mem_data_out <= 32'h0;
            instr_out <= 32'h00000013;
            RegWrite_out <= 1'b0;
            WDSel_out <= 2'h0;
            PC_out <= 32'h0;
        end else begin
            alu_result_out <= alu_result_in;
            mem_data_out <= mem_data_in;
            instr_out <= instr_in;
            RegWrite_out <= RegWrite_in;
            WDSel_out <= WDSel_in;
            PC_out <= PC_in;
        end
    end
endmodule 