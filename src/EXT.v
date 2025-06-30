`include "ctrl_encode_def.v"

// 立即数扩展模块 - 处理不同指令格式的立即数扩展
// 支持I型、S型、B型、U型、J型指令的立即数处理
module EXT( 
	input [4:0] iimm_shamt,  // I型指令移位操作的shamt字段
	input	[11:0]			iimm, //instr[31:20], 12 bits
	input	[11:0]			simm, //instr[31:25, 11:7], 12 bits
	input	[11:0]			bimm, //instrD[31], instrD[7], instrD[30:25], instrD[11:8], 12 bits
	input	[19:0]			uimm,
	input	[19:0]			jimm,
	input	[5:0]			EXTOp,

	output	reg [31:0] 	       immout);
   
	always @(*) begin
		case (EXTOp)
			`EXT_CTRL_ITYPE_SHAMT:  
				immout <= {27'b0, iimm_shamt[4:0]};                    // 移位指令：零扩展5位shamt
			
			`EXT_CTRL_ITYPE:	
				immout <= {{20{iimm[11]}}, iimm[11:0]};                // I型指令：符号扩展12位立即数
			
			`EXT_CTRL_STYPE:	
				immout <= {{20{simm[11]}}, simm[11:0]};                // S型指令：符号扩展12位立即数
			
			`EXT_CTRL_BTYPE:       
				immout <= {{20{bimm[11]}}, bimm[11:0], 1'b0};          // B型指令：符号扩展13位立即数，左移1位
			
			`EXT_CTRL_UTYPE:	
				immout <= {uimm[19:0], 12'b0};                         // U型指令：20位立即数左移12位
			
			`EXT_CTRL_JTYPE:	
				immout <= {{12{jimm[19]}}, jimm[19:0], 1'b0};          // J型指令：符号扩展21位立即数，左移1位
			
			default:	       
				immout <= 32'b0;                                       // 默认情况：零扩展
		endcase
	end

       
endmodule
