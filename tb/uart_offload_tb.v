
`timescale 1ns/1ps

module uart_offload_tb;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg [16:0] start_address = 17'd131070;

    wire [16:0] read_address;
    reg [7:0] read_data;
    wire uart_start;
    wire [7:0] uart_data;
    reg uart_busy = 0;
    reg uart_done = 0;
    wire busy;
    wire done;

    reg [7:0] memory [0:131071];
    integer i;
    integer received = 0;
    reg [16:0] expected_address;

    uart_offload uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .start_address(start_address),
        .read_data(read_data),
        .read_address(read_address),
        .uart_start(uart_start),
        .uart_data(uart_data),
        .uart_busy(uart_busy),
        .uart_done(uart_done),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    // Model the synchronous BRAM read.
    always @(posedge clk)
        read_data <= memory[read_address];

    // Simulate UART accepting and completing each byte.
    always @(posedge clk) begin
        if (rst) begin
            uart_busy <= 0;
            uart_done <= 0;
        end else begin
            uart_done <= 0;

            if (uart_start && !uart_busy) begin
                expected_address = start_address + received;

                if (read_address !== expected_address)
                    $fatal(1, "FAIL: Incorrect read address at byte %0d", received);

                if (uart_data !== memory[expected_address])
                    $fatal(1, "FAIL: Incorrect UART data at byte %0d", received);

                received = received + 1;
                uart_busy <= 1;
            end else if (uart_busy) begin
                uart_busy <= 0;
                uart_done <= 1;
            end
        end
    end

    initial begin
        $dumpfile("sim/uart_offload.vcd");
        $dumpvars(0, uart_offload_tb);

        for (i = 0; i < 131072; i = i + 1)
            memory[i] = i[7:0] ^ i[16:9];

        repeat (5) @(negedge clk);
        rst = 0;

        @(negedge clk);
        start = 1;

        @(negedge clk);
        start = 0;

        wait (done == 1);
        #1;

        if (received != 131072)
            $fatal(1, "FAIL: Expected 131072 bytes, got %0d", received);

        if (busy !== 0)
            $fatal(1, "FAIL: Offload controller still busy");

        $display("PASS: All 131072 bytes transmitted correctly");
        $display("PASS: Circular buffer address wraparound");
        $display("PASS: UART handshake and BRAM read timing");
        $display("Simulation complete.");

        $finish;
    end

    initial begin
        #20000000;
        $fatal(1, "FAIL: Offload simulation timeout");
    end

endmodule
