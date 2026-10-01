module logic_analyzer_top_tb;

    reg clk;
    reg rst;
    reg [2:0] sample_rate;
    reg [7:0] signal_in;

    wire [7:0] sampled_signal;

    logic_analyzer_top uut (
        .clk(clk),
        .rst(rst),
        .sample_rate(sample_rate),
        .signal_in(signal_in),
        .sampled_signal(sampled_signal)
    );

    initial begin
        clk = 0;
        rst = 1;
        sample_rate = 3'b010; // 25 MS/s
        signal_in = 8'b00000000;

        #20 rst = 0;
    end

    always #5 clk = ~clk;

 initial begin
    #20;

    // Set first value well before a capture
    @(negedge clk);
    signal_in = 8'hAA;

    // Wait until first buffer write actually occurs
    wait(uut.buffer.write_address == 1);

    @(negedge clk);
    signal_in = 8'hF0;
    wait(uut.buffer.write_address == 2);

    @(negedge clk);
    signal_in = 8'h0F;
    wait(uut.buffer.write_address == 3);

    @(negedge clk);
    signal_in = 8'hCC;
    wait(uut.buffer.write_address == 4);

    #1;

    $display("buffer[0] = %h", uut.buffer.buffer[0]);
    $display("buffer[1] = %h", uut.buffer.buffer[1]);
    $display("buffer[2] = %h", uut.buffer.buffer[2]);
    $display("buffer[3] = %h", uut.buffer.buffer[3]);

    $finish;
end
    initial begin
        $dumpfile("logic_analyzer_top.vcd");
        $dumpvars(0, logic_analyzer_top_tb);
    end

endmodule