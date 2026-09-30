module capture_buffer_tb;

    reg clk;
    reg rst;
    reg capture_enable;
    reg [7:0] sampled_signal;

    // Instantiate the capture buffer
    capture_buffer uut (
        .clk(clk),
        .rst(rst),
        .capture_enable(capture_enable),
        .sampled_signal(sampled_signal)
    );

    // Generate 100 MHz clock
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        clk = 0;
        rst = 1;
        capture_enable = 0;
        sampled_signal = 8'h00;

        // Reset
        #20;
        rst = 0;

        // Begin capturing
        capture_enable = 1;

        #10 sampled_signal = 8'hAA;
        #10 sampled_signal = 8'hF0;
        #10 sampled_signal = 8'h0F;
        #10 sampled_signal = 8'hCC;

        // Stop capturing
        #10 capture_enable = 0;

        #20;

        $display("buffer[0] = %h", uut.buffer[0]);
        $display("buffer[1] = %h", uut.buffer[1]);
        $display("buffer[2] = %h", uut.buffer[2]);
        $display("buffer[3] = %h", uut.buffer[3]);
        $display("buffer[4] = %h", uut.buffer[4]);

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