// Read-only: a 1-bit full adder for exercise 16.
module full_adder (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic s,
    output logic cout
);
  assign s    = a ^ b ^ cin;
  assign cout = (a & b) | (cin & (a ^ b));
endmodule
