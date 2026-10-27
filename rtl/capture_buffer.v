module capture_buffer (
    input clk,
    input [7:0] sampled_data,
    input capture_enable,
    input rst,
    input [16:0] read_address,

    output reg [7:0] read_data,
    output wire [16:0] current_write_address
);

    // Address of the next sample to be written into BRAM
    // 17 bits allow 131,072 addresses (0 through 131071)
    reg [16:0] write_address;

    // 128K x 8-bit capture memory
    reg [7:0] buffer [0:131071];

    // Expose the next write address to the capture controller
    assign current_write_address = write_address;

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

    // Synchronous read: output updates on a rising clock edge
    always @(posedge clk) begin
        read_data <= buffer[read_address];
    end

endmodule