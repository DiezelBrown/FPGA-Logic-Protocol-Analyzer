module logic_analyzer_top (
    input clk,                          // 100 MHz FPGA system clock
    input rst,                          // Reset system

    input [7:0] signal_in,              // 8 external digital channels
    input [2:0] sample_rate,            // Select sampling frequency

    // Trigger configuration
    input [2:0] trigger_channel,        // Select channel 0-7
    input trigger_edge,                 // 0 = rising, 1 = falling
    input trigger_mode,                 // 0 = edge, 1 = pattern
    input [7:0] trigger_pattern,        // Pattern to detect
    input [7:0] trigger_mask,           // Channels included in comparison

    // Capture configuration
    input start_capture,                // Begin capture
    input [16:0] pre_trigger_count,      // Requested pre-trigger samples

    // Memory read interface
    input [16:0] read_address,
    output [7:0] read_data,

    // Debug and status outputs
    output [7:0] sampled_signal,
    output trigger_detected,
    output capture_enable,
    output capture_done,
    output [1:0] capture_state,
    output [16:0] current_write_address
);

    // Determines when the system should take a sample.
    // All modules use the same FPGA clock.
    wire sample_enable;

    // =========================================================
    // SAMPLE CONTROLLER
    // =========================================================
    // Converts the selected sampling rate into sample_enable.
    sample_controller controller (
        .clk(clk),
        .rst(rst),
        .sample_rate(sample_rate),
        .sample_enable(sample_enable)
    );

    // =========================================================
    // INPUT SAMPLER
    // =========================================================
    // Stores the current values of all 8 digital channels
    // whenever sample_enable is asserted.
    input_sampler sampler (
        .clk(clk),
        .signal_in(signal_in),
        .sample_enable(sample_enable),
        .sampled_signal(sampled_signal)
    );

    // =========================================================
    // TRIGGER ENGINE
    // =========================================================
    // Monitors the selected input channel or 8-bit pattern.
    // Generates trigger_detected when a condition is satisfied.
    trigger_engine trigger (
        .clk(clk),
        .rst(rst),
        .sample_enable(sample_enable),
        .signal_in(signal_in),

        .trigger_channel(trigger_channel),
        .trigger_edge(trigger_edge),
        .trigger_mode(trigger_mode),
        .trigger_pattern(trigger_pattern),
        .trigger_mask(trigger_mask),

        .trigger_detected(trigger_detected)
    );

    // =========================================================
    // CAPTURE FSM
    // =========================================================
    // Controls when samples are written into BRAM.
    // Tracks pre-trigger and post-trigger capture phases.
    capture_fsm capture_controller (
        .clk(clk),
        .rst(rst),
        .start_capture(start_capture),
        .sample_enable(sample_enable),
        .trigger_detected(trigger_detected),
        .pre_trigger_count(pre_trigger_count),

        .capture_enable(capture_enable),
        .capture_done(capture_done),
        .state(capture_state)
    );

    // =========================================================
    // CAPTURE BUFFER
    // =========================================================
    // Stores each enabled 8-bit sample into the 128K buffer.
    // The write address automatically wraps around.
    capture_buffer buffer (
        .clk(clk),
        .rst(rst),
        .capture_enable(capture_enable),
        .sampled_data(signal_in),

        .read_address(read_address),
        .read_data(read_data),

        .current_write_address(current_write_address)
    );

endmodule