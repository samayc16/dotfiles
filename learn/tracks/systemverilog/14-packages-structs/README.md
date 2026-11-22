# 14 · Packages, packed structs, unions

**Concepts:** `package`, `import`, `typedef struct packed`, `typedef union packed`, decoding instruction words.

Raw bit-slicing (`instr[12:8]`) gets unreadable fast. A **packed struct** names the fields of a bit vector.
It is still exactly 16 bits, so it can go on ports, in flops, anywhere a vector can:

```systemverilog
typedef struct packed {
  opcode_t    op;     // first field = most significant bits
  logic [4:0] shamt;
  logic [7:0] imm;
} instr_t;            // $bits(instr_t) == 16

instr_t i = '{op: OP_ADD, shamt: 0, imm: 8'd5};   // assignment pattern by name
if (i.op == OP_SHL) ...
```

A **packed union** gives the same bits two names: `u.raw = 16'hBEEF;` then read `u.f.op`. Packages hold the
shared types so the ALU, the decoder and the testbench all agree.

**Your task:** define `instr_t` and `instr_u` in `cpu_pkg.sv`, then implement the ALU in `alu.sv`.
(This exercise opens `alu.sv`. Open `cpu_pkg.sv` too: `:e cpu_pkg.sv`.)

**Check:** `learn check`. The testbench checks the struct layout with `$bits`, then runs 400 random
instructions.
