
`timescale 1ns / 1ps

module uart #(
    parameter WORD_LEN = 8,
    parameter XTAL_CLK = 50_000_000,
    parameter BAUD_RATE = 2400
)(
    input wire sys_clk,
    input wire sys_rst_l,
    input wire xmitH,
    input wire [WORD_LEN-1:0] xmit_data,
    input wire uart_rx,
    output wire xmit_doneH,
    output wire xmit_active,
    output wire [WORD_LEN-1:0] rec_dataH,
    output wire rec_busy,
    output wire rec_readyH,
    output wire uart_tx
);

wire baud_16_clk;

u_baud #(
    .XTAL_CLK(XTAL_CLK),
    .baud_rate(BAUD_RATE)
) baud_gen (
    .sys_clk(sys_clk),
    .sys_rst_l(sys_rst_l),
    .baud_16_clk(baud_16_clk)
);

u_xmit #(
    .WORD_LEN(WORD_LEN)
) transmitter (
    .sys_rst_l(sys_rst_l),
    .xmitH(xmitH),
    .xmit_data(xmit_data),
    .baud_16_clk(baud_16_clk),
    .uart_XMIT_dataH(uart_tx),
    .xmit_doneH(xmit_doneH),
    .xmit_active(xmit_active)
);

u_rec #(
    .WORD_LEN(WORD_LEN)
) receiver (
    .sys_rst_l(sys_rst_l),
    .baud_16_clk(baud_16_clk),
    .uart_REC_dataH(uart_rx),
    .rec_dataH(rec_dataH),
    .rec_busy(rec_busy),
    .rec_readyH(rec_readyH)
);

endmodule

