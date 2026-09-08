module sample_controller_tb;

    reg clk;
    reg rst;
    wire sample_enable;

    sample_controller uut(
        .clk(clk),
        .rst(rst),
        .sample_enable(sample_enable)
    );
    initial begin
        clk = 0;
        rst = 1;
        #20 rst = 0; // Release reset after 20ns
    end
    initial begin
        #350 $finish; // Finish simulation after 350ns
    end

    initial begin
        $dumpfile("sample_controller.vcd");
        $dumpvars(0, sample_controller_tb);
    end
    always #5 clk = ~clk;

endmodule