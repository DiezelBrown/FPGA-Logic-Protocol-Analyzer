
`timescale 1ns/1ps

module uart_tx_tb;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg [7:0] data_in = 0;

    wire tx;
    wire busy;
    wire done;

    localparam CLKS_PER_BIT = 10;

    uart_tx #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(10_000_000)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    task check_bit;
        input expected;
        begin
            if (tx !== expected)
                $fatal(1, "FAIL: Expected TX=%b, got %b", expected, tx);
        end
    endtask

    initial begin
        $dumpfile("sim/uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);

        repeat (5) @(negedge clk);
        rst = 0;

        // Send 0xA5 = 10100101
        @(negedge clk);
        data_in = 8'hA5;
        start = 1;

        @(negedge clk);
        start = 0;

        wait (busy == 1);
        wait (tx == 0);

        // Sample near the middle of each UART bit.
        repeat (5) @(posedge clk);
        #1;
        check_bit(0); // Start bit

        repeat (10) @(posedge clk);
        #1;
        check_bit(1); // Data bit 0

        repeat (10) @(posedge clk);
        #1;
        check_bit(0); // Data bit 1

        repeat (10) @(posedge clk);
        #1;
        check_bit(1); // Data bit 2

        repeat (10) @(posedge clk);
        #1;
        check_bit(0); // Data bit 3

        repeat (10) @(posedge clk);
        #1;
        check_bit(0); // Data bit 4

        repeat (10) @(posedge clk);
        #1;
        check_bit(1); // Data bit 5

        repeat (10) @(posedge clk);
        #1;
        check_bit(0); // Data bit 6

        repeat (10) @(posedge clk);
        #1;
        check_bit(1); // Data bit 7

        repeat (10) @(posedge clk);
        #1;
        check_bit(1); // Stop bit

        wait (done == 1);
        #1;

        if (busy !== 0 || tx !== 1)
            $fatal(1, "FAIL: UART did not return to idle");

        $display("PASS: UART transmitted 0xA5 correctly");
        $display("Simulation complete.");
        $finish;
    end

    initial begin
        #20000;
        $fatal(1, "FAIL: UART timeout");
    end

endmodule
