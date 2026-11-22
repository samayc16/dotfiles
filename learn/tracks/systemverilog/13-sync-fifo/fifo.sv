// Exercise 13 · Synchronous FIFO
module fifo #(
    parameter int W     = 8,
    parameter int DEPTH = 4   // any value >= 2, not only powers of two
) (
    input  logic                       clk,
    input  logic                       rst_n,  // async active-low: empty
    input  logic                       push,   // write din at the clock edge (ignored when full)
    input  logic [W-1:0]               din,
    input  logic                       pop,    // drop the oldest entry at the clock edge (ignored when empty)
    output logic [W-1:0]               dout,   // the oldest entry ("show-ahead"), valid while !empty
    output logic                       full,
    output logic                       empty,
    output logic [$clog2(DEPTH+1)-1:0] count   // number of entries stored
);
  localparam int AW = $clog2(DEPTH);

  logic [W-1:0]  mem[DEPTH];
  logic [AW-1:0] wr_ptr, rd_ptr;

  // TODO:
  //   do_push = push && !full;  do_pop = pop && !empty;   (both use the state BEFORE the edge)
  //   on do_push: mem[wr_ptr] <= din, advance wr_ptr (wrap after DEPTH-1)
  //   on do_pop:  advance rd_ptr (wrap after DEPTH-1)
  //   count: +1, -1, or unchanged (push and pop together)
  assign dout  = mem[rd_ptr];
  assign full  = 1'b0;
  assign empty = 1'b1;
  assign count = '0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= '0;
      rd_ptr <= '0;
    end
  end
endmodule
