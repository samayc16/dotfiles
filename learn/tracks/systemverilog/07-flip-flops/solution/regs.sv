// Exercise 07 · Flip-flops (reference solution)
module regs (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       srst,
    input  logic       en,
    input  logic [7:0] d,
    output logic [7:0] q_async,
    output logic [7:0] q_sync
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) q_async <= 8'h00;
    else if (en) q_async <= d;
  end

  always_ff @(posedge clk) begin
    if (srst) q_sync <= 8'hFF;
    else q_sync <= d;
  end
endmodule
