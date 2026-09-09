module sample_controller(
    input clk,
    input rst,
    input [2:0] sample_rate, // 3-bit input to select sample rate
    output reg sample_enable
);

reg [7:0] counter;
reg [7:0] terminal_count;
always @(*) begin
    case (sample_rate)
        3'b000: terminal_count = 8'd0;
        3'b001: terminal_count = 8'd1;
        3'b010: terminal_count = 8'd3;
        3'b011: terminal_count = 8'd9;
        3'b100: terminal_count = 8'd19;
        3'b101: terminal_count = 8'd99;
        default: terminal_count = 8'd9;
endcase
end

     always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            sample_enable <= 0;
        end 
        else if (counter == terminal_count) begin
            counter <= 0;
            sample_enable <= 1;
        end
        else begin
            counter <= counter + 1;
            sample_enable <= 0;
        end

    end

endmodule