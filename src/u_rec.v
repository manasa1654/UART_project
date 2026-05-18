`timescale 1ns / 1ps

module u_rec #(
    parameter WORD_LEN = 8
)(
    input wire sys_rst_l,
    input wire baud_16_clk,
    input wire uart_REC_dataH,

    output reg [WORD_LEN-1:0] rec_dataH,
    output reg rec_busy,
    output reg rec_readyH
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;
reg [3:0] baud_count;
reg [$clog2(WORD_LEN)-1:0] bit_count;
reg [WORD_LEN-1:0] shift_reg;

reg uart_rec_sync1, uart_rec_sync2;

always @(posedge baud_16_clk or negedge sys_rst_l) begin
    if (!sys_rst_l) begin
        uart_rec_sync1 <= 1'b1;
        uart_rec_sync2 <= 1'b1;
    end
    else begin
        uart_rec_sync1 <= uart_REC_dataH;
        uart_rec_sync2 <= uart_rec_sync1;
    end
end

always @(posedge baud_16_clk or negedge sys_rst_l) begin
    if (!sys_rst_l) begin
        state       <= IDLE;
        baud_count  <= 0;
        bit_count   <= 0;
        shift_reg   <= 0;
        rec_dataH   <= 0;
        rec_busy    <= 0;
        rec_readyH  <= 0;
    end
    else begin
        rec_readyH <= 1'b0;

        case(state)

        IDLE: begin
            rec_busy <= 1'b0;
            baud_count <= 0;
            bit_count <= 0;

            if (uart_rec_sync2 == 1'b0) begin
                rec_busy <= 1'b1;
                baud_count <= 0;
                state <= START;
            end
        end

        START: begin
            rec_busy <= 1'b1;

            if (baud_count == 4'd7) begin
                if (uart_rec_sync2 == 1'b0) begin
                    baud_count <= 0;
                    bit_count <= 0;
                    state <= DATA;
                end
                else begin
                    state <= IDLE;
                end
            end
            else begin
                baud_count <= baud_count + 1'b1;
            end
        end

        DATA: begin
            rec_busy <= 1'b1;

            if (baud_count == 4'd15) begin
                baud_count <= 0;

                shift_reg <= {
                    uart_rec_sync2,
                    shift_reg[WORD_LEN-1:1]
                };

                if (bit_count == WORD_LEN-1) begin
                    rec_dataH <= {
                        uart_rec_sync2,
                        shift_reg[WORD_LEN-1:1]
                    };

                    bit_count <= 0;
                    state <= STOP;
                end
                else begin
                    bit_count <= bit_count + 1'b1;
                end
            end
            else begin
                baud_count <= baud_count + 1'b1;
            end
        end

        STOP: begin
            rec_busy <= 1'b1;

            if (baud_count == 4'd15) begin
                baud_count <= 0;

                if (uart_rec_sync2)
                    rec_readyH <= 1'b1;

                rec_busy <= 1'b0;
                state <= IDLE;
            end
            else begin
                baud_count <= baud_count + 1'b1;
            end
        end

        default: begin
            state <= IDLE;
        end

        endcase
    end
end

endmodule
