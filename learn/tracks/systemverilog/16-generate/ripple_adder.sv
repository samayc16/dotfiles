// Exercise 16 · Generate: build a W-bit ripple-carry adder out of W full adders
module ripple_adder #(
    parameter int W = 8
) (
    input  logic [W-1:0] a,
    input  logic [W-1:0] b,
    input  logic         cin,
    output logic [W-1:0] sum,
    output logic         cout
);
  logic [W:0] c;  // c[i] = carry INTO bit i; c[W] = carry out
  assign c[0] = cin;

  // TODO: a generate-for loop. Name the block g_bit and the instance fa:
  //   for (genvar i = 0; i < W; i++) begin : g_bit
  //     full_adder fa (.a(a[i]), ...);
  //   end
  // (the testbench peeks inside g_bit[i].fa, so the names matter)
  assign sum = '0;

  assign cout = c[W];
endmodule
