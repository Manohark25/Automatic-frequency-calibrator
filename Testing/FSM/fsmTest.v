module binary_search_fsm(
    input wire clk,          // Clock input
    input wire rst_n,        // Active low reset
    input wire [2:0] comp_in, // Comparison input (FAST=100, SLOW=010, FREEZE=001)
    input wire done,         // Signal indicating comparison is complete
    output reg [5:0] state_out, // 6-bit output (MSB=finish bit, [4:0]=band selection)
    output reg change        // Signal when state changes
);

    // Parameters for comparison inputs
    parameter FREEZE = 3'b001;
    parameter SLOW   = 3'b010;
    parameter FAST   = 3'b100;
    
    // State encoding using S-prefix for states (matches diagram)
    // Root node
    parameter S10000 = 6'b010000; // Starting state (band 16)
    
    // Level 1 states
    parameter S01000 = 6'b001000; // Band 8
    parameter S11000 = 6'b011000; // Band 24
    
    // Level 2 states
    parameter S00100 = 6'b000100; // Band 4
    parameter S01100 = 6'b001100; // Band 12
    parameter S10100 = 6'b010100; // Band 20
    parameter S11100 = 6'b011100; // Band 28
    
    // Level 3 states
    parameter S00010 = 6'b000010; // Band 2
    parameter S00110 = 6'b000110; // Band 6
    parameter S01010 = 6'b001010; // Band 10
    parameter S01110 = 6'b001110; // Band 14
    parameter S10010 = 6'b010010; // Band 18
    parameter S10110 = 6'b010110; // Band 22
    parameter S11010 = 6'b011010; // Band 26
    parameter S11110 = 6'b011110; // Band 30
    
    // Level 4 states
    parameter S00001 = 6'b000001; // Band 1
    parameter S00011 = 6'b000011; // Band 3
    parameter S00101 = 6'b000101; // Band 5
    parameter S00111 = 6'b000111; // Band 7
    parameter S01001 = 6'b001001; // Band 9
    parameter S01011 = 6'b001011; // Band 11
    parameter S01101 = 6'b001101; // Band 13
    parameter S01111 = 6'b001111; // Band 15
    parameter S10001 = 6'b010001; // Band 17
    parameter S10011 = 6'b010011; // Band 19
    parameter S10101 = 6'b010101; // Band 21
    parameter S10111 = 6'b010111; // Band 23
    parameter S11001 = 6'b011001; // Band 25
    parameter S11011 = 6'b011011; // Band 27
    parameter S11101 = 6'b011101; // Band 29
    parameter S11111 = 6'b011111; // Band 31

    // Finished states (MSB=1)
    parameter DONE_FLAG = 6'b100000; // OR with state to set done bit
    
    reg [5:0] current_state, next_state;
    reg finish;

    // Sequential logic for state transitions
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S10000; // Start at band 16
            finish <= 1'b0;
            change <= 1'b0;
        end else begin
            change <= 1'b0; // Default: no change
            
            if (done && !finish) begin
                if (next_state != current_state) begin
                    change <= 1'b1; // Signal state change
                    current_state <= next_state;
                end
                
                if (comp_in == FREEZE) begin
                    finish <= 1'b1;
                end
            end
        end
    end
    
    // Combinational logic for next state determination
    always @(*) begin
        // Default: stay in current state
        next_state = current_state;
        
        if (!finish && done) begin
            case (current_state)
                // Root node (band 16)
                S10000: begin
                    case (comp_in)
                        FREEZE: next_state = S10000 | DONE_FLAG;
                        SLOW: next_state = S11000; // Go to band 24 (blue line)
                        FAST: next_state = S01000; // Go to band 8 (red line)
                        default: next_state = current_state;
                    endcase
                end
                
                // Level 1 nodes
                S01000: begin // Band 8
                    case (comp_in)
                        FREEZE: next_state = S01000 | DONE_FLAG;
                        SLOW: next_state = S01100;  // Go to band 12 (blue)
                        FAST: next_state = S00100;  // Go to band 4 (red)
                        default: next_state = current_state;
                    endcase
                end
                
                S11000: begin // Band 24
                    case (comp_in)
                        FREEZE: next_state = S11000 | DONE_FLAG;
                        SLOW: next_state = S11100;  // Go to band 28 (blue)
                        FAST: next_state = S10100;  // Go to band 20 (red)
                        default: next_state = current_state;
                    endcase
                end
                
                // Level 2 nodes
                S00100: begin // Band 4
                    case (comp_in)
                        FREEZE: next_state = S00100 | DONE_FLAG;
                        SLOW: next_state = S00110;  // Go to band 6 (blue)
                        FAST: next_state = S00010;  // Go to band 2 (red)
                        default: next_state = current_state;
                    endcase
                end
                
                S01100: begin // Band 12
                    case (comp_in)
                        FREEZE: next_state = S01100 | DONE_FLAG;
                        SLOW: next_state = S01110;  // Go to band 14 (blue)
                        FAST: next_state = S01010;  // Go to band 10 (red)
                        default: next_state = current_state;
                    endcase
                end
                
                S10100: begin // Band 20
                    case (comp_in)
                        FREEZE: next_state = S10100 | DONE_FLAG;
                        SLOW: next_state = S10110;  // Go to band 22 (blue)
                        FAST: next_state = S10010;  // Go to band 18 (red)
                        default: next_state = current_state;
                    endcase
                end
                
                S11100: begin // Band 28
                    case (comp_in)
                        FREEZE: next_state = S11100 | DONE_FLAG;
                        SLOW: next_state = S11110;  // Go to band 30 (blue)
                        FAST: next_state = S11010;  // Go to band 26 (red)
                        default: next_state = current_state;
                    endcase
                end
                
                // Level 3 nodes
                S00010: begin // Band 2
                    case (comp_in)
                        FREEZE: next_state = S00010 | DONE_FLAG;
                        SLOW: next_state = S00011;  // Go to band 3 (blue)
                        FAST: next_state = S00001;  // Go to band 1 (red)
                        default: next_state = current_state;
                    endcase
                end
                
                S00110: begin // Band 6
                    case (comp_in)
                        FREEZE: next_state = S00110 | DONE_FLAG;
                        SLOW: next_state = S00111;  // Go to band 7 (blue)
                        FAST: next_state = S00101;  // Go to band 5 (red)
                        default: next_state = current_state;
                    endcase
                end
                
                S01010: begin // Band 10
                    case (comp_in)
                        FREEZE: next_state = S01010 | DONE_FLAG;
                        SLOW: next_state = S01011;  // Go to band 11 (blue)
                        FAST: next_state = S01001;  // Go to band 9 (red)
                        default: next_state = current_state;
                    endcase
                end
                
                S01110: begin // Band 14
                    case (comp_in)
                        FREEZE: next_state = S01110 | DONE_FLAG;
                        SLOW: next_state = S01111;  // Go to band 15 (blue)
                        FAST: next_state = S01101;  // Go to band 13 (red)
                        default: next_state = current_state;
                    endcase
                end
                
                S10010: begin // Band 18
                    case (comp_in)
                        FREEZE: next_state = S10010 | DONE_FLAG;
                        SLOW: next_state = S10011;  // Go to band 19 (blue)
                        FAST: next_state = S10001;  // Go to band 17 (red)
                        default: next_state = current_state;
                    endcase
                end
                
                S10110: begin // Band 22
                    case (comp_in)
                        FREEZE: next_state = S10110 | DONE_FLAG;
                        SLOW: next_state = S10111;  // Go to band 23 (blue)
                        FAST: next_state = S10101;  // Go to band 21 (red)
                        default: next_state = current_state;
                    endcase
                end
                
                S11010: begin // Band 26
                    case (comp_in)
                        FREEZE: next_state = S11010 | DONE_FLAG;
                        SLOW: next_state = S11011;  // Go to band 27 (blue)
                        FAST: next_state = S11001;  // Go to band 25 (red)
                        default: next_state = current_state;
                    endcase
                end
                
                S11110: begin // Band 30
                    case (comp_in)
                        FREEZE: next_state = S11110 | DONE_FLAG;
                        SLOW: next_state = S11111;  // Go to band 31 (blue)
                        FAST: next_state = S11101;  // Go to band 29 (red)
                        default: next_state = current_state;
                    endcase
                end
// Level 4 nodes (leaf nodes)
S00001: begin // Band 1
    case (comp_in)
        FREEZE: next_state = S00001 | DONE_FLAG;
        SLOW: next_state = S00010;  // Go to band 2
        FAST: next_state = S00000;  // Go to band 0
        default: next_state = current_state;
    endcase
end

S00011: begin // Band 3
    case (comp_in)
        FREEZE: next_state = S00011 | DONE_FLAG;
        SLOW: next_state = S00100;  // Go to band 4
        FAST: next_state = S00010;   // Go to band 2
        default: next_state = current_state;
    endcase
end

S00101: begin // Band 5
    case (comp_in)
        FREEZE: next_state = S00101 | DONE_FLAG;
        SLOW: next_state = S00110;  // Go to band 6
        FAST: next_state = S00100;   // Go to band 4
        default: next_state = current_state;
    endcase
end

S00111: begin // Band 7
    case (comp_in)
        FREEZE: next_state = S00111 | DONE_FLAG;
        SLOW: next_state = S01000;  // Go to band 8
        FAST: next_state = S00110;   //  Go to band 6
        default: next_state = current_state;
    endcase
end

S01001: begin // Band 9
    case (comp_in)
        FREEZE: next_state = S01001 | DONE_FLAG;
        SLOW: next_state = S01010;  // Go to band 10
        FAST: next_state = S01000;   // Go to band 8
        default: next_state = current_state;
    endcase
end

S01011: begin // Band 11
    case (comp_in)
        FREEZE: next_state = S01011 | DONE_FLAG;
        SLOW: next_state = S01100;  // Go to band 12
        FAST: next_state = S01010;   // Go to band 10
        default: next_state = current_state;
    endcase
end

S01101: begin // Band 13
    case (comp_in)
        FREEZE: next_state = S01101 | DONE_FLAG;
        SLOW: next_state = S01110;  // Go to band 14
        FAST: next_state = S01100;   // Go to band 12
        default: next_state = current_state;
    endcase
end

S01111: begin // Band 15
    case (comp_in)
        FREEZE: next_state = S01111 | DONE_FLAG;
        SLOW: next_state = S10000;  // Go to band 16
        FAST: next_state = S01110;   // Go to band 14
        default: next_state = current_state;
    endcase
end

S10001: begin // Band 17
    case (comp_in)
        FREEZE: next_state = S10001 | DONE_FLAG;
        SLOW: next_state = S10010;  // Go to band 18
        FAST: next_state = S10000;   // Go to band 16
        default: next_state = current_state;
    endcase
end

S10011: begin // Band 19
    case (comp_in)
        FREEZE: next_state = S10011 | DONE_FLAG;
        SLOW: next_state = S10100;  // Go to band 20
        FAST: next_state = S10010;   // Go to band 18
        default: next_state = current_state;
    endcase
end

S10101: begin // Band 21
    case (comp_in)
        FREEZE: next_state = S10101 | DONE_FLAG;
        SLOW: next_state = S10110;  // Go to band 22
        FAST: next_state = S10100;   // Go to band 20
        default: next_state = current_state;
    endcase
end

S10111: begin // Band 23
    case (comp_in)
        FREEZE: next_state = S10111 | DONE_FLAG;
        SLOW: next_state = S11000;  // Go to band 24
        FAST: next_state = S10110;   // Go to band 22
        default: next_state = current_state;
    endcase
end

S11001: begin // Band 25
    case (comp_in)
        FREEZE: next_state = S11001 | DONE_FLAG;
        SLOW: next_state = S11010;  // Go to band 26
        FAST: next_state = S11000;   // Go to band 24
        default: next_state = current_state;
    endcase
end

S11011: begin // Band 27
    case (comp_in)
        FREEZE: next_state = S11011 | DONE_FLAG;
        SLOW: next_state = S11100;  // Go to band 28
        FAST: next_state = S11010;   // Go to band 26
        default: next_state = current_state;
    endcase
end

S11101: begin // Band 29
    case (comp_in)
        FREEZE: next_state = S11101 | DONE_FLAG;
        SLOW: next_state = S11110;  // Go to band 30
        FAST: next_state = S11100;   // Go to band 28
        default: next_state = current_state;
    endcase
end

S11111: begin // Band 31
    case (comp_in)
        FREEZE: next_state = S11111 | DONE_FLAG;
        SLOW: next_state = S11101;  // Go to band 16
        FAST: next_state = S11110;   // Go to band 30
        default: next_state = current_state;
    endcase
end
// Level 5
S00000: begin // Band 0
    case (comp_in)
        FREEZE: next_state = S00000 | DONE_FLAG;
        SLOW: next_state = S00001;  // Go to band 1
        FAST: next_state = S10000;   // Go to band 16
        default: next_state = current_state;
    endcase
end
                default: begin
                    next_state = S10000;
                end
            endcase
        end
    end
    
    // Output assignment
    always @(*) begin
        if (finish)
            state_out = current_state | DONE_FLAG;  // Set MSB to indicate done
        else
            state_out = current_state;
    end

endmodule
