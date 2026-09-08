module input_sampler_tb;

    reg clk;
    reg [7:0] signal_in;
    wire [7:0] sampled_signal;
    input_sampler uut(
        .clk(clk),
        .signal_in(signal_in),
        .sampled_signal(sampled_signal)
    );
    initial begin
        clk = 0;
        signal_in = 8'b00000000;
    end
    
    initial begin
        #8 signal_in = 8'b10101010; // Set signal_in to 8'b10101010 at time 8ns
        #10 signal_in = 8'b11001100; // Set signal_in to 8'b11001100 at time 18ns
        #10 signal_in = 8'b00001111; // Set signal_in to 8'b00001111 at time 28ns
        #20 $finish;
    end
    
    initial begin
        $dumpfile("input_sampler.vcd");
        $dumpvars(0, input_sampler_tb);
    end

    always #5 clk = ~clk; //every 5ns flip the clock

endmodule 