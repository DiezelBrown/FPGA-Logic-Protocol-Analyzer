`timescale 1ns/1ps

module capture_fsm_tb;

    // Testbench inputs
    reg clk = 0;
    reg rst = 1;
    reg start_capture = 0;
    reg sample_enable = 0;
    reg trigger_detected = 0;

    // Use 4 pre-trigger samples for this test
    reg [16:0] pre_trigger_count = 17'd4;

    // Outputs from capture FSM
    wire capture_enable;
    wire capture_done;
    wire [1:0] state;

    // Instantiate the capture FSM
    capture_fsm uut (
        .clk(clk),
        .rst(rst),
        .start_capture(start_capture),
        .sample_enable(sample_enable),
        .trigger_detected(trigger_detected),
        .pre_trigger_count(pre_trigger_count),
        .capture_enable(capture_enable),
        .capture_done(capture_done),
        .state(state)
    );

    // Generate a 100 MHz clock (10 ns period)
    always #5 clk = ~clk;

    // Generate one sample_enable pulse
    task take_sample;
        begin
            @(negedge clk);
            sample_enable = 1;

            @(posedge clk);
            #1;

            $display(
                "Time=%0t State=%b Capture_Enable=%b Done=%b",
                $time, state, capture_enable, capture_done
            );

            @(negedge clk);
            sample_enable = 0;
        end
    endtask

    initial begin

        // Save waveforms for viewing in Surfer
        $dumpfile("sim/capture_fsm.vcd");
        $dumpvars(0, capture_fsm_tb);

        // Release reset
        @(negedge clk);
        rst = 0;

        // TEST 1: Start capture
        $display("TEST 1: Start capture");

        start_capture = 1;

        @(posedge clk);
        #1;

        $display("State=%b", state);

        @(negedge clk);
        start_capture = 0;

        // TEST 2: Pre-trigger sampling
        $display("TEST 2: Pre-trigger sampling");

        repeat (4)
            take_sample();

        // TEST 3: Trigger detection
        $display("TEST 3: Trigger detection");

        @(negedge clk);
        trigger_detected = 1;

        @(posedge clk);
        #1;

        $display("State=%b", state);

        @(negedge clk);
        trigger_detected = 0;

        // TEST 4: Verify post-trigger capture
        $display("TEST 4: Post-trigger sampling");

        repeat (4)
            take_sample();

        $display("Simulation complete");

        $finish;

    end

endmodule
