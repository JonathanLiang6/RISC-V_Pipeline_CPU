//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The controller module generates the controlling signals.
//
// ====================================================================

`include "xgriscv_defines.v"

module controller(
  input                     clk, reset,
  input [6:0]	              opcode,
  input [2:0]               funct3,
  input [6:0]               funct7,
  input [`RFIDX_WIDTH-1:0]  rd, rs1,
  input [11:0]              imm,
  input                     zero, lt, // from cmp in the decode stage

  output [4:0]              immctrl,            // for the ID stage
  output                    itype, jal, jalr, bunsigned, pcsrc,
  output reg  [3:0]         aluctrl,            // for the EX stage 
  output [1:0]              alusrca,
  output                    alusrcb,
  output                    memwrite, lunsigned,  // for the MEM stage
  output [1:0]              lwhb, swhb,
  output                    memtoreg, regwrite  // for the WB stage
  );

  wire rv32_lui		= (opcode == `OP_LUI);
  wire rv32_auipc	= (opcode == `OP_AUIPC);
  wire rv32_jal		= (opcode == `OP_JAL);
  wire rv32_jalr	= (opcode == `OP_JALR);
  wire rv32_branch= (opcode == `OP_BRANCH);
  wire rv32_load	= (opcode == `OP_LOAD); 
  wire rv32_store	= (opcode == `OP_STORE);
  wire rv32_addri	= (opcode == `OP_ADDI);
  wire rv32_addrr = (opcode == `OP_ADD);

  wire rv32_beq		= ((opcode == `OP_BRANCH) & (funct3 == `FUNCT3_BEQ));
  wire rv32_bne		= ((opcode == `OP_BRANCH) & (funct3 == `FUNCT3_BNE));
  wire rv32_blt		= ((opcode == `OP_BRANCH) & (funct3 == `FUNCT3_BLT));
  wire rv32_bge		= ((opcode == `OP_BRANCH) & (funct3 == `FUNCT3_BGE));
  wire rv32_bltu	= ((opcode == `OP_BRANCH) & (funct3 == `FUNCT3_BLTU));
  wire rv32_bgeu	= ((opcode == `OP_BRANCH) & (funct3 == `FUNCT3_BGEU));

  wire rv32_lb		= ((opcode == `OP_LOAD) & (funct3 == `FUNCT3_LB));
  wire rv32_lh		= ((opcode == `OP_LOAD) & (funct3 == `FUNCT3_LH));
  wire rv32_lw		= ((opcode == `OP_LOAD) & (funct3 == `FUNCT3_LW));
  wire rv32_lbu		= ((opcode == `OP_LOAD) & (funct3 == `FUNCT3_LBU));
  wire rv32_lhu		= ((opcode == `OP_LOAD) & (funct3 == `FUNCT3_LHU));

  wire rv32_sb		= ((opcode == `OP_STORE) & (funct3 == `FUNCT3_SB));
  wire rv32_sh		= ((opcode == `OP_STORE) & (funct3 == `FUNCT3_SH));
  wire rv32_sw		= ((opcode == `OP_STORE) & (funct3 == `FUNCT3_SW));

  wire rv32_addi  = (opcode == 7'b0010011) & (funct3 == 3'b000);
  wire rv32_slti  = (opcode == 7'b0010011) & (funct3 == 3'b010);
  wire rv32_sltiu = (opcode == 7'b0010011) & (funct3 == 3'b011);
  wire rv32_xori  = (opcode == 7'b0010011) & (funct3 == 3'b100);
  wire rv32_ori   = (opcode == 7'b0010011) & (funct3 == 3'b110);
  wire rv32_andi  = (opcode == 7'b0010011) & (funct3 == 3'b111);
  wire rv32_slli  = (opcode == 7'b0010011) & (funct3 == 3'b001) & (funct7 == 7'b0000000);
  wire rv32_srli  = (opcode == 7'b0010011) & (funct3 == 3'b101) & (funct7 == 7'b0000000);
  wire rv32_srai  = (opcode == 7'b0010011) & (funct3 == 3'b101) & (funct7 == 7'b0100000);

  wire rv32_add   = (opcode == 7'b0110011) & (funct3 == 3'b000) & (funct7 == 7'b0000000);
  wire rv32_sub   = (opcode == 7'b0110011) & (funct3 == 3'b000) & (funct7 == 7'b0100000);
  wire rv32_sll   = (opcode == 7'b0110011) & (funct3 == 3'b001) & (funct7 == 7'b0000000);
  wire rv32_slt   = (opcode == 7'b0110011) & (funct3 == 3'b010) & (funct7 == 7'b0000000);
  wire rv32_sltu  = (opcode == 7'b0110011) & (funct3 == 3'b011) & (funct7 == 7'b0000000);
  wire rv32_xor   = (opcode == 7'b0110011) & (funct3 == 3'b100) & (funct7 == 7'b0000000);
  wire rv32_srl   = (opcode == 7'b0110011) & (funct3 == 3'b101) & (funct7 == 7'b0000000);
  wire rv32_sra   = (opcode == 7'b0110011) & (funct3 == 3'b101) & (funct7 == 7'b0100000);
  wire rv32_or    = (opcode == 7'b0110011) & (funct3 == 3'b110) & (funct7 == 7'b0000000);
  wire rv32_and   = (opcode == 7'b0110011) & (funct3 == 3'b111) & (funct7 == 7'b0000000);

  wire rv32_rs1_x0= (rs1 == 5'b00000);
  wire rv32_rd_x0 = (rd  == 5'b00000);
  wire rv32_nop		= rv32_addi & rv32_rs1_x0 & rv32_rd_x0 & (imm == 12'b0); //addi x0, x0, 0 is nop

  assign itype = rv32_addi;

  wire stype = 0;

  wire btype = 0;

  wire utype = rv32_lui | rv32_auipc;

  wire jtype = 0;

  assign immctrl = (rv32_addi | rv32_slti | rv32_sltiu | rv32_xori | rv32_ori | rv32_andi | rv32_slli | rv32_srli | rv32_srai) ? `IMM_CTRL_ITYPE :
                   (rv32_lui | rv32_auipc) ? `IMM_CTRL_UTYPE : 5'b0;

  assign jal = 0;
  
  assign jalr = 0;

  assign bunsigned = 0;

  assign pcsrc = 0;

  assign alusrca = 2'b00;

  assign alusrcb = (opcode == 7'b0010011);

  assign memwrite = 0;

  assign swhb = 0;

  assign lwhb = 0;

  assign lunsigned = 0;

  assign memtoreg = 0;

  assign regwrite = rv32_addi | rv32_slti | rv32_sltiu | rv32_xori | rv32_ori | rv32_andi | rv32_slli | rv32_srli | rv32_srai |
                    rv32_add | rv32_sub | rv32_sll | rv32_slt | rv32_sltu | rv32_xor | rv32_srl | rv32_sra | rv32_or | rv32_and |
                    rv32_lui | rv32_auipc;

  always @(*) begin
    case (1'b1)
      rv32_addi, rv32_add:   aluctrl = `ALU_CTRL_ADD;
      rv32_sub:              aluctrl = `ALU_CTRL_SUB;
      rv32_slti, rv32_slt:   aluctrl = `ALU_CTRL_SLT;
      rv32_sltiu, rv32_sltu: aluctrl = `ALU_CTRL_SLTU;
      rv32_xori, rv32_xor:   aluctrl = `ALU_CTRL_XOR;
      rv32_ori, rv32_or:     aluctrl = `ALU_CTRL_OR;
      rv32_andi, rv32_and:   aluctrl = `ALU_CTRL_AND;
      rv32_slli, rv32_sll:   aluctrl = `ALU_CTRL_SLL;
      rv32_srli, rv32_srl:   aluctrl = `ALU_CTRL_SRL;
      rv32_srai, rv32_sra:   aluctrl = `ALU_CTRL_SRA;
      default:               aluctrl = `ALU_CTRL_ZERO;
    endcase
  end

endmodule