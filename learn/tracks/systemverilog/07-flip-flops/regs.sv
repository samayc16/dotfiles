// Exercise 07 · Flip-flops: asynchronous vs synchronous reset, clock enable
module regs (
    input  logic       clk,
    input  logic       rst_n,    // asynchronous, ACTIVE-LOW reset
    input  logic       srst,     // synchronous, active-high reset
    input  logic       en,       // clock enable for q_async
    input  logic [7:0] d,
    output logic [7:0] q_async,  // reset by rst_n IMMEDIATELY (no clock needed) to 8'h00; loads d on a clock edge when en=1
    output logic [7:0] q_sync    // reset by srst on a clock edge to 8'hFF; otherwise loads d on every clock edge
);
  // TODO: add the asynchronous reset (sensitivity list + if) and the enable
  always_ff @(posedge clk) begin
    q_async <= d;
  end

  // TODO: add the synchronous reset
  always_ff @(posedge clk) begin
    q_sync <= d;
  end
endmodule
