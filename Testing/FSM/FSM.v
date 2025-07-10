module afc_fsm(
    input wire clk,
    input wire rst_n,
    input wire [2:0] comp_in,  // 3-bit comparator input (fast=100, slow=010, freeze=001)
    output reg [4:0] state_out // 5-bit state output (MSB=finish bit, [3:0]=band selection)
);

    // State definitions - format: {finish_bit, band[3:0]}
    // Operational states (finish=0)
    parameter IDLE     = 5'b01000;  // Starting state (middle band)
    parameter ERROR    = 5'b00101;  // Error state
    
    // Band states (not finished)
    parameter S0000    = 5'b00000;
    parameter S0001    = 5'b00001;
    parameter S0010    = 5'b00010;
    parameter S0011    = 5'b00011;
    parameter S0100    = 5'b00100;
    parameter S0101    = 5'b00101;
    parameter S0110    = 5'b00110;
    parameter S0111    = 5'b00111;
    parameter S1000    = 5'b01000;  // Same as IDLE
    parameter S1001    = 5'b01001;
    parameter S1010    = 5'b01010;
    parameter S1011    = 5'b01011;
    parameter S1100    = 5'b01100;
    parameter S1101    = 5'b01101;
    parameter S1110    = 5'b01110;
    parameter S1111    = 5'b01111;
    
    // Finish states (finish=1)
    parameter F0000    = 5'b10000;
    parameter F0001    = 5'b10001;
    parameter F0010    = 5'b10010;
    parameter F0011    = 5'b10011;
    parameter F0100    = 5'b10100;
    parameter F0101    = 5'b10101;
    parameter F0110    = 5'b10110;
    parameter F0111    = 5'b10111;
    parameter F1000    = 5'b11000;
    parameter F1001    = 5'b11001;
    parameter F1010    = 5'b11010;
    parameter F1011    = 5'b11011;
    parameter F1100    = 5'b11100;
    parameter F1101    = 5'b11101;
    parameter F1110    = 5'b11110;
    parameter F1111    = 5'b11111;
    
    // Input signal definitions
    parameter FREEZE   = 3'b001;
    parameter SLOW     = 3'b010;
    parameter FAST     = 3'b100;
    
    // Internal state registers
    reg [4:0] current_state, next_state;
    
    // Sequential logic - state register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end
    
    // Combinational logic - next state determination
    always @(*) begin
        // Default: hold current state
        next_state = current_state;
        
        case (current_state)
            // IDLE state (starts at middle band = 01000)
            IDLE: begin
                case (comp_in)
                    FREEZE: next_state = F1000;  // Freeze -> set finish bit
                    SLOW:   next_state = S1100;  // Slow -> go higher (01100)
                    FAST:   next_state = S0100;  // Fast -> go lower (00100)
                    default: next_state = IDLE;
                endcase
            end
            
            // Band 0000
            S0000: begin
                case (comp_in)
                    FREEZE: next_state = F0000;
                    SLOW:   next_state = S0001;  // Go to next higher band
                    FAST:   next_state = ERROR;  // Already at lowest band
                    default: next_state = S0000;
                endcase
            end
            
            // Band 0001
            S0001: begin
                case (comp_in)
                    FREEZE: next_state = F0001;
                    SLOW:   next_state = S0010;
                    FAST:   next_state = S0000;
                    default: next_state = S0001;
                endcase
            end
            
            // Band 0010
            S0010: begin
                case (comp_in)
                    FREEZE: next_state = F0010;
                    SLOW:   next_state = S0011;
                    FAST:   next_state = S0001;
                    default: next_state = S0010;
                endcase
            end
            
            // Band 0011
            S0011: begin
                case (comp_in)
                    FREEZE: next_state = F0011;
                    SLOW:   next_state = S0100;
                    FAST:   next_state = S0010;
                    default: next_state = S0011;
                endcase
            end
            
            // Band 0100
            S0100: begin
                case (comp_in)
                    FREEZE: next_state = F0100;
                    SLOW:   next_state = S0101;
                    FAST:   next_state = S0011;
                    default: next_state = S0100;
                endcase
            end
            
            // Band 0101
            S0101: begin
                case (comp_in)
                    FREEZE: next_state = F0101;
                    SLOW:   next_state = S0110;
                    FAST:   next_state = S0100;
                    default: next_state = S0101;
                endcase
            end
            
            // Band 0110
            S0110: begin
                case (comp_in)
                    FREEZE: next_state = F0110;
                    SLOW:   next_state = S0111;
                    FAST:   next_state = S0101;
                    default: next_state = S0110;
                endcase
            end
            
            // Band 0111
            S0111: begin
                case (comp_in)
                    FREEZE: next_state = F0111;
                    SLOW:   next_state = S1000;
                    FAST:   next_state = S0110;
                    default: next_state = S0111;
                endcase
            end
            
            // Band 1000 (matches IDLE, but handled separately for clarity)
            S1000: begin
                case (comp_in)
                    FREEZE: next_state = F1000;
                    SLOW:   next_state = S1001;
                    FAST:   next_state = S0111;
                    default: next_state = S1000;
                endcase
            end
            
            // Band 1001
            S1001: begin
                case (comp_in)
                    FREEZE: next_state = F1001;
                    SLOW:   next_state = S1010;
                    FAST:   next_state = S1000;
                    default: next_state = S1001;
                endcase
            end
            
            // Band 1010
            S1010: begin
                case (comp_in)
                    FREEZE: next_state = F1010;
                    SLOW:   next_state = S1011;
                    FAST:   next_state = S1001;
                    default: next_state = S1010;
                endcase
            end
            
            // Band 1011
            S1011: begin
                case (comp_in)
                    FREEZE: next_state = F1011;
                    SLOW:   next_state = S1100;
                    FAST:   next_state = S1010;
                    default: next_state = S1011;
                endcase
            end
            
            // Band 1100
            S1100: begin
                case (comp_in)
                    FREEZE: next_state = F1100;
                    SLOW:   next_state = S1101;
                    FAST:   next_state = S1011;
                    default: next_state = S1100;
                endcase
            end
            
            // Band 1101
            S1101: begin
                case (comp_in)
                    FREEZE: next_state = F1101;
                    SLOW:   next_state = S1110;
                    FAST:   next_state = S1100;
                    default: next_state = S1101;
                endcase
            end
            
            // Band 1110
            S1110: begin
                case (comp_in)
                    FREEZE: next_state = F1110;
                    SLOW:   next_state = S1111;
                    FAST:   next_state = S1101;
                    default: next_state = S1110;
                endcase
            end
            
            // Band 1111
            S1111: begin
                case (comp_in)
                    FREEZE: next_state = F1111;
                    SLOW:   next_state = ERROR;  // Already at highest band
                    FAST:   next_state = S1110;
                    default: next_state = S1111;
                endcase
            end
            
            // All finish states maintain their value
            F0000, F0001, F0010, F0011, F0100, F0101, F0110, F0111,
            F1000, F1001, F1010, F1011, F1100, F1101, F1110, F1111: begin
                next_state = current_state;  // Stay in finish state
            end
            
            // Error state handling
            ERROR: begin
                if (!rst_n)
                    next_state = IDLE;
                else
                    next_state = ERROR;  // Stay in error until reset
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Output logic - Direct mapping of internal state to output
    always @(*) begin
        state_out = current_state;
    end

endmodule

