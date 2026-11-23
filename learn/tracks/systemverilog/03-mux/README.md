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

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `c ? x : y` | ternary: `x` when `c` is 1, else `y` | `assign big = turbo ? 8'd200 : 8'd5;` |
| `always_comb begin ... end` | combinational block: its statements run top to bottom whenever an input changes | see the block above |
| `begin ... end` | groups statements into one, like `{ }` in C | |
| `y = expr;` (inside a block) | blocking assignment: takes effect at once, so later lines see the new value | `t = x ^ y;  z = t & en;` |
| `case (s) ... endcase` | runs the arm whose label equals `s` | `case (mode) 2'd0: speed = 8'd0; ... endcase` |
| `unique case` | a promise that exactly one arm matches; simulators warn if it's broken | |
| `default:` | the arm for every value not listed | `default: speed = 8'd99;` |
| `2'd3` | sized **decimal** literal (`d`) | `3'd5` is `3'b101` |

**Your task:** implement `y2` with the ternary operator and `y4` with a `case` in `always_comb`.

**Check:** `learn check`
