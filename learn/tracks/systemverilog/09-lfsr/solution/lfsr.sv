// Exercise 09 · LFSR (reference solution)
module lfsr #(
    parameter logic [7:0] SEED = 8'h01
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    output logic [7:0] q
);
  logic fb;
  assign fb = q[7] ^ q[5] ^ q[4] ^ q[3];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= SEED;
    else if (en) q <= {q[6:0], fb};
  end
endmodule
