// ============================================================================
// 模块名称：top_module
// 模块功能：FPGA顶层模块，集成CPU、显示、按键等外设，适配Nexys4DDR开发板
// ============================================================================
module top_module(
    input         clk,            // 100MHz系统时钟
    input         rstn,           // 复位信号，低电平有效
    input  [15:0] sw_i,           // 16位开关输入
    output [7:0]  disp_seg_o,     // 七段数码管段选信号
    output [7:0]  disp_an_o       // 七段数码管位选信号
);
    // =====================
    // 参数定义
    // =====================
    parameter REG_DATA_NUM  = 5'd31;   // 寄存器数量
    parameter DMEM_DATA_NUM = 4'd15;   // 数据存储器数量
    // =====================
    // 内部信号定义
    // =====================
    reg  [27:0] clkdiv;                // 时钟分频计数器
    wire        Clk_CPU;               // CPU时钟
    wire        Clk_instr;             // 指令执行时钟
    wire        Clk_display;           // 数码管显示时钟
    wire [31:0] PC_out;                // 程序计数器输出
    wire [31:0] instr;                 // 当前指令
    wire [31:0] reg_data;              // 寄存器数据
    wire [31:0] mem_addr_out;          // 内存访问地址
    wire [31:0] mem_data_out;          // 内存访问数据
    wire [31:0] debug_data;            // 调试数据
    reg  [4:0]  reg_addr;              // 寄存器地址
    reg  [3:0]  dmem_addr;             // 数据存储器地址
    reg         sw3_last, sw4_last;    // 开关状态记录
    reg  [31:0] reg_data_from_cpu;     // CPU寄存器数据
    reg  [31:0] dmem_data;             // 数据存储器数据
    reg  [31:0] access_addr_data;      // 访问地址数据
    reg  [31:0] display_data;          // 显示数据
    // =====================
    // 时钟分频逻辑
    // =====================
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            clkdiv <= 0;
        else
            clkdiv <= clkdiv + 1'b1;
    end
    assign Clk_CPU     = (sw_i[15]) ? clkdiv[27] : clkdiv[20];
    assign Clk_instr   = Clk_CPU & ~sw_i[1];
    assign Clk_display = clkdiv[16];
    // =====================
    // CPU实例化
    // =====================
    sccomp cpu(
        .clk(Clk_instr),
        .rstn(rstn),
        .reg_sel(reg_addr),
        .reg_data(reg_data),
        .instr(instr),
        .PC_out(PC_out),
        .mem_addr_out(mem_addr_out),
        .mem_data_out(mem_data_out),
        .debug_data(debug_data)
    );
    // =====================
    // 显示控制逻辑
    // =====================
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            reg_addr  <= 5'b0;
            dmem_addr <= 4'b0;
            sw3_last  <= 1'b0;
            sw4_last  <= 1'b0;
        end else begin
            sw3_last <= sw_i[3];
            sw4_last <= sw_i[4];
            if (sw_i[0]) begin
                reg_addr  <= sw_i[6:2];
                dmem_addr <= sw_i[5:2];
            end else begin
                if (sw_i[2]) begin
                    reg_addr  <= 5'b0;
                    dmem_addr <= 4'b0;
                end else if (sw_i[3] && !sw3_last) begin
                    reg_addr  <= (reg_addr  == REG_DATA_NUM)  ? 5'd0  : reg_addr  + 1'b1;
                    dmem_addr <= (dmem_addr == DMEM_DATA_NUM) ? 4'd0  : dmem_addr + 1'b1;
                end else if (sw_i[4] && !sw4_last) begin
                    reg_addr  <= (reg_addr  == 5'd0)          ? REG_DATA_NUM  : reg_addr  - 1'b1;
                    dmem_addr <= (dmem_addr == 4'd0)          ? DMEM_DATA_NUM : dmem_addr - 1'b1;
                end
            end
        end
    end
    always @(*) reg_data_from_cpu = reg_data;
    always @(*) dmem_data = mem_data_out;
    always @(*) begin
        if (mem_addr_out != 32'h0 || mem_data_out != 32'h0)
            access_addr_data = mem_addr_out;
        else
            access_addr_data = 32'hFFFFFFFF;
    end
    always @(*) begin
        if (sw_i[10] == 1'b1)
            display_data = debug_data;
        else begin
            case (sw_i[14:11])
                4'b1000: display_data = instr;
                4'b0100: display_data = reg_data_from_cpu;
                4'b0010: display_data = access_addr_data;
                4'b0001: display_data = dmem_data;
                4'b1001: display_data = PC_out;
                default: display_data = PC_out;
            endcase
        end
    end
    // =====================
    // 七段数码管控制器实例化
    // =====================
    seg7_controller seg7_ctrl(
        .clk(Clk_display),
        .rstn(rstn),
        .data(display_data),
        .seg(disp_seg_o),
        .an(disp_an_o)
    );
endmodule

// ============================================================================
// 模块名称：seg7_controller
// 模块功能：七段数码管控制器模块
// ============================================================================
module seg7_controller(
    input         clk,         // 时钟信号
    input         rstn,        // 复位信号
    input  [31:0] data,        // 显示数据
    output reg [7:0] seg,      // 段选信号
    output reg [7:0] an        // 位选信号
);
    reg [2:0] digit_sel;
    reg [3:0] digit_data;
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            digit_sel <= 3'b000;
        else
            digit_sel <= digit_sel + 1;
    end
    always @(*) begin
        case (digit_sel)
            3'b000: digit_data = data[3:0];
            3'b001: digit_data = data[7:4];
            3'b010: digit_data = data[11:8];
            3'b011: digit_data = data[15:12];
            3'b100: digit_data = data[19:16];
            3'b101: digit_data = data[23:20];
            3'b110: digit_data = data[27:24];
            3'b111: digit_data = data[31:28];
        endcase
    end
    always @(*) begin
        case (digit_sel)
            3'b000: an = 8'b11111110;
            3'b001: an = 8'b11111101;
            3'b010: an = 8'b11111011;
            3'b011: an = 8'b11110111;
            3'b100: an = 8'b11101111;
            3'b101: an = 8'b11011111;
            3'b110: an = 8'b10111111;
            3'b111: an = 8'b01111111;
        endcase
    end
    always @(*) begin
        case (digit_data)
            4'h0: seg = 8'b11000000;
            4'h1: seg = 8'b11111001;
            4'h2: seg = 8'b10100100;
            4'h3: seg = 8'b10110000;
            4'h4: seg = 8'b10011001;
            4'h5: seg = 8'b10010010;
            4'h6: seg = 8'b10000010;
            4'h7: seg = 8'b11111000;
            4'h8: seg = 8'b10000000;
            4'h9: seg = 8'b10010000;
            4'hA: seg = 8'b10001000;
            4'hB: seg = 8'b10000011;
            4'hC: seg = 8'b11000110;
            4'hD: seg = 8'b10100001;
            4'hE: seg = 8'b10000110;
            4'hF: seg = 8'b10001110;
            default: seg = 8'b11111111;
        endcase
    end
endmodule 