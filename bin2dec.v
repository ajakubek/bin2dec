/**
 * Converts a binary number to sequence of decimal digits.
 * Digits are decoded from LSB to MSB.
 * Ports:
 * - i_bin - binary number to convert
 * - i_bin_stb - set to 1 for 1 clock to start conversion
 * - o_digit - contains decoded digit if o_digit_rd == 1
 * - o_digit_rd - if 1, o_digit contains decoded digit, reset after 1 clock
 * - o_conv_rd - if 1, conversion is complete
 */
module bin2dec
  #(parameter WIDTH = 8,
    parameter WIDTH_MSB = WIDTH - 1,
    parameter CARRY_BIT = WIDTH_MSB + 1,
    parameter DIGIT_MSB = $clog2(10) - 1)
  (input wire clk,
   input wire [WIDTH_MSB:0] i_bin,
   input wire i_bin_stb,
   output reg [DIGIT_MSB:0] o_digit,
   output reg o_digit_rd,
   output reg o_conv_rd);

  reg [WIDTH_MSB:0] bin;
  reg [WIDTH_MSB:0] dividend;
  reg carry;
  reg [$clog2(WIDTH):0] shift_count;

  initial o_digit = 0;
  initial o_digit_rd = 0;
  initial o_conv_rd = 0;
  initial bin = 0;
  initial dividend = 0;
  initial carry = 0;
  initial shift_count = WIDTH;

  wire [CARRY_BIT:0] rotl_dividend;
  wire [WIDTH_MSB:0] rotl_bin;
  wire [CARRY_BIT:0] diff;
  wire quotient;
  wire [WIDTH_MSB:0] remainder;

  assign rotl_dividend = {1'b1, dividend[WIDTH_MSB-1:0], bin[WIDTH_MSB]};
  assign diff = rotl_dividend - 10;
  assign quotient = diff[CARRY_BIT];
  assign remainder = diff[WIDTH_MSB:0];
  assign rotl_bin = {bin[WIDTH_MSB-1:0], carry};

  always @(posedge clk)
  begin
    if (i_bin_stb == 1'b1)
    begin
      // set initial state when input strobed
      o_digit <= 0;
      o_digit_rd <= 0;
      o_conv_rd <= 0;
      bin <= i_bin;
      dividend <= 0;
      carry <= 0;
      shift_count <= WIDTH;
    end
    else
    begin
      // convert input
      if (rotl_bin != 0 || shift_count != 0)
      begin
        bin <= rotl_bin;
        carry <= quotient;

        if (shift_count != 0)
        begin
          dividend <= (quotient == 1'b1) ? remainder : rotl_dividend;
          shift_count <= shift_count - 1;
          o_digit_rd <= 0;
        end
        else
        begin
          // digit complete
          dividend <= 0;
          shift_count <= WIDTH;
          o_digit <= dividend[DIGIT_MSB:0];
          o_digit_rd <= 1;
        end
      end
      else
      begin
        // conversion complete
        o_digit <= dividend[DIGIT_MSB:0];
        o_digit_rd <= ~o_conv_rd; // 1-cycle digit strobe
        o_conv_rd <= 1;
      end
    end
  end
endmodule

module top(CLK,
           A0, A1, A2, A3, A4, A5, A6, A7,
           B0,
           C0, C1, C2, C3,
           E0, E1);

  input wire CLK;
  input wire A0, A1, A2, A3, A4, A5, A6, A7;
  input wire B0;
  output wire C0, C1, C2, C3;
  output wire E0, E1;

  bin2dec #(.WIDTH(8)) b2d(CLK,
                           {A7, A6, A5, A4, A3, A2, A1, A0},
                           B0,
                           {C3, C2, C1, C0},
                           E1,
                           E0);
endmodule
