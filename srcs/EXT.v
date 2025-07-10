// ============================================================================
// 模块名称：EXT
// 模块功能：立即数扩展模块，根据指令类型对立即数进行符号扩展或拼接
// ============================================================================
`include "ctrl_encode_def.v"

module EXT (
    input   [4:0]  iimm_shamt, // I型移位立即数
    input  [11:0]  iimm,       // I型立即数 instr[31:20]
    input  [11:0]  simm,       // S型立即数 instr[31:25, 11:7]
    input  [11:0]  bimm,       // B型立即数 {instr[31], instr[7], instr[30:25], instr[11:8]}
    input  [19:0]  uimm,       // U型立即数
    input  [19:0]  jimm,       // J型立即数 {instr[31], instr[19:12], instr[20], instr[30:21]}
    input   [5:0]  EXTOp,      // 扩展控制信号
    output reg [31:0] immout   // 扩展后输出
);
    // =====================
    // 立即数扩展逻辑
    // =====================
    always @(*) begin
        case (EXTOp)
            `EXT_CTRL_ITYPE_SHAMT:   immout <= {27'b0, iimm_shamt[4:0]};
            `EXT_CTRL_ITYPE:         immout <= {{20{iimm[11]}}, iimm[11:0]};
            `EXT_CTRL_STYPE:         immout <= {{20{simm[11]}}, simm[11:0]};
            `EXT_CTRL_BTYPE:         immout <= {{19{bimm[11]}}, bimm, 1'b0};
            `EXT_CTRL_UTYPE:         immout <= {uimm[19:0], 12'b0};
            `EXT_CTRL_JTYPE:         immout <= {{11{jimm[19]}}, jimm[19:0], 1'b0};
            default:                 immout <= 32'b0;
        endcase
    end
endmodule
