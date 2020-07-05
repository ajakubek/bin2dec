module bin2dec_tb();
  reg clk;
  reg [7:0] i_bin;
  reg i_bin_stb;
  wire [3:0] o_digit;
  wire o_digit_rd;
  wire o_conv_rd;

  initial clk = 0;

  bin2dec #(.WIDTH(8)) b2d(clk, i_bin, i_bin_stb, o_digit, o_digit_rd, o_conv_rd);

  always begin
    #1 clk = ~clk;
  end

  task send_input;
    input [7:0] input_value;

    begin
      i_bin = input_value;
      #1 i_bin_stb = 1;
      #1 i_bin_stb = 0;
    end
  endtask

  task wait_for_result;
    output integer result;
    integer digit_pow;

    begin
      result = 0;
      digit_pow = 1;

      while (o_conv_rd == 0 || o_digit_rd != 0)
      begin
        if (clk == 0 && o_digit_rd != 0)
        begin
          result = result + o_digit * digit_pow;
          digit_pow = digit_pow * 10;
        end
        #1;
      end
    end
  endtask

  integer i;
  integer result;

  initial begin
    `ifdef MONITOR
    $monitor("mon: %d %d %d", o_digit, o_digit_rd, o_conv_rd);
    `endif

    for (i = 0; i < 256; ++i)
    begin
      send_input(i);
      wait_for_result(result);

      if (i != result)
      begin
        $display("Error: expected %0d, got %0d", i, result);
        $finish();
      end
    end

    $display("All tests passed!");
    $finish();
  end
endmodule
