// Exercise 13 · Synchronous FIFO (reference solution)
module fifo #(
    parameter int W     = 8,
    parameter int DEPTH = 4
) (
    input  logic                       clk,
    input  logic                       rst_n,
    input  logic                       push,
    input  logic [W-1:0]               din,
    input  logic                       pop,
    output logic [W-1:0]               dout,
    output logic                       full,
    output logic                       empty,
    output logic [$clog2(DEPTH+1)-1:0] count
);
  localparam int AW = $clog2(DEPTH);
  localparam int CW = $clog2(DEPTH + 1);
  localparam logic [AW-1:0] LastIdx = AW'(DEPTH - 1);
  localparam logic [CW-1:0] Depth = CW'(DEPTH);

  logic [W-1:0]  mem[DEPTH];
  logic [AW-1:0] wr_ptr, rd_ptr;
  logic          do_push, do_pop;

  assign full    = (count == Depth);
  assign empty   = (count == '0);
  assign do_push = push && !full;
  assign do_pop  = pop && !empty;
  assign dout    = mem[rd_ptr];

  always_ff @(posedge clk) begin
    if (do_push) mem[wr_ptr] <= din;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= '0;
      rd_ptr <= '0;
      count  <= '0;
    end else begin
      if (do_push) wr_ptr <= (wr_ptr == LastIdx) ? '0 : wr_ptr + 1'b1;
      if (do_pop) rd_ptr <= (rd_ptr == LastIdx) ? '0 : rd_ptr + 1'b1;
      unique case ({do_push, do_pop})
        2'b10:   count <= count + 1'b1;
        2'b01:   count <= count - 1'b1;
        default: count <= count;
      endcase
    end
  end
endmodule
