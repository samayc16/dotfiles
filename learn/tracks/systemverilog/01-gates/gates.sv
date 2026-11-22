// Exercise 01 · Logic gates
// Replace each 1'b0 with the right expression, then run: learn check
module gates (
    input  logic a,
    input  logic b,
    output logic y_and,
    output logic y_or,
    output logic y_xor,
    output logic y_nand,
    output logic y_not_a
);
  assign y_and   = 1'b0;  // TODO: a AND b
  assign y_or    = 1'b0;  // TODO: a OR b
  assign y_xor   = 1'b0;  // TODO: a XOR b
  assign y_nand  = 1'b0;  // TODO: NOT (a AND b)
  assign y_not_a = 1'b0;  // TODO: NOT a
endmodule
