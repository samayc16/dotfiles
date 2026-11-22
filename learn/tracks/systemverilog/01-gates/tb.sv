// Testbench for exercise 01 (read-only). Exhaustive: all 4 input combinations.
module tb;
  logic a, b;
  logic y_and, y_or, y_xor, y_nand, y_not_a;

  gates dut (.*);

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  initial begin
    tbu::group("truth table");
    for (int i = 0; i < 4; i++) begin
      {a, b} = 2'(i);
      #1;
      tbu::check($sformatf("a=%0b b=%0b: y_and", a, b), y_and, a & b);
      tbu::check($sformatf("a=%0b b=%0b: y_or", a, b), y_or, a | b);
      tbu::check($sformatf("a=%0b b=%0b: y_xor", a, b), y_xor, a ^ b);
      tbu::check($sformatf("a=%0b b=%0b: y_nand", a, b), y_nand, 1'(~(a & b)));
      tbu::check($sformatf("a=%0b: y_not_a", a), y_not_a, 1'(~a));
    end
    tbu::finish();
  end
endmodule
