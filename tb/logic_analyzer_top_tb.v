module logic_analyzer_top_tb;

    reg clk;
    reg rst;
    reg [2:0] sample_rate;
    reg [7:0] signal_in;
    reg [16:0] read_address;
    
    wire [7:0] read_data;
    wire [7:0] sampled_signal;

    logic_analyzer_top uut (
        .clk(clk),
        .rst(rst),
        .sample_rate(sample_rate),
        .signal_in(signal_in),
        .sampled_signal(sampled_signal),
        .read_address(read_address),
        .read_data(read_data)
    );

    initial begin
        clk = 0;
        rst = 1;
        sample_rate = 3'b010; // 25 MS/s
        signal_in = 8'b00000000;
        read_address = 17'd0;

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

    read_address = 17'd0;
    @(posedge clk);
    #1;
    $display("read_address 0 = %h", read_data);

    read_address = 17'd1;
    @(posedge clk);
    #1;
    $display("read_address 1 = %h", read_data);

    read_address = 17'd2;
    @(posedge clk);
    #1;
    $display("read_address 2 = %h", read_data);

    read_address = 17'd3;
    @(posedge clk);
    #1;
    $display("read_address 3 = %h", read_data);

    $finish;
end
    initial begin
        $dumpfile("logic_analyzer_top.vcd");
        $dumpvars(0, logic_analyzer_top_tb);
    end

endmodule