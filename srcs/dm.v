// ============================================================================
// 模块名称：dm
// 模块功能：数据存储器，支持字、半字、字节的读写，实现RISC-V RV32I存储指令
// ============================================================================
`include "ctrl_encode_def.v"

module dm (
    input         clk,        // 时钟信号
    input         DMWr,       // 存储器写使能（1=写，0=读）
    input  [2:0]  DMType,     // 存储器访问类型
    input  [31:0] addr,       // 存储器地址（32位）
    input  [31:0] din,        // 写入数据（32位）
    output [31:0] dout        // 读出数据（32位）
);
    reg [31:0] dmem[127:0];   // 数据存储器，128个字，每字32位
    wire [31:0] mem_data;     // 存储器原始数据
    wire [1:0]  byte_offset;  // 字节偏移量（地址低2位）
    wire [6:0]  word_addr;    // 字地址（地址高位）
    integer i;

    // =====================
    // 存储器初始化
    // =====================
    initial begin
        for (i = 0; i < 128; i = i + 1)
            dmem[i] = 32'b0;
    end

    // =====================
    // 地址计算
    // =====================
    assign word_addr   = addr[8:2];   // 字地址
    assign byte_offset = addr[1:0];   // 字节偏移

    // =====================
    // 读操作
    // =====================
    // 超出物理空间返回0
    assign mem_data = (addr[31:9] != 23'b0) ? 32'b0 : dmem[word_addr];
    assign dout = (DMType == `DM_WORD) ? mem_data :
                  (DMType == `DM_HALFWORD) ? (byte_offset[1] ? {16'b0, mem_data[31:16]} : {16'b0, mem_data[15:0]}) :
                  (DMType == `DM_HALFWORD_UNSIGNED) ? (byte_offset[1] ? {16'b0, mem_data[31:16]} : {16'b0, mem_data[15:0]}) :
                  (DMType == `DM_BYTE) ? (byte_offset == 2'b00 ? {24'b0, mem_data[7:0]} :
                                            byte_offset == 2'b01 ? {24'b0, mem_data[15:8]} :
                                            byte_offset == 2'b10 ? {24'b0, mem_data[23:16]} :
                                            {24'b0, mem_data[31:24]}) :
                  (DMType == `DM_BYTE_UNSIGNED) ? (byte_offset == 2'b00 ? {24'b0, mem_data[7:0]} :
                                                byte_offset == 2'b01 ? {24'b0, mem_data[15:8]} :
                                                byte_offset == 2'b10 ? {24'b0, mem_data[23:16]} :
                                                {24'b0, mem_data[31:24]}) :
                  mem_data;

    // =====================
    // 写操作
    // =====================
    always @(posedge clk) begin
        if (DMWr && (addr[31:9] == 23'b0)) begin
            case (DMType)
                `DM_WORD: begin
                    dmem[word_addr] <= din;
                end
                `DM_HALFWORD: begin
                    if (byte_offset[1])
                        dmem[word_addr][31:16] <= din[15:0];
                    else
                        dmem[word_addr][15:0] <= din[15:0];
                end
                `DM_BYTE: begin
                    case (byte_offset)
                        2'b00: dmem[word_addr][7:0]    <= din[7:0];
                        2'b01: dmem[word_addr][15:8]   <= din[7:0];
                        2'b10: dmem[word_addr][23:16]  <= din[7:0];
                        2'b11: dmem[word_addr][31:24]  <= din[7:0];
                    endcase
                end
            endcase
        end
    end
endmodule    
