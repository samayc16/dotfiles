// Exercise 01 · Logic gates (reference solution)
module gates (
    input  logic a,
    input  logic b,
    output logic y_and,
    output logic y_or,
    output logic y_xor,
    output logic y_nand,
    output logic y_not_a
);
  assign y_and   = a & b;
  assign y_or    = a | b;
  assign y_xor   = a ^ b;
  assign y_nand  = ~(a & b);
  assign y_not_a = ~a;
endmodule
