`timescale 1ns / 1ps

module u_xmit #(parameter WORD_LEN=8)
( 
input wire sys_rst_l,
input wire xmitH,
input wire [WORD_LEN-1:0] xmit_dataH,
input wire baud_16_clk,
output reg uart_XMIT_dataH,
output reg xmit_doneH,
output reg xmit_active 
); 

reg [WORD_LEN-1:0] shift_reg;
reg [($clog2(WORD_LEN)-1):0] bit_count;
reg [3:0] baud_count;
reg [3:0] done_count;

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;

always @(posedge baud_16_clk or negedge sys_rst_l)
begin
if(!sys_rst_l)
begin
uart_XMIT_dataH <= 1'b1;
xmit_doneH <= 1'b0;
xmit_active <= 1'b0;        
baud_count <= 0;
done_count <= 0;
shift_reg <= 0;
bit_count <= 0;
state <= IDLE;
end  

else
begin

if (done_count != 0)
begin
done_count <= done_count - 1'b1;
xmit_doneH <= 1'b1;
xmit_active <= 1'b1;
end
else
begin
xmit_doneH <= 1'b0;
end

case(state)

IDLE:
begin
 uart_XMIT_dataH<=1'b1;

 if(done_count == 0)
 xmit_active<=1'b0;

 if(xmitH)
 begin
    shift_reg <= xmit_dataH;
    bit_count<=0;
    baud_count <= 0;
    xmit_active<=1'b1;
    state <= START;
 end
end

START:
begin
uart_XMIT_dataH<=1'b0;
baud_count <= baud_count + 1;

if(baud_count == 4'd15)
begin
    baud_count <= 0;
    state<=DATA;
end
end

DATA:
begin
uart_XMIT_dataH <= shift_reg[0];
baud_count <= baud_count + 1;

if(baud_count == 4'd15)
begin
    baud_count <= 0;
    shift_reg <= shift_reg>>1;

    if(bit_count == WORD_LEN-1)
    begin
      bit_count<= 0;
      state <= STOP;
    end
    else
      bit_count <= bit_count+1;
end
end

STOP:
begin
uart_XMIT_dataH <= 1'b1;
baud_count <= baud_count + 1;

if(baud_count == 4'd15)
begin
    baud_count <= 0;
    done_count <= 4'd15;
    state <= IDLE;
end
end

endcase
end
end

endmodule
