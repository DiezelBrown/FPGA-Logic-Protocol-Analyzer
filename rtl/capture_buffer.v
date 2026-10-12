module capture_buffer(
    input clk,
    input [7:0] sampled_data,
    input capture_enable,
    input rst,
    input [16:0] read_address,
    output reg [7:0] read_data
);

    // 17-bit write address supports 131,072 memory locations
    reg [16:0] write_address;

    // 128K x 8-bit capture memory
    reg [7:0] buffer [0:131071];

    // Write samples into the capture buffer
    always @(posedge clk) begin
        if (rst) begin
            write_address <= 0;
        end
        else if (capture_enable) begin
            buffer[write_address] <= sampled_data;
            write_address <= write_address + 1;
        end
    end

    // Read stored samples from the capture buffer
    always @(posedge clk) begin
        read_data <= buffer[read_address];
    end

endmodule