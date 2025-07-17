module freq_comparator (
  input wire pre_clk, // Pre-scalar clock
  input wire ref_clk, // Reference clock
  input wire div_clk, // VCO divided clock
  input wire rst, // Reset of comparator
  output reg done, // Done bit to be sent to FSM
  output reg [2:0] flags, // Output
  output reg [9:0] ref_count_out, //refcount
  output reg [9:0] div_count_out  //divcount
);
  
  reg [3:0] n = 4'd2; // Number of cycles to take reading
  reg signed [3:0] m = 4'd2; // Maximum count difference

  // Variables
  reg [9:0] ref_count = 8'd0;
  reg [9:0] div_count = 8'd0;
  reg [9:0] ref_count_buff = 8'd0;
  reg [9:0] div_count_buff = 8'd0;
  reg [9:0] ref_start = 8'd0;
  reg [9:0] div_start = 8'd0;
  reg [9:0] diff1 = 0;
  reg signed [9:0] diff2 = 0;
  reg ref_flag = 0;
  reg div_flag = 0;
  reg ref_flag_pos = 0;
  reg div_flag_pos = 0;
  reg [2:0] ref_check = 0;
  reg [2:0] div_check = 0;

// Reference counter

always @(posedge pre_clk or posedge rst) begin
  if (rst == 1'b0) begin
    ref_count <= 8'd0;
  end else if (ref_clk == 1'b0) begin
    ref_count <= ref_count ;
  end else begin
    ref_count <= ref_count + 1;
  end
end

// Divider counter

always @(posedge pre_clk or posedge rst) begin
  if (rst == 1'b0) begin
    div_count <= 8'd0;
  end else if (div_clk == 1'b0) begin
    div_count <= div_count ;
  end else begin
    div_count <= div_count + 1;
  end
end

  initial begin
    flags = 3'd0;
    done = 1'b0;
  end
  
  always @(posedge ref_clk) begin
    if (rst && !done) begin
 		if (ref_flag == 0 && ref_flag_pos == 0) begin
        		ref_start <= ref_count;
        		ref_flag_pos <= 1;
      end else if (ref_flag == 0) begin
        ref_count_buff <= ref_count - ref_start;
      end
    end
  end

  always @(negedge ref_clk) begin
    if (rst && !done) begin
      if (ref_flag_pos == 1 && ref_flag == 0) begin
        ref_count_buff <= ref_count - ref_start;
        ref_check <= ref_check + 1;
        if (ref_check + 1 == n) begin
          ref_flag <= 1; end
      end
    end
  end

  always @(posedge div_clk) begin
    if (rst && !done) begin
       if (div_flag == 0 && div_flag_pos == 0) begin
        div_start <= div_count;
        div_flag_pos <= 1;
      end else if (div_flag == 0) begin
        div_count_buff <= div_count - div_start;
      end
    end
  end

  always @(negedge div_clk) begin
    if (rst && !done) begin
      if (div_flag_pos == 1 && div_flag == 0) begin
        div_count_buff <= div_count - div_start;
        div_check <= div_check + 1;
        if (div_check + 1 == n) begin
          div_flag <= 1; end
      end
    end
  end

  always @(*) begin
    if (rst) begin
      if ((ref_flag == 1) && (div_flag == 1)) begin
        diff1 = (ref_count_buff > div_count_buff) ? (ref_count_buff - div_count_buff)*2'b11 : (div_count_buff - ref_count_buff)*2'b11;
       // diff2 = (ref_count_buff - div_count_buff)*2'b11;
      end
    end else begin
      flags = 3'b000;
      ref_count_buff = 0;
      div_count_buff = 0;
      ref_flag = 0;
      div_flag = 0;
      ref_flag_pos = 0;
      div_flag_pos = 0;
      ref_check = 0;
      div_check = 0;
    end
	ref_count_out = ref_count_buff;
	div_count_out = div_count_buff;
  end

  always @(posedge pre_clk) begin
    if ((ref_flag == 1) && (div_flag == 1)) begin
      if ((diff1 >= m) && (ref_count_buff > div_count_buff) ) begin
        flags <= 3'b100; // slow
      end else if ((diff1 >= m) && (ref_count_buff < div_count_buff) ) begin
        flags <= 3'b010; // fast
      end else if (diff1 < m ) begin
        flags <= 3'b001; // Freeze
      end else begin
        flags <= 3'b111; // Error
      end
      ref_count_buff <= 0;
      div_count_buff <= 0;
      ref_flag <= 0;
      div_flag <= 0;
      ref_flag_pos <= 0;
      div_flag_pos <= 0;
      ref_check <= 0;
      div_check <= 0;
    end
    if (flags == 3'b000) begin 
      done <= 0;
    end else
      done <= 1;
  end
endmodule