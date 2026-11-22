// Exercise 09 · 8-bit LFSR (linear-feedback shift register)
module lfsr #(
    parameter logic [7:0] SEED = 8'h01  // must be non-zero: all-zeros is a dead state
) (
    input  logic       clk,
    input  logic       rst_n,  // async active-low reset loads SEED
    input  logic       en,     // advance one step per clock while en=1
    output logic [7:0] q
);
  // Taps 8,6,5,4 (polynomial x^8 + x^6 + x^5 + x^4 + 1) give the maximal period: 255 states.
  // feedback = q[7] ^ q[5] ^ q[4] ^ q[3]; next q = {q[6:0], feedback}
  logic fb;
  assign fb = 1'b0;  // TODO

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= SEED;
    else if (en) q <= {q[6:0], 1'b0};  // TODO: shift the feedback in instead of 0
  end
endmodule
