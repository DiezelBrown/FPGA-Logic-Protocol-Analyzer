module input_sampler (
    
    input clk,
    input signal_in,
    output reg sampled_signal
);

always @(posedge clk) begin
    sampled_signal <= signal_in;
end

endmodule