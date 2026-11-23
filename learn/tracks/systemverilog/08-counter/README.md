# 08 · Counter

**Concepts:** register + next-state logic, priorities in `if/else if`, wrap-around, sized constants.

A counter is a register that loads `count + 1` every clock. Real ones need more:

| priority | input | effect on the next clock edge |
|---|---|---|
| 1 | `rst_n = 0` | `count = 0` (asynchronous: immediately) |
| 2 | `load = 1` | `count = load_val` |
| 3 | `en = 1` | `count + 1`, or `0` after `MAX` |
| - | otherwise | hold |

`tc` (terminal count) is **combinational**: `en && count == MAX`. It's high during the cycle *before* the
counter wraps, which is exactly when a second counter (tens digit!) should increment. Chaining counters through
`tc` is how clocks and timers are built.

Width tip: `count == MAX` compares a 4-bit signal with a 32-bit `int`. Verilator warns. Make a sized copy:
`localparam logic [W-1:0] MaxVal = W'(MAX);`

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `#(parameter int W = 4, parameter int MAX = 9)` | several parameters, separated by commas | |
| `localparam int X = ...;` | a constant computed inside the module; can't be overridden from outside | `localparam int Half = DEPTH / 2;` |
| `localparam logic [W-1:0] X = W'(V);` | a constant with an exact width (the cast makes it W bits) | `localparam logic [3:0] Top = 4'(12);` |
| `x + 1'b1` | add a 1-bit one, so no 32-bit `int` sneaks into the expression | `level + 1'b1` |
| `c ? a : b` after `<=` | the ternary works on the right of `<=` too | `level <= (level == Top) ? level : level + 1'b1;` (saturate) |
| `%Warning-WIDTH...` | Verilator lint: operands have different widths. Fix it with sized constants | |

**Your task:** finish `counter.sv`. The testbench builds a 0-9 and a 0-99 counter from the same code.
