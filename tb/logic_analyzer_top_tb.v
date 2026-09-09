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
        #25 signal_in = 8'b10101010;
        #10 signal_in = 8'b11110000;
        #10 signal_in = 8'b00001111;
        #10 signal_in = 8'b11001100;
        #100 $finish;
    end

    initial begin
        $dumpfile("logic_analyzer_top.vcd");
        $dumpvars(0, logic_analyzer_top_tb);
    end

endmodule