// Exercise 14 · An ALU that decodes an instruction struct
module alu
  import cpu_pkg::*;
(
    input  logic [7:0] a,
    input  instr_t     instr,
    output logic [7:0] y
);
  always_comb begin
    y = '0;
    // TODO: unique case (instr.op) - one arm per opcode (see the comments in cpu_pkg.sv)
  end
endmodule
