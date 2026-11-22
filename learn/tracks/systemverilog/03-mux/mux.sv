// Exercise 03 · Multiplexers: ternary and case
module mux (
    input  logic [7:0] d0,
    input  logic [7:0] d1,
    input  logic [7:0] d2,
    input  logic [7:0] d3,
    input  logic       sel2,  // 2:1 select: 0 -> d0, 1 -> d1
    input  logic [1:0] sel4,  // 4:1 select: 0..3 -> d0..d3
    output logic [7:0] y2,
    output logic [7:0] y4
);
  // TODO: a 2:1 mux with the ternary operator  cond ? if_true : if_false
  assign y2 = d0;

  // TODO: a 4:1 mux with a case statement inside always_comb
  always_comb begin
    y4 = d0;
  end
endmodule
