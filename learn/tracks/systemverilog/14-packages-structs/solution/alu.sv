// Exercise 14 · ALU (reference solution)
module alu
  import cpu_pkg::*;
(
    input  logic [7:0] a,
    input  instr_t     instr,
    output logic [7:0] y
);
  always_comb begin
    unique case (instr.op)
      OP_ADD:  y = a + instr.imm;
      OP_SUB:  y = a - instr.imm;
      OP_AND:  y = a & instr.imm;
      OP_OR:   y = a | instr.imm;
      OP_XOR:  y = a ^ instr.imm;
      OP_SHL:  y = a << instr.shamt;
      OP_SHR:  y = a >> instr.shamt;
      OP_PASS: y = instr.imm;
      default: y = '0;
    endcase
  end
endmodule
