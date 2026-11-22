// Exercise 02 · Vectors, slices, reduction and concatenation
// Each output has a TODO. Run: learn check
module vectors (
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    output logic [7:0]  both,           // bits set in BOTH a and b
    output logic [7:0]  swapped,        // a with its two nibbles (4-bit halves) swapped
    output logic        parity,         // 1 if a has an odd number of 1 bits
    output logic        all_ones,       // 1 if every bit of a is 1
    output logic        any_set,        // 1 if any bit of a is 1
    output logic [15:0] sign_extended,  // a as a signed number, widened to 16 bits
    output logic [7:0]  reversed        // a with bit order reversed (bit 0 <-> bit 7)
);
  assign both          = '0;  // TODO
  assign swapped       = '0;  // TODO: concatenation {.., ..} of two slices
  assign parity        = '0;  // TODO: reduction XOR
  assign all_ones      = '0;  // TODO: reduction AND
  assign any_set       = '0;  // TODO: reduction OR
  assign sign_extended = '0;  // TODO: replicate the sign bit: {N{bit}}
  assign reversed      = '0;  // TODO: streaming operator {<<{a}}
endmodule
