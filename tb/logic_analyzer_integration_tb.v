`timescale 1ns/1ps

module logic_analyzer_integration_tb;

    // =====================================================
    // TESTBENCH INPUTS
    // =====================================================

    reg clk = 0;
    reg rst = 1;

    reg [7:0] signal_in = 0;
    reg [2:0] sample_rate = 3'b000; // 100 MS/s

    // Trigger configuration: rising edge on channel 3
    reg [2:0] trigger_channel = 3'd3;
    reg trigger_edge = 0;
    reg trigger_mode = 0;
    reg [7:0] trigger_pattern = 0;
    reg [7:0] trigger_mask = 8'hFF;

    // Capture configuration
    reg start_capture = 0;
    reg [16:0] pre_trigger_count = 17'd4;

    // Memory read interface
    reg [16:0] read_address = 0;
    wire [7:0] read_data;

    // Outputs from the complete analyzer
    wire [7:0] sampled_signal;
    wire trigger_detected;
    wire capture_enable;
    wire capture_done;
    wire [1:0] capture_state;
    wire [16:0] current_write_address;

    // =====================================================
    // DEVICE UNDER TEST
    // =====================================================

    logic_analyzer_top uut (
        .clk(clk),
        .rst(rst),

        .signal_in(signal_in),
        .sample_rate(sample_rate),

        .trigger_channel(trigger_channel),
        .trigger_edge(trigger_edge),
        .trigger_mode(trigger_mode),
        .trigger_pattern(trigger_pattern),
        .trigger_mask(trigger_mask),

        .start_capture(start_capture),
        .pre_trigger_count(pre_trigger_count),

        .read_address(read_address),
        .read_data(read_data),

        .sampled_signal(sampled_signal),
        .trigger_detected(trigger_detected),
        .capture_enable(capture_enable),
        .capture_done(capture_done),
        .capture_state(capture_state),
        .current_write_address(current_write_address)
    );

    // 100 MHz FPGA clock: 10 ns period
    always #5 clk = ~clk;

    // =====================================================
    // TEST SEQUENCE
    // =====================================================

    initial begin

        // Save signals for waveform inspection in Surfer
        $dumpfile("sim/logic_analyzer_integration.vcd");
        $dumpvars(0, logic_analyzer_integration_tb);

        // Hold reset for two clock cycles
        repeat (2) @(negedge clk);
        rst = 0;

        // Start the capture controller
        start_capture = 1;

        @(negedge clk);
        start_capture = 0;

        $display("TEST 1: Capture begins");

        // Allow the pre-trigger buffer to collect samples
        repeat (6) @(negedge clk);

        $display(
            "State=%b Write_Address=%0d",
            capture_state,
            current_write_address
        );

        // Generate a rising edge on channel 3
        $display("TEST 2: Trigger detection");

        signal_in = 8'b00001000;

        repeat (3) @(negedge clk);

        $display(
            "Trigger=%b State=%b Write_Address=%0d",
            trigger_detected,
            capture_state,
            current_write_address
        );

        // Continue capturing after trigger
        $display("TEST 3: Post-trigger capture");

        repeat (10) @(negedge clk);

        $display(
            "State=%b Write_Address=%0d Done=%b",
            capture_state,
            current_write_address,
            capture_done
        );

        // Read the first few memory locations
        $display("TEST 4: Read captured BRAM samples");

        read_address = 0;
        @(posedge clk);
        #1;
        $display("Address 0: %b", read_data);

        @(negedge clk);
        read_address = 1;
        @(posedge clk);
        #1;
        $display("Address 1: %b", read_data);

        @(negedge clk);
        read_address = 2;
        @(posedge clk);
        #1;
        $display("Address 2: %b", read_data);

        $display("Integration simulation complete");

        $finish;
    end

endmodule