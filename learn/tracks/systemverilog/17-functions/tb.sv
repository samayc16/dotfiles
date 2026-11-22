// Testbench for exercise 17 (read-only).
module tb;
  import bits_pkg::*;

  function automatic int ref_lowest(logic [31:0] x);
    if (x == 0) return -1;
    return $clog2(x & -x);
  endfunction

  initial begin
    tbu::group("gray code: all 256 values");
    for (int i = 0; i < 256; i++) begin
      automatic logic [7:0] bin = 8'(i);
      automatic logic [7:0] gray = bin ^ (bin >> 1);
      tbu::check($sformatf("bin2gray(%0d)", i), bin2gray(bin), gray);
      tbu::check($sformatf("gray2bin(8'h%02h)", gray), gray2bin(gray), bin);
    end
    tbu::group("gray code: neighbours differ in one bit");
    for (int i = 0; i < 255; i++)
      tbu::check($sformatf("bits changed from %0d to %0d", i, i + 1), $countones(bin2gray(8'(i)) ^ bin2gray(8'(i + 1))), 1);

    tbu::group("popcount / is_pow2 / lowest_set");
    tbu::check("popcount(0)", popcount(0), 0);
    tbu::check("popcount(32'hFFFF_FFFF)", popcount(32'hFFFF_FFFF), 32);
    tbu::check("is_pow2(0)", is_pow2(0), 0);
    tbu::check("is_pow2(1)", is_pow2(1), 1);
    tbu::check("is_pow2(32'h8000_0000)", is_pow2(32'h8000_0000), 1);
    tbu::check("lowest_set(0)", lowest_set(0), -1);
    repeat (500) begin
      automatic logic [31:0] x = $urandom >> $urandom_range(0, 31);
      tbu::check($sformatf("popcount(32'h%08h)", x), popcount(x), $countones(x));
      tbu::check($sformatf("is_pow2(32'h%08h)", x), is_pow2(x), $onehot(x));
      tbu::check($sformatf("lowest_set(32'h%08h)", x), lowest_set(x), ref_lowest(x));
    end
    tbu::finish();
  end
endmodule
