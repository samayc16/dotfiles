# 01 · Logic gates

**Concepts:** modules and ports, `logic`, continuous assignment (`assign`), bitwise operators.

Hardware isn't a program that runs top to bottom. A module describes **wires and gates that all exist at
once**. `assign y = a & b;` doesn't mean "compute once". It means "y is permanently wired to the output of an
AND gate".

## SystemVerilog in 2 minutes

How to read a design file:

```systemverilog
// a line comment               /* a block comment */
module lamp (               // module <name> ( <ports> );
    input  logic btn,       // direction, type, name; commas BETWEEN ports...
    output logic led        // ...but none after the last one
);                          // the port list ends with );
  assign led = btn;         // the body: every statement ends with ;
endmodule                   // no ; after endmodule
```

- **Every line exists at once.** The order of the `assign` lines doesn't matter: they're all wires.
- **4-state signals:** a `logic` bit is `0`, `1`, `x` (unknown, e.g. never driven) or `z` (disconnected).
- **`learn check`** compiles your file plus a read-only testbench (`tb.sv`: a module that drives the inputs
  and checks the outputs) with Verilator, then runs the simulation.

A failing run (real output, trimmed). `%Warning` lint lines are tips, never failures:

```text
Lint (2 warnings in your code, not fatal):
  %Warning-UNUSEDSIGNAL: gates.sv:4:18: Signal is not used: 'a'
✗ simulation failed:
  FAIL a=0 b=1: y_or: got 0 (0x0), expected 1 (0x1)
```

A passing run ends with `✓ All checks passed!`. A **compile error** stops everything and points at
`file:line:column`:

```text
✗ Does not compile yet:
%Error: gates.sv:13:3: syntax error, unexpected assign, expecting ',' or ';'
```

A missing `;` is reported at the **next** statement, so look one line up.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `module m (...); ... endmodule` | one block of hardware and its ports | `lamp` above |
| `input logic x` / `output logic y` | a 1-bit port: direction, type, name | `input logic btn` |
| `assign y = expr;` | continuous assignment: `y` is wired to `expr` forever | `assign led = btn;` |
| `1'b0` | sized literal: *width* `'` *base* *digits*; base `b` binary, `h` hex, `d` decimal | `1'b1`, `4'b1010`, `8'hFF` |
| `&` | AND gate | `x & y` |
| `\|` | OR gate | `x \| y` |
| `^` | XOR gate | `x ^ y` |
| `~` | NOT gate | `~x` |
| `( )` | grouping: the inside is computed first | NOR: `~(x \| y)` |
| `gates dut (.*);` | (in `tb.sv`) an *instance* named `dut` of module `gates`; `.*` connects each port to the signal with the same name | `lamp u_lamp (.*);` |

**Your task:** in `gates.sv`, replace each `1'b0` with the right expression. (`1'b0` means "a 1-bit value, written
in binary, equal to 0".)

**Check:** `learn check`. It compiles your module with a read-only testbench using Verilator and tries all
four input combinations. Verilator's `-Wall` lint warnings about *your* code are shown as tips, but they never
fail the check.

**Explore:** open `tb.sv` next to your design: `gates dut (.*);` connects every port to the signal of the same
name. That's how a testbench "plugs in" the design under test (DUT).
