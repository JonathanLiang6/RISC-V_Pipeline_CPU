`include "ctrl_encode_def.v"
module SCPU(
    input      clk,            // 时钟信号
    input      reset,          // 复位信号
    input [31:0]  inst_in,     // 指令输入
    input [31:0]  Data_in,     // 来自数据内存的数据
   
    output    mem_w,          // 输出: 内存写信号
    output [31:0] PC_out,     // PC地址
      // memory write
    output [31:0] Addr_out,   // ALU输出
    output [31:0] Data_out,   // 输出到数据内存的数据
    output [2:0] DMType_out,  // 输出: 数据内存访问类型控制信号

    input  [4:0] reg_sel,    // 寄存器选择 (用于调试)
    output [31:0] reg_data  // 选中的寄存器数据 (用于调试)
);
    wire        RegWrite;    // 寄存器写控制信号
    wire [5:0]       EXTOp;       // 符号扩展控制信号
    wire [4:0]  ALUOp;       // ALU操作
    wire [2:0]  NPCOp;       // 下一条PC操作

    wire [1:0]  WDSel;       // (寄存器)写数据选择
    wire [1:0]  GPRSel;      // 通用寄存器选择
   
    wire        ALUSrc;      // ALU源操作数A
    wire        Zero;        // ALU输出零标志

    wire [31:0] NPC;         // 下一条PC

    wire [4:0]  rs1;          // rs
    wire [4:0]  rs2;          // rt
    wire [4:0]  rd;          // rd
    wire [6:0]  Op;          // opcode
    wire [6:0]  Funct7;       // funct7
    wire [2:0]  Funct3;       // funct3
    wire [11:0] Imm12;       // 12位立即数
    wire [31:0] Imm32;       // 32位立即数
    wire [19:0] IMM;         // 20位立即数 (地址)
    wire [4:0]  A3;          // 寄存器写地址
    reg [31:0] WD;          // 寄存器写数据
    wire [31:0] RD1,RD2;         // 由rs指定的寄存器数据
    wire [31:0] B;           // ALU操作数B
	
	wire [4:0] iimm_shamt;
	wire [11:0] iimm,simm,bimm;
	wire [19:0] uimm,jimm;
	wire [31:0] immout;
wire[31:0] aluout;
assign Addr_out=aluout;
	assign B = (ALUSrc) ? immout : RD2;
	assign Data_out = RD2;
	
	assign iimm_shamt=inst_in[24:20];
	assign iimm=inst_in[31:20];
	assign simm={inst_in[31:25],inst_in[11:7]};
	assign bimm={inst_in[31],inst_in[7],inst_in[30:25],inst_in[11:8]};
	assign uimm=inst_in[31:12];
	assign jimm={inst_in[31],inst_in[19:12],inst_in[20],inst_in[30:21]};
   
    assign Op = inst_in[6:0];  // instruction
    assign Funct7 = inst_in[31:25]; // funct7
    assign Funct3 = inst_in[14:12]; // funct3
    assign rs1 = inst_in[19:15];  // rs1
    assign rs2 = inst_in[24:20];  // rs2
    assign rd = inst_in[11:7];  // rd
    assign Imm12 = inst_in[31:20];// 12-bit immediate
    assign IMM = inst_in[31:12];  // 20-bit immediate
   
   // 控制单元实例化
	ctrl U_ctrl(
		.Op(Op), .Funct7(Funct7), .Funct3(Funct3), .Zero(Zero), 
		.RegWrite(RegWrite), .MemWrite(mem_w),
		.EXTOp(EXTOp), .ALUOp(ALUOp), .NPCOp(NPCOp), 
		.ALUSrc(ALUSrc), .GPRSel(GPRSel), .WDSel(WDSel),
		.DMType(DMType_out) // 添加DMType连接
	);
 // instantiation of pc unit
	PC U_PC(.clk(clk), .rst(reset), .NPC(NPC), .PC(PC_out) );
	NPC U_NPC(.PC(PC_out), .NPCOp(NPCOp), .IMM(immout), .NPC(NPC), .aluout(aluout));
	EXT U_EXT(
		.iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
		.uimm(uimm), .jimm(jimm),
		.EXTOp(EXTOp), .immout(immout)
	);
	RF U_RF(
		.clk(clk), .rst(reset),
		.RFWr(RegWrite), 
		.A1(rs1), .A2(rs2), .A3(rd), 
		.WD(WD), 
		.RD1(RD1), .RD2(RD2)
		//.reg_sel(reg_sel),
		//.reg_data(reg_data)
	);
// instantiation of alu unit
	alu U_alu(.A(RD1), .B(B), .ALUOp(ALUOp), .C(aluout), .Zero(Zero), .PC(PC_out));

//please connnect the CPU by yourself
always @*
begin
	case(WDSel)
		`WDSel_FromALU: WD<=aluout;
		`WDSel_FromMEM: WD<=Data_in;
		`WDSel_FromPC: WD<=PC_out+4;
	endcase
end


endmodule