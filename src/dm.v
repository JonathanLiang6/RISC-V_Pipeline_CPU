// 数据内存模块 - 支持字节、半字、字访问
// 支持有符号和无符号加载操作
module dm(clk, DMWr, DMType, addr, din, dout);
   input          clk;        // 时钟信号
   input          DMWr;       // 内存写使能
   input  [2:0]   DMType;     // 内存访问类型
   input  [8:2]   addr;       // 内存地址
   input  [31:0]  din;        // 写入数据
   output [31:0]  dout;       // 读出数据
     
   reg [31:0] dmem[127:0];    // 数据内存数组
   reg [31:0] read_data;      // 读取的数据
   reg [31:0] write_data;     // 写入的数据
   
   // 内存写操作
   always @(posedge clk) begin
      if (DMWr) begin
         case (DMType)
            `dm_word: begin
               // 字存储（32位）
               dmem[addr[8:2]] <= din;
               $display("dmem[0x%8X] = 0x%8X (WORD)", addr << 2, din);
            end
            `dm_halfword: begin
               // 半字存储（16位）
               dmem[addr[8:2]][15:0] <= din[15:0];
               $display("dmem[0x%8X] = 0x%4X (HALFWORD)", addr << 2, din[15:0]);
            end
            `dm_byte: begin
               // 字节存储（8位）
               case (addr[1:0])
                  2'b00: dmem[addr[8:2]][7:0] <= din[7:0];
                  2'b01: dmem[addr[8:2]][15:8] <= din[7:0];
                  2'b10: dmem[addr[8:2]][23:16] <= din[7:0];
                  2'b11: dmem[addr[8:2]][31:24] <= din[7:0];
               endcase
               $display("dmem[0x%8X] = 0x%2X (BYTE)", addr << 2, din[7:0]);
            end
            default: begin
               dmem[addr[8:2]] <= din;
               $display("dmem[0x%8X] = 0x%8X (DEFAULT)", addr << 2, din);
            end
         endcase
      end
   end
   
   // 内存读操作
   always @(*) begin
      case (DMType)
         `dm_word: begin
            // 字加载（32位）
            read_data = dmem[addr[8:2]];
         end
         `dm_halfword: begin
            // 半字加载（16位）- 有符号扩展
            read_data = {{16{dmem[addr[8:2]][15]}}, dmem[addr[8:2]][15:0]};
         end
         `dm_halfword_unsigned: begin
            // 半字加载（16位）- 无符号扩展
            read_data = {16'b0, dmem[addr[8:2]][15:0]};
         end
         `dm_byte: begin
            // 字节加载（8位）- 有符号扩展
            case (addr[1:0])
               2'b00: read_data = {{24{dmem[addr[8:2]][7]}}, dmem[addr[8:2]][7:0]};
               2'b01: read_data = {{24{dmem[addr[8:2]][15]}}, dmem[addr[8:2]][15:8]};
               2'b10: read_data = {{24{dmem[addr[8:2]][23]}}, dmem[addr[8:2]][23:16]};
               2'b11: read_data = {{24{dmem[addr[8:2]][31]}}, dmem[addr[8:2]][31:24]};
            endcase
         end
         `dm_byte_unsigned: begin
            // 字节加载（8位）- 无符号扩展
            case (addr[1:0])
               2'b00: read_data = {24'b0, dmem[addr[8:2]][7:0]};
               2'b01: read_data = {24'b0, dmem[addr[8:2]][15:8]};
               2'b10: read_data = {24'b0, dmem[addr[8:2]][23:16]};
               2'b11: read_data = {24'b0, dmem[addr[8:2]][31:24]};
            endcase
         end
         default: begin
            read_data = dmem[addr[8:2]];
         end
      endcase
   end
   
   assign dout = read_data;
    
endmodule    
