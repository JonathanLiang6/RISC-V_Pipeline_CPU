// RISC-V 单周期CPU测试台 - 用于仿真验证
module sccomp_tb();
    
   reg  clk, rstn;         // 时钟和复位信号
   reg  [4:0] reg_sel;     // 寄存器选择
   wire [31:0] reg_data;   // 寄存器数据
    
   // ==================== 单周期CPU实例化 ====================
   sccomp U_SCCOMP(
      .clk(clk), .rstn(rstn), .reg_sel(reg_sel), .reg_data(reg_data) 
   );

   integer foutput;        // 输出文件句柄
   integer counter = 0;    // 计数器
   integer max_cycles = 2000; // 最大仿真周期数
   
   // ==================== 初始化过程 ====================
   initial begin
      // 加载指令到指令内存
      $readmemh("Test_All_RV32I.dat", U_SCCOMP.U_IM.ROM);
      
      // 打开结果输出文件
      foutput = $fopen("results.txt");
      
      // 初始化信号
      clk = 1;
      rstn = 1;
      
      // 复位序列
      #5;
      rstn = 0;            // 激活复位
      #20;
      rstn = 1;            // 释放复位
      
      // 运行仿真
      #1000;
      reg_sel = 7;         // 选择寄存器x7进行观察
   end
   
   // ==================== 时钟生成和监控 ====================
   always begin
      #(50) clk = ~clk;    // 生成50个时间单位的时钟周期
	   
      if (clk == 1'b1) begin
         // 检查仿真结束条件
         if ((counter >= max_cycles) || (U_SCCOMP.U_SCPU.PC_out === 32'hxxxxxxxx)) begin
            $fclose(foutput);
            $display("仿真结束：计数器 = %d, PC = %h", counter, U_SCCOMP.U_SCPU.PC_out);
            $stop;
         end
         else begin
            // 在特定PC地址记录寄存器状态
            if (U_SCCOMP.PC == 32'h00000048) begin
               counter = counter + 1;
               
               // 记录当前状态到文件
               $fdisplay(foutput, "=== 仿真状态记录 ===");
               $fdisplay(foutput, "PC:\t\t %h", U_SCCOMP.PC);
               $fdisplay(foutput, "指令:\t\t %h", U_SCCOMP.instr);
               $fdisplay(foutput, "寄存器x00-x03:\t %h %h %h %h", 0, U_SCCOMP.U_SCPU.U_RF.rf[1], U_SCCOMP.U_SCPU.U_RF.rf[2], U_SCCOMP.U_SCPU.U_RF.rf[3]);
               $fdisplay(foutput, "寄存器x04-x07:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[4], U_SCCOMP.U_SCPU.U_RF.rf[5], U_SCCOMP.U_SCPU.U_RF.rf[6], U_SCCOMP.U_SCPU.U_RF.rf[7]);
               $fdisplay(foutput, "寄存器x08-x11:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[8], U_SCCOMP.U_SCPU.U_RF.rf[9], U_SCCOMP.U_SCPU.U_RF.rf[10], U_SCCOMP.U_SCPU.U_RF.rf[11]);
               $fdisplay(foutput, "寄存器x12-x15:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[12], U_SCCOMP.U_SCPU.U_RF.rf[13], U_SCCOMP.U_SCPU.U_RF.rf[14], U_SCCOMP.U_SCPU.U_RF.rf[15]);
               $fdisplay(foutput, "寄存器x16-x19:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[16], U_SCCOMP.U_SCPU.U_RF.rf[17], U_SCCOMP.U_SCPU.U_RF.rf[18], U_SCCOMP.U_SCPU.U_RF.rf[19]);
               $fdisplay(foutput, "寄存器x20-x23:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[20], U_SCCOMP.U_SCPU.U_RF.rf[21], U_SCCOMP.U_SCPU.U_RF.rf[22], U_SCCOMP.U_SCPU.U_RF.rf[23]);
               $fdisplay(foutput, "寄存器x24-x27:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[24], U_SCCOMP.U_SCPU.U_RF.rf[25], U_SCCOMP.U_SCPU.U_RF.rf[26], U_SCCOMP.U_SCPU.U_RF.rf[27]);
               $fdisplay(foutput, "寄存器x28-x31:\t %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[28], U_SCCOMP.U_SCPU.U_RF.rf[29], U_SCCOMP.U_SCPU.U_RF.rf[30], U_SCCOMP.U_SCPU.U_RF.rf[31]);
               $fdisplay(foutput, "==================");
               
               $fclose(foutput);
               $stop;
            end
            else begin
               counter = counter + 1;
               
               // 可选：显示调试信息
               // $display("PC: %h, 指令: %h", U_SCCOMP.U_SCPU.PC_out, U_SCCOMP.instr);
            end
         end
      end
   end // end always
   
endmodule
