`timescale 1ns/1ps

module trigger_engine_tb;

    reg clk = 0;
    reg rst = 1;
    reg sample_enable = 0;
    reg [7:0] signal_in = 0;
    reg [2:0] trigger_channel = 3'd3;
    reg trigger_edge = 0;
    reg trigger_mode = 0;
    reg [7:0] trigger_pattern = 0;
    reg [7:0] trigger_mask = 8'hFF;

    wire trigger_detected;

    trigger_engine uut (
        .clk(clk),
        .rst(rst),
        .sample_enable(sample_enable),
        .signal_in(signal_in),
        .trigger_channel(trigger_channel),
        .trigger_edge(trigger_edge),
        .trigger_detected(trigger_detected),
        .trigger_mode(trigger_mode),
        .trigger_pattern(trigger_pattern),
        .trigger_mask(trigger_mask)
    );

    always #5 clk = ~clk;

    task take_sample;
        input [7:0] value;
        begin
            @(negedge clk);
            signal_in = value;
            sample_enable = 1;

            @(posedge clk);
            #1;
            $display(
                "Time=%0t Data=%b Trigger=%b",
                $time, signal_in, trigger_detected
            );

            @(negedge clk);
            sample_enable = 0;
        end
    endtask

    initial begin
        $dumpfile("sim/trigger_engine.vcd");
        $dumpvars(0, trigger_engine_tb);

        // Release reset
        @(negedge clk);
        rst = 0;

        $display("TEST 1: Rising edge on channel 3");

        take_sample(8'b00000000);
        take_sample(8'b00000000);
        take_sample(8'b00001000);
        take_sample(8'b00001000);

        // Reset and test falling edge
        @(negedge clk);
        rst = 1;
        trigger_edge = 1;

        @(negedge clk);
        rst = 0;

        $display("TEST 2: Falling edge on channel 3");

        take_sample(8'b00001000);
        take_sample(8'b00000000);
        take_sample(8'b00000000);

        // Reset before pattern test
        @(negedge clk);
        rst = 1;

        trigger_mode = 1;
        trigger_pattern = 8'b10100110;
        trigger_mask = 8'b11111111;

        @(negedge clk);
        rst = 0;

        $display("TEST 3: Pattern triggering");

        take_sample(8'b00000000);
        take_sample(8'b10100100);
        take_sample(8'b10100110);
        take_sample(8'b00000000);

        // TEST 4: Masked pattern triggering
        @(negedge clk);
        rst = 1;

        trigger_mode = 1;
        trigger_pattern = 8'b10100110;
        trigger_mask = 8'b11110000;

        @(negedge clk);
        rst = 0;

        $display("TEST 4: Masked pattern triggering");

        take_sample(8'b00000110); // No match
        take_sample(8'b10101111); // Match
        take_sample(8'b10100000); // Match
        take_sample(8'b11100110); // No match

        $finish;
    end

endmodule