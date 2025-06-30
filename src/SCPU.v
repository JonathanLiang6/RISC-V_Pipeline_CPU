`include "ctrl_encode_def.v"

// RISC-V 单周期CPU主模块 - 支持完整的RV32I指令集
module SCPU(
    input      clk,            // 时钟信号
    input      reset,          // 复位信号
    input [31:0]  inst_in,     // 指令输入
    input [31:0]  Data_in,     // 数据内存输入
   
    output    mem_w,          // 内存写使能
    output [31:0] PC_out,     // PC地址输出
    output [31:0] Addr_out,   // ALU输出地址
    output [31:0] Data_out,   // 数据内存输出
    output [2:0]  DMType_out, // 内存访问类型输出

    input  [4:0] reg_sel,     // 寄存器选择（调试用）
    output [31:0] reg_data    // 选中寄存器数据（调试用）
);
    // ==================== 控制信号 ====================
    wire        RegWrite;     // 寄存器写使能
    wire [5:0]  EXTOp;        // 立即数扩展控制
    wire [4:0]  ALUOp;        // ALU操作码
    wire [2:0]  NPCOp;        // 下一条PC操作
    wire [1:0]  WDSel;        // 写数据选择
    wire [1:0]  GPRSel;       // 寄存器选择
    wire        ALUSrc;       // ALU源操作数选择
    wire        Zero;         // ALU零标志位
    wire [2:0]  DMType;       // 内存访问类型

    // ==================== 数据通路信号 ====================
    wire [31:0] NPC;          // 下一条PC
    wire [4:0]  rs1;          // 源寄存器1
    wire [4:0]  rs2;          // 源寄存器2
    wire [4:0]  rd;           // 目标寄存器
    wire [6:0]  Op;           // 操作码
    wire [6:0]  Funct7;       // funct7字段
    wire [2:0]  Funct3;       // funct3字段
    wire [11:0] Imm12;        // 12位立即数
    wire [31:0] Imm32;        // 32位立即数
    wire [19:0] IMM;          // 20位立即数
    reg  [4:0]  A3;           // 写寄存器地址
    reg [31:0]  WD;           // 寄存器写数据
    wire [31:0] RD1, RD2;     // 寄存器读数据
    wire [31:0] B;            // ALU操作数B
    wire [31:0] aluout;       // ALU输出
    wire [31:0] debug_RD1;    // 调试用寄存器读数据
	
    // ==================== 立即数字段提取 ====================
    wire [4:0]  iimm_shamt;   // I型指令移位字段
    wire [11:0] iimm, simm, bimm; // 各种指令格式的立即数
    wire [19:0] uimm, jimm;   // U型和J型指令立即数
    wire [31:0] immout;       // 扩展后的立即数

    // ==================== 信号连接 ====================
    assign Addr_out = aluout;     // ALU输出作为地址
    assign DMType_out = DMType;   // 内存访问类型输出
    assign B = (ALUSrc) ? immout : RD2;  // ALU源操作数选择
    assign Data_out = RD2;        // 存储指令的数据输出
	
    // ==================== 指令字段提取 ====================
    assign iimm_shamt = inst_in[24:20];  // 移位指令的shamt字段
    assign iimm = inst_in[31:20];        // I型指令立即数
    assign simm = {inst_in[31:25], inst_in[11:7]}; // S型指令立即数
    assign bimm = {inst_in[31], inst_in[7], inst_in[30:25], inst_in[11:8]}; // B型指令立即数
    assign uimm = inst_in[31:12];        // U型指令立即数
    assign jimm = {inst_in[31], inst_in[19:12], inst_in[20], inst_in[30:21]}; // J型指令立即数
   
    assign Op = inst_in[6:0];            // 操作码
    assign Funct7 = inst_in[31:25];      // funct7字段
    assign Funct3 = inst_in[14:12];      // funct3字段
    assign rs1 = inst_in[19:15];         // 源寄存器1
    assign rs2 = inst_in[24:20];         // 源寄存器2
    assign rd = inst_in[11:7];           // 目标寄存器
    assign Imm12 = inst_in[31:20];       // 12位立即数
    assign IMM = inst_in[31:12];         // 20位立即数
   
    // ==================== 寄存器地址选择 ====================
    always @(*) begin
        case(GPRSel)
            `GPRSel_RD: A3 = rd;         // 选择rd寄存器
            `GPRSel_RT: A3 = rs2;        // 选择rt寄存器（RISC-V中不使用）
            `GPRSel_31: A3 = 5'b11111;   // 选择x31寄存器（用于JAL）
            default:   A3 = rd;          // 默认选择rd
        endcase
    end
   
    // ==================== 模块实例化 ====================
    
    // 控制单元实例化
    ctrl U_ctrl(
        .Op(Op), .Funct7(Funct7), .Funct3(Funct3), .Zero(Zero), 
        .RegWrite(RegWrite), .MemWrite(mem_w),
        .EXTOp(EXTOp), .ALUOp(ALUOp), .NPCOp(NPCOp), 
        .ALUSrc(ALUSrc), .GPRSel(GPRSel), .WDSel(WDSel), .DMType(DMType)
    );
    
    // PC单元实例化
    PC U_PC(.clk(clk), .rst(reset), .NPC(NPC), .PC(PC_out));
    
    // NPC单元实例化
    NPC U_NPC(.PC(PC_out), .NPCOp(NPCOp), .IMM(immout), .NPC(NPC), .aluout(aluout));
    
    // 立即数扩展单元实例化
    EXT U_EXT(
        .iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
        .uimm(uimm), .jimm(jimm),
        .EXTOp(EXTOp), .immout(immout)
    );
    
    // 寄存器文件实例化
    RF U_RF(
        .clk(clk), .rst(reset),
        .RFWr(RegWrite), 
        .A1(rs1), .A2(rs2), .A3(A3), 
        .WD(WD), 
        .RD1(RD1), .RD2(RD2)
    );
    
    // ALU单元实例化
    alu U_alu(.A(RD1), .B(B), .ALUOp(ALUOp), .C(aluout), .Zero(Zero), .PC(PC_out));

    // ==================== 写数据选择逻辑 ====================
    always @(*) begin
        case(WDSel)
            `WDSel_FromALU: WD <= aluout;    // 来自ALU结果
            `WDSel_FromMEM: WD <= Data_in;   // 来自内存数据
            `WDSel_FromPC:  WD <= PC_out + 4; // 来自PC+4（跳转指令）
            default:        WD <= aluout;    // 默认来自ALU
        endcase
    end

    // ==================== 调试寄存器数据输出 ====================
    // 为调试目的，从寄存器文件读取指定寄存器的值
    RF U_RF_debug(
        .clk(clk), .rst(reset),
        .RFWr(1'b0),  // 不写入
        .A1(reg_sel), .A2(5'b0), .A3(5'b0), 
        .WD(32'b0), 
        .RD1(debug_RD1), .RD2()
    );
    
    assign reg_data = debug_RD1;

endmodule