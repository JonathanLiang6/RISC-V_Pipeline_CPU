// RISC-V 单周期CPU顶层模块 - 连接CPU、指令内存和数据内存
module sccomp(clk, rstn, reg_sel, reg_data);
   input          clk;        // 时钟信号
   input          rstn;       // 复位信号（低电平有效）
   input [4:0]    reg_sel;    // 寄存器选择（调试用）
   output [31:0]  reg_data;   // 选中寄存器数据（调试用）
   
   // ==================== 内部信号 ====================
   wire [31:0]    instr;      // 指令
   wire [31:0]    PC;         // 程序计数器
   wire           MemWrite;   // 内存写使能
   wire [31:0]    dm_addr;    // 数据内存地址
   wire [31:0]    dm_din;     // 数据内存输入数据
   wire [31:0]    dm_dout;    // 数据内存输出数据
   wire [2:0]     dm_type;    // 数据内存访问类型
   
   wire rst = ~rstn;          // 复位信号转换（高电平有效）
       
   // ==================== 单周期CPU实例化 ====================
   SCPU U_SCPU(
         .clk(clk),                 // 输入：CPU时钟
         .reset(rst),               // 输入：复位信号
         .inst_in(instr),           // 输入：指令
         .Data_in(dm_dout),         // 输入：来自数据内存的数据
         .mem_w(MemWrite),          // 输出：内存写使能
         .PC_out(PC),               // 输出：程序计数器
         .Addr_out(dm_addr),        // 输出：CPU到内存的地址
         .Data_out(dm_din),         // 输出：CPU到内存的数据
         .DMType_out(dm_type),      // 输出：内存访问类型
         .reg_sel(reg_sel),         // 输入：寄存器选择
         .reg_data(reg_data)        // 输出：寄存器数据
   );
         
   // ==================== 数据内存实例化 ====================
   dm U_DM(
         .clk(clk),                 // 输入：CPU时钟
         .DMWr(MemWrite),           // 输入：内存写使能
         .DMType(dm_type),          // 输入：内存访问类型
         .addr(dm_addr[8:2]),       // 输入：内存地址
         .din(dm_din),              // 输入：写入内存的数据
         .dout(dm_dout)             // 输出：从内存读取的数据
   );
         
   // ==================== 指令内存实例化（用于仿真） ====================
   im U_IM ( 
      .addr(PC[8:2]),              // 输入：ROM地址
      .dout(instr)                 // 输出：指令
   );
        
endmodule

