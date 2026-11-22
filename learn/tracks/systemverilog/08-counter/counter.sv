// Exercise 08 · Counter with enable, load and wrap-around
module counter #(
    parameter int W   = 4,
    parameter int MAX = 9   // count 0, 1, ..., MAX, 0, 1, ... (a decade counter by default)
) (
    input  logic         clk,
    input  logic         rst_n,     // async active-low reset -> 0
    input  logic         en,        // count up on each clock edge while en=1
    input  logic         load,      // load load_val on the clock edge (priority over en)
    input  logic [W-1:0] load_val,
    output logic [W-1:0] count,
    output logic         tc         // terminal count: en && count == MAX (combinational)
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) count <= '0;
    // TODO: else if load ... else if en ... (wrap MAX -> 0)
  end

  assign tc = 1'b0;  // TODO
endmodule
