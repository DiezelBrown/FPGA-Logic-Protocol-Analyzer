module capture_buffer_tb;

    reg clk;
    reg rst;
    reg capture_enable;
    reg [7:0] sampled_data;
    reg [16:0] read_address;
    wire [7:0] read_data;

    // Instantiate the capture buffer
    capture_buffer uut (
        .clk(clk),
        .rst(rst),
        .capture_enable(capture_enable),
        .sampled_data(sampled_data),
        .read_address(read_address),
        .read_data(read_data)
    );

    // Generate 100 MHz clock
    always #5 clk = ~clk;

    // Test sequence
    initial begin
    // Initialize signals
    clk = 0;
    rst = 1;
    capture_enable = 0;
    sampled_data = 8'h00;
    read_address = 17'd0;

    // Reset the write address
    #20;
    rst = 0;

    // Begin capturing samples
    capture_enable = 1;

    // Write AA
    sampled_data = 8'hAA;
    @(posedge clk);
    #1;

    // Write F0
    sampled_data = 8'hF0;
    @(posedge clk);
    #1;

    // Write 0F
    sampled_data = 8'h0F;
    @(posedge clk);
    #1;

    // Write CC
    sampled_data = 8'hCC;
    @(posedge clk);
    #1;

    // Stop writing to the buffer
    capture_enable = 0;

    // Read address 0
    read_address = 17'd0;
    @(posedge clk);
    #1;
    $display("read_address 0 = %h", read_data);

    // Read address 1
    read_address = 17'd1;
    @(posedge clk);
    #1;
    $display("read_address 1 = %h", read_data);

    // Read address 2
    read_address = 17'd2;
    @(posedge clk);
    #1;
    $display("read_address 2 = %h", read_data);

    // Read address 3
    read_address = 17'd3;
    @(posedge clk);
    #1;
    $display("read_address 3 = %h", read_data);

    $finish;
end

    // Generate waveform file
    initial begin
    $dumpfile("capture_buffer.vcd");
    $dumpvars(0, capture_buffer_tb);

    $dumpvars(0, uut.buffer[0]);
    $dumpvars(0, uut.buffer[1]);
    $dumpvars(0, uut.buffer[2]);
    $dumpvars(0, uut.buffer[3]);
    $dumpvars(0, uut.buffer[4]);
end
endmodule