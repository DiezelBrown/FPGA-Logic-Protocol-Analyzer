module capture_buffer(
    input clk,
    input[7:0] sampled_data,
    input capture_enable,
    input rst
);
reg [3:0] write_address;
reg [7:0] buffer [15:0];

always @(posedge clk) begin
    if (rst == 1) begin
        write_address <= 0;
    end 
    else if (capture_enable) begin
        buffer[write_address] <= sampled_data;
        write_address <= write_address + 1;
    end
end

    
endmodule