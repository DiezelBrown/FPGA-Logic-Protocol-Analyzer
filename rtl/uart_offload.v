
module uart_offload (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [16:0] start_address,

    input wire [7:0] read_data,
    output reg [16:0] read_address,

    output reg uart_start,
    output reg [7:0] uart_data,
    input wire uart_busy,
    input wire uart_done,

    output reg busy,
    output reg done
);

    localparam IDLE      = 3'd0;
    localparam READ_WAIT = 3'd1;
    localparam LOAD      = 3'd2;
    localparam SEND      = 3'd3;
    localparam WAIT_UART = 3'd4;
    localparam COMPLETE  = 3'd5;

    reg [2:0] state;
    reg [17:0] sample_count;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            read_address <= 0;
            uart_start <= 0;
            uart_data <= 0;
            sample_count <= 0;
            busy <= 0;
            done <= 0;
        end else begin
            uart_start <= 0;
            done <= 0;

            case (state)
                IDLE: begin
                    busy <= 0;

                    if (start) begin
                        read_address <= start_address;
                        sample_count <= 0;
                        busy <= 1;
                        state <= READ_WAIT;
                    end
                end

                READ_WAIT: begin
                    // BRAM reads data on a clock edge.
                    state <= LOAD;
                end

                LOAD: begin
                    uart_data <= read_data;
                    state <= SEND;
                end

                SEND: begin
                    if (!uart_busy) begin
                        uart_start <= 1;
                        state <= WAIT_UART;
                    end
                end

                WAIT_UART: begin
                    if (uart_done) begin
                        if (sample_count == 18'd131071) begin
                            state <= COMPLETE;
                        end else begin
                            sample_count <= sample_count + 1;
                            read_address <= read_address + 1;
                            state <= READ_WAIT;
                        end
                    end
                end

                COMPLETE: begin
                    busy <= 0;
                    done <= 1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
