// Read-only: the design under test for exercise 22, a 4-deep, 8-bit FIFO (like exercise 13).
// bug_en = 1 injects a data-corruption bug that a good scoreboard must catch.
module fifo (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       push,
    input  logic [7:0] din,
    input  logic       pop,
    output logic [7:0] dout,
    output logic       full,
    output logic       empty,
    output logic [2:0] count,
    input  logic       bug_en
);
  logic [7:0] mem[4];
  logic [1:0] wr_ptr, rd_ptr;
  logic       do_push, do_pop;

  assign full    = (count == 3'd4);
  assign empty   = (count == 3'd0);
  assign do_push = push && !full;
  assign do_pop  = pop && !empty;
  assign dout    = mem[rd_ptr] ^ ((bug_en && rd_ptr == 2'd3) ? 8'h01 : 8'h00);

  always_ff @(posedge clk) begin
    if (do_push) mem[wr_ptr] <= din;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= '0;
      rd_ptr <= '0;
      count  <= '0;
    end else begin
      if (do_push) wr_ptr <= wr_ptr + 1'b1;
      if (do_pop) rd_ptr <= rd_ptr + 1'b1;
      if (do_push && !do_pop) count <= count + 1'b1;
      else if (do_pop && !do_push) count <= count - 1'b1;
    end
  end
endmodule
