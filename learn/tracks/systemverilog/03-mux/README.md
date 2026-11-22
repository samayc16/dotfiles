# 03 · Multiplexers

**Concepts:** the ternary operator, `always_comb`, `case` / `unique case`.

A multiplexer (mux) picks one of several inputs based on a select signal. It's the hardware `if`.

```systemverilog
assign y = sel ? b : a;          // 2:1 mux in one line

always_comb begin                // combinational logic described procedurally
  unique case (sel)              // `unique`: the cases don't overlap and every value is covered
    2'd0: y = a;
    2'd1: y = b;
    default: y = '0;
  endcase
end
```

`always_comb` re-evaluates whenever any input changes, just like `assign`. **Every path must assign the output**,
otherwise you have described a latch (memory) by accident. Verilator warns about that (`LATCH`).

**Your task:** implement `y2` with the ternary operator and `y4` with a `case` in `always_comb`.

**Check:** `learn check`
