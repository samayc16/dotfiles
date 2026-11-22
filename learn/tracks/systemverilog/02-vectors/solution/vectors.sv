// Exercise 02 · Vectors (reference solution)
module vectors (
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    output logic [7:0]  both,
    output logic [7:0]  swapped,
    output logic        parity,
    output logic        all_ones,
    output logic        any_set,
    output logic [15:0] sign_extended,
    output logic [7:0]  reversed
);
  assign both          = a & b;
  assign swapped       = {a[3:0], a[7:4]};
  assign parity        = ^a;
  assign all_ones      = &a;
  assign any_set       = |a;
  assign sign_extended = {{8{a[7]}}, a};
  assign reversed      = {<<{a}};
endmodule
