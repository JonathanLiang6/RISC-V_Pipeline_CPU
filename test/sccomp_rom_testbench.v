// ============================================================================
// 文件名称：sccomp_rom_testbench.v
// 文件功能：SoC顶层模块仿真测试平台，测试sccomp模块功能
// ============================================================================
`timescale 1ns / 1ps

module sccomp_rom_testbench;
    reg clk;
    reg rstn;
    reg [4:0] reg_sel;
    wire [31:0] reg_data;
    wire [31:0] instr;
    wire [31:0] PC_out;
    wire [31:0] mem_addr_out;
    wire [31:0] mem_data_out;
    wire [31:0] debug_data;
    wire        stall_IF;

    // =====================
    // 时钟生成
    // =====================
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz

    // =====================
    // 复位与寄存器选择初始化
    // =====================
    initial begin
        rstn = 0;
        reg_sel = 0;
        #20;
        rstn = 1;
        #100000;
        $stop;
    end

    // =====================
    // DUT实例化
    // =====================
    sccomp dut(
        .clk(clk),
        .rstn(rstn),
        .reg_sel(reg_sel),
        .reg_data(reg_data),
        .instr(instr),
        .PC_out(PC_out),
        .mem_addr_out(mem_addr_out),
        .mem_data_out(mem_data_out),
        .debug_data(debug_data),
        .stall_IF(stall_IF)
    );
endmodule 