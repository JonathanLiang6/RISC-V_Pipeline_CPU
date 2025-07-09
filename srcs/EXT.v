`include "ctrl_encode_def.v"

// 立即数扩展模块，根据不同指令类型对立即数进行符号扩展或拼接
module EXT( 
	input   [4:0] 	iimm_shamt,
    input	[11:0]			iimm, // instr[31:20]，12位
	input	[11:0]			simm, // instr[31:25, 11:7]，12位
	input	[11:0]			bimm, // instrD[31], instrD[7], instrD[30:25], instrD[11:8]，12位
	input	[19:0]			uimm,
	input	[19:0]			jimm,
	input	[5:0]			EXTOp,

	output	reg [31:0] 	       immout);
	
    // 输入bimm为{instr[31], instr[7], instr[30:25], instr[11:8]}
    // 输入jimm为{instr[31], instr[19:12], instr[20], instr[30:21]}
   
always  @(*)
     // 根据EXTOp选择不同的扩展方式
	 case (EXTOp)
		`EXT_CTRL_ITYPE_SHAMT:   immout<={27'b0,iimm_shamt[4:0]};
		`EXT_CTRL_ITYPE:	immout <= {{20{iimm[11]}}, iimm[11:0]};
		`EXT_CTRL_STYPE:	immout <= {{20{simm[11]}}, simm[11:0]};
		`EXT_CTRL_BTYPE:    immout <= {{19{bimm[11]}}, bimm, 1'b0};
		`EXT_CTRL_UTYPE:	immout <= {uimm[19:0], 12'b0};
		`EXT_CTRL_JTYPE:	immout <= {{11{jimm[19]}}, jimm[19:0],1'b0};
		default:	        immout <= 32'b0;
	 endcase

       
endmodule
