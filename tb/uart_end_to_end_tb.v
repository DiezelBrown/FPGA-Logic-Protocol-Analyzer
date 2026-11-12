
`timescale 1ns/1ps

module uart_end_to_end_tb;

    reg clk = 0;
    reg rst = 1;
    reg [7:0] signal_in = 0;
    reg [2:0] sample_rate = 3'b000;

    reg [2:0] trigger_channel = 3'd3;
    reg trigger_edge = 0;
    reg trigger_mode = 0;
    reg [7:0] trigger_pattern = 0;
    reg [7:0] trigger_mask = 8'hFF;

    reg start_capture = 0;
    reg [16:0] pre_trigger_count = 17'd4;
    reg start_offload = 0;
    reg [16:0] read_address = 0;

    wire [7:0] read_data;
    wire [7:0] sampled_signal;
    wire trigger_detected;
    wire capture_enable;
    wire capture_done;
    wire [1:0] capture_state;
    wire [16:0] current_write_address;
    wire [16:0] trigger_address;
    wire uart_tx_pin;
    wire offload_busy;
    wire offload_done;

    localparam integer BIT_CYCLES = 10;
    localparam integer BYTES_TO_CHECK = 16;

    logic_analyzer_top #(
        .UART_BAUD_RATE(10_000_000)
    ) uut (
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
        .start_offload(start_offload),
        .uart_tx_pin(uart_tx_pin),
        .offload_busy(offload_busy),
        .offload_done(offload_done),
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

    always #5 clk = ~clk;

    task receive_byte;
        output reg [7:0] received_byte;
        integer bit_number;
        begin
            // Detect UART start bit.
            @(negedge uart_tx_pin);

            // Sample in the middle of the start bit.
            repeat (BIT_CYCLES / 2) @(posedge clk);
            #1;
            if (uart_tx_pin !== 0)
                $fatal(1, "FAIL: Invalid start bit");

            // UART sends data least-significant bit first.
            for (bit_number = 0; bit_number < 8;
                 bit_number = bit_number + 1) begin
                repeat (BIT_CYCLES) @(posedge clk);
                #1;
                received_byte[bit_number] = uart_tx_pin;
            end

            // Verify stop bit.
            repeat (BIT_CYCLES) @(posedge clk);
            #1;
            if (uart_tx_pin !== 1)
                $fatal(1, "FAIL: Invalid stop bit");
        end
    endtask

    reg [7:0] received_byte;
    reg [7:0] expected_byte;
    reg [16:0] expected_address;
    integer i;

    initial begin
        $dumpfile("sim/uart_end_to_end.vcd");
        $dumpvars(0, uart_end_to_end_tb);

        repeat (5) @(negedge clk);
        rst = 0;

        // Start capturing.
        @(negedge clk);
        start_capture = 1;
        @(negedge clk);
        start_capture = 0;

        repeat (8) @(negedge clk);

        // Generate rising edge on channel 3.
        signal_in = 8'h08;

        wait (capture_done == 1);
        @(negedge clk);

        $display("PASS: Capture completed");

        // Record expected starting address.
        expected_address = current_write_address;

        // Start UART offload.
        start_offload = 1;
        @(negedge clk);
        start_offload = 0;

        for (i = 0; i < BYTES_TO_CHECK; i = i + 1) begin
            expected_byte = uut.buffer.buffer[
                (expected_address + i) & 17'h1FFFF
            ];

            receive_byte(received_byte);

            if (received_byte !== expected_byte)
                $fatal(1,
                    "FAIL: Byte %0d expected %h got %h",
                    i, expected_byte, received_byte);

            $display("PASS: Byte %0d = %h", i, received_byte);
        end

        $display("PASS: UART end-to-end test completed");
        $finish;
    end

    initial begin
        #10000000;
        $fatal(1, "FAIL: Simulation timeout");
    end

endmodule
