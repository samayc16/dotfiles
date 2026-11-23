# 05 · Priority encoder

**Concepts:** `always_comb` with default assignments, `for` loops that describe parallel hardware.

An interrupt controller has 8 request lines. When several fire at once, the **highest-numbered** one wins.
Output its index and a `valid` flag.

| req | idx | valid |
|---|---|---|
| `8'b0000_0000` | (don't care) | 0 |
| `8'b0000_0101` | 2 | 1 |
| `8'b1000_0001` | 7 | 1 |

A `for` loop in `always_comb` doesn't run over time. Synthesis **unrolls** it into 8 copies of the logic. The
"last assignment wins" rule of procedural code gives you priority for free:

```systemverilog
always_comb begin
  y = '0;                      // default
  for (int i = 0; i < 8; i++)
    if (x[i]) y = ...;         // a later i overrides an earlier one
end
```

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `for (int i = 0; i < N; i++)` | loop; in hardware it's unrolled into N copies | `for (int i = 0; i < 4; i++)` |
| `if (c) ... else ...` | choose; a `begin ... end` arm can hold several statements | see below |
| `x[i]` | bit-select with a variable index | `flags[i]` |
| `3'(i)` | cast the 32-bit `int` loop variable down to 3 bits | `2'(i)` |
| `8'b0000_0101` | `_` is only a visual separator inside literals | `16'b1010_0000_1111_0000` |
| `casez` with `?` | a `case` where `?` in a label means "don't care" | `4'b1???` matches `1000` to `1111` |

```systemverilog
always_comb begin
  found = 1'b0;                  // default first
  for (int i = 0; i < 4; i++)
    if (flags[i]) found = 1'b1;  // "is any of the 4 flags set?"
end
```

**Your task:** finish `prio_enc.sv`. Alternative: try `casez (req)` with `8'b1???????` patterns.

**Check:** `learn check` (all 256 inputs).
