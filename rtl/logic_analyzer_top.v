module logic_analyzer_top #(
    parameter UART_BAUD_RATE = 115200
)(
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

    // UART offload interface
    input start_offload,
    output uart_tx_pin,
    output offload_busy,
    output offload_done,

    // Debug and status outputs
    output [7:0] sampled_signal,
    output trigger_detected,
    output capture_enable,
    output capture_done,
    output [1:0] capture_state,
    output [16:0] current_write_address,
    output [16:0] trigger_address
);

    // Determines when the system should take a sample.
    // All modules use the same FPGA clock.
    wire [16:0] offload_read_address;
    wire [7:0] offload_read_data;

    wire uart_start;
    wire [7:0] uart_data;
    wire uart_busy;
    wire uart_done;

    wire [16:0] oldest_sample_address;
    assign oldest_sample_address = current_write_address;

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
        .trigger_detected(trigger_detected),
        .trigger_hit(trigger_hit)
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
        .state(capture_state),
        .current_write_address(current_write_address),
        .trigger_address(trigger_address)
    );

    // =========================================================
    // CAPTURE BUFFER
    // =========================================================
    // Stores each enabled 8-bit sample into the 128K buffer.
    // The write address automatically wraps around.
        wire [16:0] selected_read_address;

        assign selected_read_address =
            offload_busy ? offload_read_address : read_address;

        assign read_data = offload_read_data;

        capture_buffer buffer (
            .clk(clk),
            .rst(rst),
            .capture_enable(capture_enable),
            .sampled_data(signal_in),

            .read_address(selected_read_address),
            .read_data(offload_read_data),

            .current_write_address(current_write_address)
        );
// =========================================================
// UART OFFLOAD CONTROLLER
// =========================================================

    uart_offload offload_controller (
        .clk(clk),
        .rst(rst),
        .start(start_offload),
        .start_address(oldest_sample_address),

        .read_data(offload_read_data),
        .read_address(offload_read_address),

        .uart_start(uart_start),
        .uart_data(uart_data),
        .uart_busy(uart_busy),
        .uart_done(uart_done),

        .busy(offload_busy),
        .done(offload_done)
    );

    // =========================================================
    // UART TRANSMITTER
    // =========================================================

    uart_tx #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(UART_BAUD_RATE)
    ) transmitter (
        .clk(clk),
        .rst(rst),
        .start(uart_start),
        .data_in(uart_data),

        .tx(uart_tx_pin),
        .busy(uart_busy),
        .done(uart_done)
    );
endmodule