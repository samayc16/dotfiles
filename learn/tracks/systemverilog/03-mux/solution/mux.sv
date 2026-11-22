// Exercise 03 · Multiplexers (reference solution)
module mux (
    input  logic [7:0] d0,
    input  logic [7:0] d1,
    input  logic [7:0] d2,
    input  logic [7:0] d3,
    input  logic       sel2,
    input  logic [1:0] sel4,
    output logic [7:0] y2,
    output logic [7:0] y4
);
  assign y2 = sel2 ? d1 : d0;

  always_comb begin
    unique case (sel4)
      2'd0: y4 = d0;
      2'd1: y4 = d1;
      2'd2: y4 = d2;
      2'd3: y4 = d3;
    endcase
  end
endmodule
