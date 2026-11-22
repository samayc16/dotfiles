// Exercise 04 · Parameterized adder (reference solution)
module adder #(
    parameter int W = 8
) (
    input  logic [W-1:0] a,
    input  logic [W-1:0] b,
    input  logic         cin,
    output logic [W-1:0] sum,
    output logic         cout,
    output logic         overflow
);
  assign {cout, sum} = {1'b0, a} + {1'b0, b} + (W+1)'(cin);
  assign overflow    = (a[W-1] == b[W-1]) && (sum[W-1] != a[W-1]);
endmodule
