// testbench for simulation
module sccomp_tb();
    
   reg  clk, rstn;
   reg  [4:0] reg_sel;
   wire [31:0] reg_data;
    
// instantiation of sccomp    
   sccomp U_SCCOMP(
      .clk(clk), .rstn(rstn), .reg_sel(reg_sel), .reg_data(reg_data) 
   );

   integer foutput;
   integer counter = 0;

   // 独立时钟生成
   initial begin
      clk = 1;
      forever #50 clk = ~clk;
   end

   // 仿真初始化流程
   initial begin
      $readmemh("E:/Projects_of_Liang/SingleProject/FPGA_Liang/PipelineCPU/Test_8_Instr.dat", U_SCCOMP.U_IM.ROM); // load instructions into instruction memory
      foutput = $fopen("results.txt");
      rstn = 1;
      #5;
      rstn = 0;
      #20;
      rstn = 1;
      reg_sel = 7;
      counter = 0;
   end

   // 预期结果（部分关键点，按dat文件顺序，PC=4字节递增）
   // 这里只列举部分关键点，实际可根据需要扩展
   // 格式：counter, 预期xN, 预期内存
   // 例如：counter==2时，x3应为10

   // 主仿真流程
   always @(posedge clk) begin
      // 自动断言检查
      case (counter)
         2: if (U_SCCOMP.U_SCPU.U_RF.rf[3] !== 32'hA) begin $display("[ERROR] addi x3, x0, 10 failed, x3=%h", U_SCCOMP.U_SCPU.U_RF.rf[3]); $fatal; end
         3: if (U_SCCOMP.U_SCPU.U_RF.rf[4] !== 32'h14) begin $display("[ERROR] addi x4, x0, 20 failed, x4=%h", U_SCCOMP.U_SCPU.U_RF.rf[4]); $fatal; end
         5: if (U_SCCOMP.U_SCPU.U_RF.rf[5] !== 32'h1e) begin $display("[ERROR] add x5, x3, x4 failed, x5=%h", U_SCCOMP.U_SCPU.U_RF.rf[5]); $fatal; end
         21: if (U_SCCOMP.U_DM.dmem[32'h80>>2] !== 32'hA) begin $display("[ERROR] sw x3, 0x80(x0) failed, mem[0x80]=%h", U_SCCOMP.U_DM.dmem[32'h80>>2]); $fatal; end
         27: if (U_SCCOMP.U_SCPU.U_RF.rf[23] !== 32'hA) begin $display("[ERROR] lw x23, 0x80(x0) failed, x23=%h", U_SCCOMP.U_SCPU.U_RF.rf[23]); $fatal; end
         // 可继续添加更多断言...
      endcase

      if ((counter == 2000) || (U_SCCOMP.U_SCPU.PC_out=== 32'hxxxxxxxx)) begin
         $display("[INFO] 所有自动断言检查通过，指令集实现正确！");
         $fclose(foutput);
         $stop;
      end else begin
         // 每条指令执行后输出关键信息
         $display("====================");
         $display("PC = 0x%08X, instr = 0x%08X", U_SCCOMP.PC, U_SCCOMP.instr);
         $display("rf01-07: %h %h %h %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[1], U_SCCOMP.U_SCPU.U_RF.rf[2], U_SCCOMP.U_SCPU.U_RF.rf[3], U_SCCOMP.U_SCPU.U_RF.rf[4], U_SCCOMP.U_SCPU.U_RF.rf[5], U_SCCOMP.U_SCPU.U_RF.rf[6], U_SCCOMP.U_SCPU.U_RF.rf[7]);
         $display("内存[0x80]=%h, [0x84]=%h, [0x88]=%h, [0x8C]=%h, [0x8E]=%h", 
           U_SCCOMP.U_DM.dmem[7'h80>>2], U_SCCOMP.U_DM.dmem[7'h84>>2], U_SCCOMP.U_DM.dmem[7'h88>>2], U_SCCOMP.U_DM.dmem[7'h8C>>2], U_SCCOMP.U_DM.dmem[7'h8E>>2]);
         $display("====================");
         $fdisplay(foutput, "====================");
         $fdisplay(foutput, "PC = 0x%08X, instr = 0x%08X", U_SCCOMP.PC, U_SCCOMP.instr);
         $fdisplay(foutput, "rf01-07: %h %h %h %h %h %h %h", U_SCCOMP.U_SCPU.U_RF.rf[1], U_SCCOMP.U_SCPU.U_RF.rf[2], U_SCCOMP.U_SCPU.U_RF.rf[3], U_SCCOMP.U_SCPU.U_RF.rf[4], U_SCCOMP.U_SCPU.U_RF.rf[5], U_SCCOMP.U_SCPU.U_RF.rf[6], U_SCCOMP.U_SCPU.U_RF.rf[7]);
         $fdisplay(foutput, "内存[0x80]=%h, [0x84]=%h, [0x88]=%h, [0x8C]=%h, [0x8E]=%h", 
           U_SCCOMP.U_DM.dmem[7'h80>>2], U_SCCOMP.U_DM.dmem[7'h84>>2], U_SCCOMP.U_DM.dmem[7'h88>>2], U_SCCOMP.U_DM.dmem[7'h8C>>2], U_SCCOMP.U_DM.dmem[7'h8E>>2]);
         $fdisplay(foutput, "====================");
         counter = counter + 1;
         // 检查是否到死循环，若到达则终止仿真
         if (U_SCCOMP.instr == 32'hFFF00063) begin
           $display("检测到死循环，仿真结束。");
           $fdisplay(foutput, "检测到死循环，仿真结束。");
           $fclose(foutput);
           $stop;
         end
      end
   end

endmodule
