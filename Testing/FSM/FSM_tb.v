`timescale 1ns/1ps

module afc_fsm_tb;
    // Parameters
    parameter CLK_PERIOD = 10;  // 10ns clock period (100MHz)
    
    // Testbench signals
    reg clk;
    reg rst_n;
    reg [2:0] comp_in;
    wire [4:0] state_out;
    
    // Instantiate the DUT (Device Under Test)
    afc_fsm dut (
        .clk(clk),
        .rst_n(rst_n),
        .comp_in(comp_in),
        .state_out(state_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Testbench stimulus and monitoring
    initial begin
        // Initialize
        rst_n = 0;
        comp_in = 3'b000;
        
        // Apply initial reset
        #(CLK_PERIOD*2);
        rst_n = 1;
        #(CLK_PERIOD*2);
        
        // Test Case 1: IDLE -> S1100 (Slow from IDLE)
        $display("Test Case 1: IDLE -> S1100 (Slow)");
        comp_in = 3'b010; // Slow
        #(CLK_PERIOD);
        $display("State: %b (Expected: 01100)", state_out);
        
        // Test Case 2: S1100 -> S1101 (Slow again)
        $display("Test Case 2: S1100 -> S1101 (Slow)");
        comp_in = 3'b010; // Slow
        #(CLK_PERIOD);
        $display("State: %b (Expected: 01101)", state_out);
        
        // Test Case 3: S1101 -> F1101 (Freeze)
        $display("Test Case 3: S1101 -> F1101 (Freeze)");
        comp_in = 3'b001; // Freeze
        #(CLK_PERIOD);
        $display("State: %b (Expected: 11101)", state_out);
        
        // Test Case 4: F1101 should remain in finished state
        $display("Test Case 4: F1101 should remain in finished state");
        comp_in = 3'b010; // Try Slow (should have no effect)
        #(CLK_PERIOD);
        $display("State: %b (Expected: 11101)", state_out);
        
        // Reset to start new test sequence
        rst_n = 0;
        #(CLK_PERIOD*2);
        rst_n = 1;
        #(CLK_PERIOD*2);
        
        // End simulation
        #(CLK_PERIOD*5);
        $display("Testbench completed");
        $finish;
    end
    
    // Optional: Add waveform dumping for visualization
    initial begin
        $dumpfile("afc_fsm.vcd");
        $dumpvars(0, afc_fsm_tb);
    end
endmodule

