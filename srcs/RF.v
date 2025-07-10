// ============================================================================
// 模块名称：RF
// 模块功能：通用寄存器堆，包含32个32位寄存器，支持读写和调试端口
// ============================================================================
module RF(
    input         clk,         // 时钟信号
    input         rst,         // 复位信号
    input         RFWr,        // 写使能
    input  [4:0]  A1,          // 读端口1地址
    input  [4:0]  A2,          // 读端口2地址
    input  [4:0]  A3,          // 写端口地址
    input  [31:0] WD,          // 写入数据
    output [31:0] RD1,         // 读端口1数据
    output [31:0] RD2,         // 读端口2数据
    input  [4:0]  reg_sel,     // 调试端口地址
    output [31:0] reg_data     // 调试端口数据
);
    reg [31:0] rf[31:0];       // 32个32位寄存器
    integer i;
    // =====================
    // 寄存器堆复位
    // =====================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                rf[i] <= 0;
        end else if (RFWr && A3 != 0) begin
            rf[A3] <= WD;
        end
    end
    // =====================
    // 读端口
    // =====================
    assign RD1 = (A1 != 0) ? rf[A1] : 0;
    assign RD2 = (A2 != 0) ? rf[A2] : 0;
    assign reg_data = (reg_sel != 0) ? rf[reg_sel] : 0;
endmodule 
