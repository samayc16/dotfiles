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

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `typedef struct packed { ... } t;` | named fields over one bit vector; the first field is the MSBs | see below |
| `x.field` | read or write one field | `hd.len` |
| `'{f: v, ...}` | assignment pattern: build a struct value field by field | `hd = '{kind: 4'h3, len: 8'd20};` |
| `typedef union packed { ... } u;` | several names for the same bits (every member must be the same width) | see below |
| `$bits(t)` | the width of a type or signal | `$bits(hdr_t)` → `12` |
| `a << n` | shift by a variable amount | `x >> amt` |

```systemverilog
typedef struct packed {
  logic [3:0] kind;    // bits [11:8]
  logic [7:0] len;     // bits [7:0]
} hdr_t;

typedef union packed {
  hdr_t        h;      // read it as fields: u.h.kind
  logic [11:0] bits;   // or as a plain vector: u.bits
} hdr_u;
```

**Your task:** define `instr_t` and `instr_u` in `cpu_pkg.sv`, then implement the ALU in `alu.sv`.
(This exercise opens `alu.sv`. Open `cpu_pkg.sv` too: `:e cpu_pkg.sv`.)

**Check:** `learn check`. The testbench checks the struct layout with `$bits`, then runs 400 random
instructions.
