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

**Your task:** implement `sum`, `cout` and `overflow` for any width `W`.

**Check:** `learn check`. The testbench instantiates your adder twice, at W=8 and W=16.
