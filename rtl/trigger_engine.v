//stores. the previous 8 channels, selects the channel requested by trigger_channel and compares the previous and current values
module trigger_engine (
    input clk,
    input rst,
    input sample_enable,
    input [7:0] signal_in,
    input [2:0] trigger_channel,
    input trigger_edge,
    input trigger_mode,
    input [7:0] trigger_pattern,
    input [7:0] trigger_mask,
    output reg trigger_detected
);

    reg [7:0] previous_signal;
    reg previous_valid;

    wire current_bit;
    wire previous_bit;
    wire rising_edge;
    wire falling_edge;
    wire pattern_match;


    // Select one of the 8 digital channels
    assign current_bit = signal_in[trigger_channel];
    assign previous_bit = previous_signal[trigger_channel];

    // Detect changes between consecutive samples
    assign rising_edge = ~previous_bit & current_bit;
    assign falling_edge = previous_bit & ~current_bit;

    assign pattern_match =
    ((signal_in ^ trigger_pattern) & trigger_mask) == 8'b0;

    always @(posedge clk) begin
        if (rst) begin
            previous_signal <= 8'b00000000;
            previous_valid <= 1'b0;
            trigger_detected <= 1'b0;
        end
        else begin
            trigger_detected <= 1'b0;

            if (sample_enable) begin
                previous_signal <= signal_in;

                if (trigger_mode == 1'b1) begin
                    trigger_detected <= pattern_match;
                end
                else if (previous_valid) begin
                    if (trigger_edge == 1'b0)
                        trigger_detected <= rising_edge;
                    else
                        trigger_detected <= falling_edge;
                end

                previous_valid <= 1'b1;
            end
        end
    end

endmodule