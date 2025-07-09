// SoC顶层模块，连接CPU、数据存储器和ROM，作为FPGA实验的顶层集成模块
module sccomp(clk, rstn, reg_sel, reg_data, instr, PC_out, mem_addr_out, mem_data_out, debug_data, stall_IF);
   input          clk;
   input          rstn;
   input [4:0]    reg_sel;
   output [31:0]  reg_data;
   output [31:0]  instr;
   output [31:0]  PC_out;
   output [31:0]  mem_addr_out;      // 内存访问地址输出
   output [31:0]  mem_data_out;      // 内存访问数据输出
   output [31:0]  debug_data;
   output         stall_IF; // 新增
   
   wire [31:0]    PC;
   wire           MemWrite;
   wire [31:0]    dm_addr, dm_din, dm_dout;
   wire [2:0]     DMType;
   wire [31:0]    debug_data_wire;
   
   wire rst = ~rstn;
   
   // 输出PC
   assign PC_out = PC;
   
   // 输出内存访问地址
   assign mem_addr_out = dm_addr;
   
   // 根据读写状态输出相应数据
   // 如果CPU正在向内存写数据，输出写入的数据
   // 如果内存正在被读，输出读到的数据
   assign mem_data_out = MemWrite ? dm_din : dm_dout;
       
  // 实例化五级流水线CPU   
   PipelineCPU U_PipelineCPU(
         .clk(clk),                 // 输入：CPU时钟
         .rst(rst),                 // 输入：复位
         .instr_in(instr),          // 输入：指令
         .Data_in(dm_dout),         // 输入：数据到CPU  
         .mem_w(MemWrite),          // 输出：内存写使能信号
         .PC_out(PC),               // 输出：PC
         .Addr_out(dm_addr),        // 输出：CPU到内存的地址
         .Data_out(dm_din),         // 输出：CPU到内存的数据
         .reg_sel(reg_sel),         // 输入：寄存器选择
         .reg_data(reg_data),        // 输出：寄存器数据
         .DMType_out(DMType),        // 输出：内存访问类型
         .debug_data(debug_data_wire), // 输出：调试数据
         .stall_IF(stall_IF) // 新增
         );
         
  // 实例化数据存储器  
 dm    U_dm(
         .clk(clk),           // 输入：CPU时钟
         .DMWr(MemWrite),     // 输入：RAM写使能
         .DMType(DMType),      // 输入：内存访问类型
         .addr(dm_addr),      // 输入：RAM地址（完整32位地址）
         .din(dm_din),        // 输入：写入RAM的数据
         .dout(dm_dout)       // 输出：从RAM读出的数据
         );
         
  // 实例化ROM IP核（dist_mem_gen_0）
   dist_mem_gen_0 U_ROM ( 
      .a(PC[8:2]),     // 输入：ROM地址（7位）
      .spo(instr)      // 输出：指令（32位）
   );
   
   assign debug_data = debug_data_wire;
        
endmodule

