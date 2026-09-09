module sample_controller_tb;

    reg clk;
    reg rst;
    reg [2:0] sample_rate;
    wire sample_enable;

    sample_controller uut(
        .clk(clk),
        .rst(rst),
        .sample_rate(sample_rate),
        .sample_enable(sample_enable)
    );
    initial begin
        clk = 0;
        rst = 1;
        sample_rate = 3'b010; // 25MS/s

        #20 rst = 0; // Release reset after 20ns

        #200 sample_rate = 3'b001; // 50 MS/s
        #200 sample_rate = 3'b010; // 25 MS/s
        #200 sample_rate = 3'b011; // 10 MS/s
        #300 sample_rate = 3'b100; // 5 MS/s
        #500 sample_rate = 3'b101; // 1 MS/s

    end
    initial begin
        #2500 $finish; // Finish simulation after 2500ns
    end

    initial begin
        $dumpfile("sample_controller.vcd");
        $dumpvars(0, sample_controller_tb);
    end
    always #5 clk = ~clk;

endmodule