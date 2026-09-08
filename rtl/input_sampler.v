module input_sampler (
    
    input clk,
    input [7:0] signal_in,
    output reg [7:0] sampled_signal
);

always @(posedge clk) begin
    sampled_signal <= signal_in;
end

endmodule