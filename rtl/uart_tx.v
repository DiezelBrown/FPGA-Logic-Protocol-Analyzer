module uart_tx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [7:0] data_in,
    output reg tx,
    output reg busy,
    output reg done
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] state;
    reg [15:0] baud_counter;
    reg [2:0] bit_index;
    reg [7:0] data_reg;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            tx <= 1'b1;
            busy <= 1'b0;
            done <= 1'b0;
            baud_counter <= 0;
            bit_index <= 0;
            data_reg <= 0;
        end else begin
            done <= 1'b0;

            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    busy <= 1'b0;
                    baud_counter <= 0;

                    if (start) begin
                        data_reg <= data_in;
                        busy <= 1'b1;
                        state <= START;
                    end
                end

                START: begin
                    tx <= 1'b0;

                    if (baud_counter == CLKS_PER_BIT - 1) begin
                        baud_counter <= 0;
                        bit_index <= 0;
                        state <= DATA;
                    end else
                        baud_counter <= baud_counter + 1;
                end

                DATA: begin
                    tx <= data_reg[bit_index];

                    if (baud_counter == CLKS_PER_BIT - 1) begin
                        baud_counter <= 0;

                        if (bit_index == 7)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;
                    end else
                        baud_counter <= baud_counter + 1;
                end

                STOP: begin
                    tx <= 1'b1;

                    if (baud_counter == CLKS_PER_BIT - 1) begin
                        baud_counter <= 0;
                        busy <= 1'b0;
                        done <= 1'b1;
                        state <= IDLE;
                    end else
                        baud_counter <= baud_counter + 1;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
