module logic_analyzer_top
(
    input clk,
    input rst,
    input [7:0] signal_in,
    input [2:0] sample_rate, // 3-bit input to select sample rate
    output [7:0] sampled_signal
);
    wire sample_enable;
    sample_controller controller (
        .clk(clk),
        .rst(rst),
        .sample_rate(sample_rate),
        .sample_enable(sample_enable)
    );
    input_sampler sampler (
        .clk(clk),
        .signal_in(signal_in),
        .sample_enable(sample_enable),
        .sampled_signal(sampled_signal)
    );
endmodule  
