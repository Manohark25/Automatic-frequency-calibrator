`timescale 1ns/1ps

module afc_tb ();
  wire [5:0] out;
  reg pre_clk = 0;
  reg ref_clk = 0;
  reg div_clk = 0;
  reg clr;

  afc dut (
    .fpre(pre_clk),
    .fref(ref_clk),
    .fdiv(div_clk),
    .clr(clr),
    .out(out)
  );

  integer delay_time_1 = 450;
  integer delay_time_2 = delay_time_1/45;

  initial begin
      forever begin
          #delay_time_1 div_clk = ~div_clk;
          #delay_time_2 pre_clk = ~pre_clk
      end
  end

  initial begin
      #330;
      delay_time_1 = 900;
      delay_time_2 = delay_time_1/45;
      #330
      delay_time_1 = 450;
      delay_time_2 = delay_time_1/45;
  end

  //initial forever #5  pre_clk = ~pre_clk;
  initial forever #200 ref_clk = ~ref_clk;
  //initial forever #18 div_clk = ~div_clk;
    
  initial begin
    clr = 1'b0;
    #100 clr = 1'b1;
    #1500 $finish;
  end

  initial begin
    $dumpfile("out.vcd");
    $dumpvars(0, afc_tb);
  end

endmodule
