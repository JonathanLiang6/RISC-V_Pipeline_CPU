// ============================================================================
// 模块名称：sccomp
// 模块功能：SoC顶层模块，连接CPU、数据存储器和ROM，作为FPGA实验的顶层集成模块
// ============================================================================
module sccomp(
    input         clk,             // 时钟信号
    input         rstn,            // 复位信号（低有效）
    input  [4:0]  reg_sel,         // 调试寄存器选择
    output [31:0] reg_data,        // 调试寄存器数据
    output [31:0] instr,           // 指令输出
    output [31:0] PC_out,          // PC输出
    output [31:0] mem_addr_out,    // 内存访问地址输出
    output [31:0] mem_data_out,    // 内存访问数据输出
    output [31:0] debug_data,      // 调试数据输出
    output        stall_IF         // IF阶段暂停信号
);
    wire [31:0] PC;
    wire        MemWrite;
    wire [31:0] dm_addr, dm_din, dm_dout;
    wire [2:0]  DMType;
    wire [31:0] debug_data_wire;
    wire        rst = ~rstn;
    // =====================
    // 输出信号分配
    // =====================
    assign PC_out = PC;
    assign mem_addr_out = dm_addr;
    assign mem_data_out = MemWrite ? dm_din : dm_dout;
    // =====================
    // CPU实例化
    // =====================
    PipelineCPU U_PipelineCPU(
        .clk(clk),
        .rst(rst),
        .instr_in(instr),
        .Data_in(dm_dout),
        .mem_w(MemWrite),
        .PC_out(PC),
        .Addr_out(dm_addr),
        .Data_out(dm_din),
        .reg_sel(reg_sel),
        .reg_data(reg_data),
        .DMType_out(DMType),
        .debug_data(debug_data_wire),
        .stall_IF(stall_IF)
    );
    // =====================
    // 数据存储器实例化
    // =====================
    dm U_dm(
        .clk(clk),
        .DMWr(MemWrite),
        .DMType(DMType),
        .addr(dm_addr),
        .din(dm_din),
        .dout(dm_dout)
    );
    // =====================
    // ROM实例化
    // =====================
    dist_mem_gen_0 U_ROM(
        .a(PC[8:2]),
        .spo(instr)
    );
    assign debug_data = debug_data_wire;
endmodule

