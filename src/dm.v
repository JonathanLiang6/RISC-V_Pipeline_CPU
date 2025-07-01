// 数据内存模块 - 支持字节、半字、字访问
module dm(clk, DMWr, addr, din, dout, DMType);
   input          clk;      // 时钟信号
   input          DMWr;     // 数据内存写使能
   input  [31:0]  addr;     // 32位地址输入
   input  [31:0]  din;      // 32位数据输入
   output [31:0]  dout;     // 32位数据输出
   input  [2:0]   DMType;   // 数据内存访问类型控制信号
     
   reg [31:0] dmem[127:0];  // 128个字，总共512字节的数据内存
   
   // 计算字地址和字节偏移
   wire [6:0] word_addr = addr[8:2];   // 内存数组的索引（字地址）
   wire [1:0] byte_offset = addr[1:0]; // 字内的字节偏移
   
   // 写操作逻辑
   always @(posedge clk) begin
      if (DMWr) begin
         case (DMType)
             3'b010: begin // 字访问 (LW, SW)
                 dmem[word_addr] <= din;
                 $display("dmem[0x%8X] = 0x%8X (字访问)", addr, din);
             end
             3'b001: begin // 半字访问 (LH, SH)
                 case (byte_offset)
                     2'b00: dmem[word_addr][15:0]  <= din[15:0];
                     2'b10: dmem[word_addr][31:16] <= din[15:0];
                     default: $display("警告: 未对齐的半字写入地址 0x%h", addr);
                 endcase
                 $display("dmem[0x%8X] = 0x%4X (半字访问)", addr, din[15:0]);
             end
             3'b000: begin // 字节访问 (LB, SB)
                 case (byte_offset)
                     2'b00: dmem[word_addr][7:0]   <= din[7:0];
                     2'b01: dmem[word_addr][15:8]  <= din[7:0];
                     2'b10: dmem[word_addr][23:16] <= din[7:0];
                     2'b11: dmem[word_addr][31:24] <= din[7:0];
                 endcase
                 $display("dmem[0x%8X] = 0x%2X (字节访问)", addr, din[7:0]);
             end
             default: $display("错误: 无效的DMType写入地址 0x%h", addr);
         endcase
      end
   end
   
   // 读操作逻辑 (组合逻辑)
   reg [31:0] dout_reg;
   assign dout = dout_reg;
   
   always @(*) begin
       case (DMType)
           3'b010: dout_reg = dmem[word_addr]; // 字访问 (LW, SW)
           3'b001: begin // 半字访问 (LH) - 符号扩展
               case (byte_offset)
                   2'b00: dout_reg = {{16{dmem[word_addr][15]}}, dmem[word_addr][15:0]}; // 符号扩展
                   2'b10: dout_reg = {{16{dmem[word_addr][31]}}, dmem[word_addr][31:16]}; // 符号扩展
                   default: dout_reg = 32'hX; // 未对齐访问或错误
               endcase
           end
           3'b000: begin // 字节访问 (LB) - 符号扩展
               case (byte_offset)
                   2'b00: dout_reg = {{24{dmem[word_addr][7]}}, dmem[word_addr][7:0]};   // 符号扩展
                   2'b01: dout_reg = {{24{dmem[word_addr][15]}}, dmem[word_addr][15:8]};  // 符号扩展
                   2'b10: dout_reg = {{24{dmem[word_addr][23]}}, dmem[word_addr][23:16]}; // 符号扩展
                   2'b11: dout_reg = {{24{dmem[word_addr][31]}}, dmem[word_addr][31:24]}; // 符号扩展
                   default: dout_reg = 32'hX;
               endcase
           end
           3'b101: begin // 无符号半字访问 (LHU) - 零扩展
               case (byte_offset)
                   2'b00: dout_reg = {16'h0000, dmem[word_addr][15:0]}; // 零扩展
                   2'b10: dout_reg = {16'h0000, dmem[word_addr][31:16]}; // 零扩展
                   default: dout_reg = 32'hX;
               endcase
           end
           3'b100: begin // 无符号字节访问 (LBU) - 零扩展
               case (byte_offset)
                   2'b00: dout_reg = {24'h000000, dmem[word_addr][7:0]};   // 零扩展
                   2'b01: dout_reg = {24'h000000, dmem[word_addr][15:8]};  // 零扩展
                   2'b10: dout_reg = {24'h000000, dmem[word_addr][23:16]}; // 零扩展
                   2'b11: dout_reg = {24'h000000, dmem[word_addr][31:24]}; // 零扩展
                   default: dout_reg = 32'hX;
               endcase
           end
           default: dout_reg = dmem[word_addr]; // 默认值，例如对于非内存访问
       endcase
   end
    
endmodule    
