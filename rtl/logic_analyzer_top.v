module logic_analyzer_top
(
    input clk,
    input rst,
    input [7:0] signal_in,
    input [2:0] sample_rate, // 3-bit input to select sample rate
    output [7:0] sampled_signal
);
    //Pulses for one clock cycle whenever a sample should be captured
    wire sample_enable;

    // Generates sample_enable based on the selected sampling rate
    sample_controller controller (
        .clk(clk),
        .rst(rst),
        .sample_rate(sample_rate),
        .sample_enable(sample_enable)
    );
    // Captures the current state of all 8 digital input channels
    input_sampler sampler (
        .clk(clk),
        .signal_in(signal_in),
        .sample_enable(sample_enable),
        .sampled_signal(sampled_signal)
    );
    // Stores consecutive 8-bit samples in the capture buffer
    capture_buffer buffer(
        .clk(clk),
        .rst(rst),
        .capture_enable(sample_enable),
        .sampled_data(signal_in)
    );
endmodule
