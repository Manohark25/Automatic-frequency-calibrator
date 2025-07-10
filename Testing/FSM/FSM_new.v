module afc_fsm_6bit (
    input wire clk,
    input wire rst_n,
    input wire [2:0] comp_in,    // FAST=3'b100, SLOW=3'b010, FREEZE=3'b001
    output reg [5:0] state_out   // [5]=finish, [4:0]=band(0-31)
);

    localparam FREEZE = 3'b001, SLOW = 3'b010, FAST = 3'b100;
    localparam IDLE_BAND = 5'd16;

    reg [4:0] low, high, mid;
    reg finish;
    reg [4:0] band;

    // Initialization and band update logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            low    <= 5'd0;
            high   <= 5'd31;
            mid    <= IDLE_BAND;
            band   <= IDLE_BAND;
            finish <= 1'b0;
        end else if (!finish) begin
            case (comp_in)
                FREEZE: begin
                    finish <= 1'b1;
                    band   <= mid;
                end
                SLOW: begin
                    low  <= mid + 1;
                    high <= high;
                    mid  <= ((mid + 1) + high) >> 1;
                    band <= ((mid + 1) + high) >> 1;
                end
                FAST: begin
                    low  <= low;
                    high <= mid - 1;
                    mid  <= (low + (mid - 1)) >> 1;
                    band <= (low + (mid - 1)) >> 1;
                end
                default: ; // Hold state
            endcase
        end
        // If finish, hold values
    end

    // Output assignment
    always @(*) begin
        state_out = {finish, band};
    end

endmodule

