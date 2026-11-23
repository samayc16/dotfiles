# 07 · Flip-flops and resets

**Concepts:** `always_ff`, nonblocking assignment `<=`, asynchronous vs. synchronous reset, clock enable.

Until now everything was **combinational**: outputs follow inputs. A **flip-flop** remembers: it copies
`d` to `q` only at the rising clock edge.

```systemverilog
always_ff @(posedge clk or negedge rst_n) begin   // async reset: in the sensitivity list
  if (!rst_n) q <= '0;                             // ...and checked first
  else if (en) q <= d;                             // no else -> q holds its value
end

always_ff @(posedge clk) begin                     // sync reset: only the clock edge matters
  if (srst) q <= 8'hFF;
  else      q <= d;
end
```

* Use **`<=`** in `always_ff`: every flop samples its inputs at the same instant, then all update together.
* `_n` is the usual suffix for active-low signals.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `always_ff @(posedge clk)` | a block of flip-flops: it only acts at the clock's rising edge | |
| `@(posedge clk or negedge rst_n)` | sensitivity list: also act the moment `rst_n` falls (async reset) | |
| `q <= d;` | nonblocking: every right side is read first, then all flops update together | `x <= y; y <= x;` swaps them |
| `=` vs `<=` | `=` in `always_comb`, `<=` in `always_ff`. Mixing them causes sim/synthesis mismatches | |
| `!x` vs `~x` | logical NOT ("is x zero?", 1 bit) vs bitwise NOT (flip every bit) | `!rst_n`; `~4'b0100` → `4'b1011` |
| `if ... else if ... else` | a priority chain: the first true condition wins | |
| (no final `else`) | in `always_ff`, a register that isn't assigned keeps its old value | `else if (tick) led <= ~led;` |

**Your task:** add the async reset + enable to `q_async` and the sync reset to `q_sync`.

**Waveforms help here:** `WAVES=1 learn check`, then `surfer wave.vcd` and look at `rst_n` vs `q_async`.
The async reset clears `q_async` between clock edges.
