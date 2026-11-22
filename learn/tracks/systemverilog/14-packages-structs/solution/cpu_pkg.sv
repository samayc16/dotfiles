// Exercise 14 · Packages, structs, unions (reference solution)
package cpu_pkg;
  typedef enum logic [2:0] {
    OP_ADD,
    OP_SUB,
    OP_AND,
    OP_OR,
    OP_XOR,
    OP_SHL,
    OP_SHR,
    OP_PASS
  } opcode_t;

  typedef struct packed {
    opcode_t    op;     // [15:13]
    logic [4:0] shamt;  // [12:8]
    logic [7:0] imm;    // [7:0]
  } instr_t;

  typedef union packed {
    instr_t      f;
    logic [15:0] raw;
  } instr_u;
endpackage
