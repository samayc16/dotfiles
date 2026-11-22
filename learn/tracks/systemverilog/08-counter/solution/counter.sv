// Exercise 08 · Counter (reference solution)
module counter #(
    parameter int W   = 4,
    parameter int MAX = 9
) (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         en,
    input  logic         load,
    input  logic [W-1:0] load_val,
    output logic [W-1:0] count,
    output logic         tc
);
  localparam logic [W-1:0] MaxVal = W'(MAX);  // sized copy keeps width lint quiet

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) count <= '0;
    else if (load) count <= load_val;
    else if (en) count <= (count == MaxVal) ? '0 : count + 1'b1;
  end

  assign tc = en && (count == MaxVal);
endmodule
