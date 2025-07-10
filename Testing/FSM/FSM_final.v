module afc_fsm_6bit (
    input wire clk,
    input wire rst_n,
    input wire [2:0] comp_in,    // FAST=3'b100, SLOW=3'b010, FREEZE=3'b001
    input wire done,
    output reg change,
    output reg [5:0] state_out   // [5]=finish, [4:0]=band(0-31)
);

    localparam FREEZE = 3'b001, SLOW = 3'b010, FAST = 3'b100;
    localparam IDLE_BAND = 5'd16;
    reg [4:0] low, high, mid;
    reg finish;
    reg busy;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            low <= 5'd0;
            high <= 5'd31;
            mid <= IDLE_BAND;
            finish <= 1'b0;
            busy <= 1'b0;
            change <= 1'b1; // Start first comparison
        end else begin
            // Default: don't start a new comparison unless needed
            change <= 1'b0;

            if (!finish && !busy) begin
                busy <= 1'b1;
                change <= 1'b1;
            end
            else if (!finish && done && busy) begin
                // Only update state when comparison is done and busy
                case (comp_in)
                    FREEZE: finish <= 1'b1;
                    SLOW: begin
                        low <= mid + 5'd1;
                        mid <= ((mid + 5'd1) + high) >> 1;
                    end
                    FAST: begin
                        high <= mid - 5'd1;
                        mid <= (low + (mid - 5'd1)) >> 1;
                    end
                endcase
                busy <= 1'b0; // Ready for next comparison
            end
        end
    end
    always @(*) begin
        state_out = {finish, mid};
    end
endmodule