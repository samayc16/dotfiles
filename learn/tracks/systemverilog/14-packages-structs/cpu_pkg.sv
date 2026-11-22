// Exercise 14 · Packages, packed structs and unions
package cpu_pkg;
  typedef enum logic [2:0] {
    OP_ADD,   // y = a + imm
    OP_SUB,   // y = a - imm
    OP_AND,   // y = a & imm
    OP_OR,    // y = a | imm
    OP_XOR,   // y = a ^ imm
    OP_SHL,   // y = a << shamt
    OP_SHR,   // y = a >> shamt
    OP_PASS   // y = imm
  } opcode_t;

  // TODO: a 16-bit packed struct named instr_t, fields MSB first:
  //   [15:13] op     (opcode_t)
  //   [12:8]  shamt  (logic [4:0], shift amount)
  //   [7:0]   imm    (logic [7:0], immediate operand)

  // TODO: a packed union named instr_u, so the same 16 bits can be read as
  //   .f   (an instr_t)  or  .raw (logic [15:0])
endpackage
