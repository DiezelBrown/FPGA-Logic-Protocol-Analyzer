module input_sampler_tb;

    reg clk;
    reg signal_in;
    wire sampled_signal;
    input_sampler uut(
        .clk(clk),
        .signal_in(signal_in),
        .sampled_signal(sampled_signal)
    );
    initial begin
        clk = 0;
        signal_in = 0;
    end
    
    initial begin
        #8 signal_in = 1; // Set signal_in to 1 at time 8ns
        #10 signal_in = 0;
        #20 $finish;
    end
    
    initial begin
        $dumpfile("input_sampler.vcd");
        $dumpvars(0, input_sampler_tb);
    end

    always #5 clk = ~clk; //every 5ns flip the clock

endmodule 