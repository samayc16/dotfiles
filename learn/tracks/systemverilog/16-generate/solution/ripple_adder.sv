// Exercise 16 · Ripple-carry adder (reference solution)
module ripple_adder #(
    parameter int W = 8
) (
    input  logic [W-1:0] a,
    input  logic [W-1:0] b,
    input  logic         cin,
    output logic [W-1:0] sum,
    output logic         cout
);
  logic [W:0] c;
  assign c[0] = cin;

  for (genvar i = 0; i < W; i++) begin : g_bit
    full_adder fa (
        .a   (a[i]),
        .b   (b[i]),
        .cin (c[i]),
        .s   (sum[i]),
        .cout(c[i+1])
    );
  end

  assign cout = c[W];
endmodule
