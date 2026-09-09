module input_sampler (
    
    input clk,
    input [7:0] signal_in,
    input sample_enable,
    output reg [7:0] sampled_signal
);

always @(posedge clk) begin
    if (sample_enable) begin
        sampled_signal <= signal_in;
end
end

endmodule