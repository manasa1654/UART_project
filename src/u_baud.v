`timescale 1ns /1ps
module u_baud #(parameter XTAL_CLK=50_000_000,parameter baud_rate=2400)(
input  sys_clk,
input sys_rst_l,
output reg baud_16_clk);

localparam integer CLK_DIV =
                XTAL_CLK / (baud_rate * 16 * 2); 
localparam integer CW=$clog2(CLK_DIV);
reg [CW-1:0] count;
always@(posedge sys_clk or negedge sys_rst_l) begin
 if (!sys_rst_l) begin
   baud_16_clk<=0;
   count<=0;
   end
  else if(count==CLK_DIV-1) begin
   count <=0;
   baud_16_clk<=~baud_16_clk;
   end
   
   else begin
   count<=count+1;
   end
   end
endmodule
