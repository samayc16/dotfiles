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

**Your task:** finish `prio_enc.sv`. Alternative: try `casez (req)` with `8'b1???????` patterns.

**Check:** `learn check` (all 256 inputs).
