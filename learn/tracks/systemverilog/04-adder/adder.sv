// Exercise 04 · Parameterized adder with carry and signed overflow
module adder #(
    parameter int W = 8  // width; the testbench uses W=8 and W=16
) (
    input  logic [W-1:0] a,
    input  logic [W-1:0] b,
    input  logic         cin,
    output logic [W-1:0] sum,
    output logic         cout,     // carry out of the MSB (unsigned overflow)
    output logic         overflow  // signed (two's complement) overflow
);
  // TODO: {cout, sum} = a + b + cin  (mind the widths!)
  assign {cout, sum} = '0;

  // TODO: signed overflow: a and b have the same sign, but sum's sign differs
  assign overflow = 1'b0;
endmodule
