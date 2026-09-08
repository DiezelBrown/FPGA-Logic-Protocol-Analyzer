module sample_controller(
    input clk,
    input rst,
    output reg sample_enable
);

reg [7:0] counter;
     always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            sample_enable <= 0;
        end 
        else if (counter == 9) begin
            counter <= 0;
            sample_enable <= 1;
        end
        else begin
            counter <= counter + 1;
            sample_enable <= 0;
        end
    end

endmodule