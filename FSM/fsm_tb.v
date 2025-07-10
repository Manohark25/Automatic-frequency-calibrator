`timescale 1ns/1ps

module tb_afc_fsm_6bit;

    // Inputs
    reg clk;
    reg rst_n;
    reg [2:0] comp_in;
    reg done;

    // Outputs
    wire [5:0] state_out;
    wire change;

    // Instantiate the FSM module
    afc_fsm_6bit uut (
        .clk(clk),
        .rst_n(rst_n),
        .comp_in(comp_in),
        .done(done),
        .state_out(state_out),
        .change(change)
    );

    // Clock generation for 5.33 MHz (period = ~187.6 ns)
    initial begin
        clk = 0;
        forever #93.8 clk = ~clk;
    end

    // Task to apply stimulus
    task apply_input(input [2:0] c, input integer delay);
        begin
            @(negedge clk);
            comp_in = c;
            done = 1;
            @(negedge clk);
            done = 0;
            #(delay);
        end
    endtask

    // Main test
    initial begin
        $dumpfile("afc_fsm_6bit.vcd");
        $dumpvars(0, tb_afc_fsm_6bit);

        // Reset logic
        rst_n = 0;
        comp_in = 3'b000;
        done = 0;

        #200;
        rst_n = 1;
        #200;

        // Stimulus sequence
        apply_input(3'b010, 200); // FAST -> Band 8
        apply_input(3'b100, 200); // SLOW -> Band 12
        apply_input(3'b001, 200); // FREEZE -> done

        apply_input(3'b010, 200); // No effect after FREEZE

        #500;

        // Reset again
        rst_n = 0;
        #200;
        rst_n = 1;
        #200;

        apply_input(3'b010, 200);
        apply_input(3'b100, 200);
        apply_input(3'b001, 200);

        #500;
        $finish;
    end

endmodule
