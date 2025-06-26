//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The alu module implements the core's ALU.
//
// ====================================================================

`include "xgriscv_defines.v"
module alu(
	input	[`XLEN-1:0]	a, b, 
	input	[4:0]  		shamt, 
	input	[3:0]   	aluctrl, 

	output reg [`XLEN-1:0]	aluout,
	output       		overflow,
	output 			zero,
	output 			lt,
	output 			ge
	);

	wire op_unsigned = ~aluctrl[3]&~aluctrl[2]&aluctrl[1]&~aluctrl[0]	//ALU_CTRL_ADDU	4'b0010
					| aluctrl[3]&~aluctrl[2]&aluctrl[1]&~aluctrl[0] 	//ALU_CTRL_SUBU	4'b1010
					| aluctrl[3]&aluctrl[2]&~aluctrl[1]&~aluctrl[0]; 	//ALU_CTRL_SLTU	4'b1100

	wire [`XLEN-1:0] 	b2;
	wire [`XLEN:0] 		sum; //adder of length XLEN+1
  
	assign b2 = aluctrl[3] ? ~b:b; 
	assign sum = (op_unsigned & ({1'b0, a} + {1'b0, b2} + aluctrl[3]))
				| (~op_unsigned & ({a[`XLEN-1], a} + {b2[`XLEN-1], b2} + aluctrl[3]));
				// aluctrl[3]=0 if add, or 1 if sub, don't care if other

	always@(*)
		case(aluctrl[3:0])
		`ALU_CTRL_MOVEA: 	aluout <= a;
		`ALU_CTRL_ADD: 		aluout <= a + b;
		`ALU_CTRL_SUB: 		aluout <= a - b;
		`ALU_CTRL_SLL: 		aluout <= a << b[4:0];
		`ALU_CTRL_SLT: 		aluout <= ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
		`ALU_CTRL_SLTU: 	aluout <= (a < b) ? 32'b1 : 32'b0;
		`ALU_CTRL_XOR: 		aluout <= a ^ b;
		`ALU_CTRL_SRL: 		aluout <= a >> b[4:0];
		`ALU_CTRL_SRA: 		aluout <= $signed(a) >>> b[4:0];
		`ALU_CTRL_OR: 		aluout <= a | b;
		`ALU_CTRL_AND: 		aluout <= a & b;
		`ALU_CTRL_LUI: 		aluout <= b; //a = 0, b = immout
		`ALU_CTRL_AUIPC: 	aluout <= a + b; //a = pc, b = immout
		default: 			aluout <= `XLEN'b0; 
	 endcase
	    
	assign overflow = sum[`XLEN-1] ^ sum[`XLEN];
	assign zero = (aluout == `XLEN'b0);
	assign lt = aluout[`XLEN-1];
	assign ge = ~aluout[`XLEN-1];
endmodule

