`timescale 1ns/1ps

module trigger_address_tb;

    reg clk = 0;
    reg rst = 1;

    reg [7:0] signal_in = 0;
    reg [2:0] sample_rate = 3'b101;

    reg [2:0] trigger_channel = 3'd3;
    reg trigger_edge = 0;
    reg trigger_mode = 0;
    reg [7:0] trigger_pattern = 0;
    reg [7:0] trigger_mask = 8'hFF;

    reg start_capture = 0;
    reg [16:0] pre_trigger_count = 17'd4;

    reg [16:0] read_address = 0;
    reg trigger_printed = 0;

    wire [7:0] read_data;
    wire [7:0] sampled_signal;

    wire trigger_detected;
    wire capture_enable;
    wire capture_done;

    wire [1:0] capture_state;
    wire [16:0] current_write_address;
    wire [16:0] trigger_address;

    // Complete logic analyzer
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

        .current_write_address(current_write_address),
        .trigger_address(trigger_address)
    );

    // 100 MHz FPGA clock
    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (uut.sample_enable) begin
            $display("Time=%0t State=%b Previous=%b Current=%b Hit=%b",
                $time,
                capture_state,
                uut.trigger.previous_signal,
                signal_in,
                uut.trigger_hit
            );
        end
    end

    // Print information when the FSM enters POST_TRIGGER.
        always @(posedge clk) begin
            #1;

            if (capture_state == 2'b10 &&
                !trigger_printed) begin

                $display(
                    "Rate=%b Trigger_Address=%0d Write_Address=%0d",
                    sample_rate,
                    trigger_address,
                    current_write_address
                );

                trigger_printed = 1;
            end
        end

    initial begin

        $dumpfile("sim/trigger_address.vcd");
        $dumpvars(0, trigger_address_tb);

        // Reset
        repeat (2) @(negedge clk);
        rst = 0;

        // Begin capture
        start_capture = 1;
        @(negedge clk);
        start_capture = 0;

        // Collect pre-trigger samples
        repeat (600) @(negedge clk);

        // Rising edge on channel 3
        signal_in = 8'b00001000;

        repeat (200) @(negedge clk);
        @(negedge clk);
        read_address = trigger_address - 17'd1;

        @(posedge clk);
        #1;
        $display("Before trigger: Address=%0d Data=%b",
                read_address, read_data);

        // Read the triggering sample
        @(negedge clk);
        read_address = trigger_address;

        @(posedge clk);
        #1;
        $display("Trigger sample: Address=%0d Data=%b",
                read_address, read_data);

        // Read the address immediately after the trigger
        @(negedge clk);
        read_address = trigger_address + 17'd1;

        @(posedge clk);
        #1;
        $display("After trigger: Address=%0d Data=%b",
                read_address, read_data);

        $display("Simulation complete.");
        $finish;
    end

endmodule