# 04 · Parameterized adder

**Concepts:** `parameter`, width-generic code `[W-1:0]`, width extension, casts `N'(x)`, carry vs. signed
overflow.

```systemverilog
module adder #(parameter int W = 8) (input logic [W-1:0] a, ...);
adder #(.W(16)) u16 (...);   // the same code, instantiated 16 bits wide
```

Adding two W-bit numbers can produce a W+1-bit result. Widen the operands so the carry isn't lost:
`{1'b0, a} + {1'b0, b}` is W+1 bits wide, so `{cout, sum} = ...` captures it. (`(W+1)'(cin)` casts cin to W+1
bits too, which keeps Verilator's width lint quiet.)

* **cout**: unsigned overflow, the carry out of the top bit.
* **overflow**: signed overflow. Adding two positives gives a "negative" result, or two negatives give a
  "positive" one. Example: `8'h7F + 8'h01 = 8'h80` (127 + 1 = -128).

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `module m #(parameter int W = 8) (...)` | a parameter: a compile-time constant with a default, settable per instance | `module ram #(parameter int DEPTH = 16) (...)` |
| `int` | 32-bit signed integer; used for parameters and loop counters | `parameter int DEPTH = 16` |
| `[W-1:0]` | widths can be expressions of parameters | `logic [DEPTH-1:0] valid_bits;` |
| `m #(.W(16)) u (...);` | instantiate with a parameter overridden, by name | `ram #(.DEPTH(4)) small_ram (...);` |
| `.port(signal)` | named port connection | `ram r0 (.clk(sys_clk), .din(data));` |
| `{c, s} = ...` | concatenation on the **left**: the top bit goes to `c`, the rest to `s` | `assign {hi, lo} = 8'hA5;` gives `hi = 4'hA`, `lo = 4'h5` |
| `N'(x)` | width cast: resize `x` to N bits (unsigned values get zero-extended) | `5'(4'hF)` → `5'b01111` |
| `==` `!=` `&&` `\|\|` | compare, logical AND / OR: each gives a 1-bit answer | `(x == y) && (x != 0)` |
| `x[W-1]` | the MSB: in two's complement it's the sign bit | `8'h80` has MSB 1, so it's −128 |

**Your task:** implement `sum`, `cout` and `overflow` for any width `W`.

**Check:** `learn check`. The testbench instantiates your adder twice, at W=8 and W=16.
