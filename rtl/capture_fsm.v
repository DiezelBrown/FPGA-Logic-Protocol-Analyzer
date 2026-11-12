module capture_fsm (
    input clk,
    input rst,
    input start_capture,
    input sample_enable,
    input trigger_detected,
    input [16:0] pre_trigger_count,
    input [16:0] current_write_address, //ADDRESS OF THE NEXT SAMPLE TO BE WRITTEN INTO BRAM
    
    
    output wire capture_enable,
    output reg capture_done,
    output reg [1:0] state,
    output reg [16:0] trigger_address // Address of the sample where the trigger was detected
);
//four states of our capture controller
    localparam IDLE         = 2'b00;
    localparam PRE_TRIGGER  = 2'b01;
    localparam POST_TRIGGER = 2'b10;
    localparam DONE         = 2'b11;

//counter used to track the number of captured samples
    reg [16:0] sample_count;
    reg [17:0] post_count;

    // Combinational write enable for BRAM.
    // Allows memory to write on the same clock edge as sample_enable.
    assign capture_enable =
        sample_enable &&
        ((state == PRE_TRIGGER) || (state == POST_TRIGGER));

    // Sequential logic: executes on each rising edge of the FPGA clock
    // Registers and flip-flops store the FSM state and counter values
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            sample_count <= 0;
            post_count <= 0;
            capture_done <= 0;
            trigger_address <= 17'd0;
        end
        else begin
            // Default outputs LOW unless enabled by the current state
            capture_done <= 0;

            case (state)

                IDLE: begin
                    sample_count <= 0;
                    post_count <= 0;

                    if (start_capture)
                        state <= PRE_TRIGGER;
                end

                PRE_TRIGGER: begin

                    // Count samples until sufficient pre-trigger history exists
                    if (sample_enable && sample_count < pre_trigger_count)
                        sample_count <= sample_count + 1;

                    // The trigger engine reports the event after the
                    // triggering sample has already been written.
                    if (trigger_detected && sample_count >= pre_trigger_count) begin

                        // Current write address points to the NEXT location.
                        // Subtract one to identify the triggering sample.
                        trigger_address <= current_write_address - 17'd1;

                        post_count <= 0;

                        if (pre_trigger_count == 17'd131071)
                            state <= DONE;
                        else
                            state <= POST_TRIGGER;
                    end
                end

                POST_TRIGGER: begin
                    if (sample_enable) begin
                        post_count <= post_count + 1;

                        if (post_count == (18'd131070 - {1'b0, pre_trigger_count}))
                            state <= DONE;
                    end
                end

                DONE: begin
                    capture_done <= 1;

                    if (start_capture)
                        state <= IDLE;
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule