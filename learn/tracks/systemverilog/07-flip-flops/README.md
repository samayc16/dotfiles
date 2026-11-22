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

**Your task:** add the async reset + enable to `q_async` and the sync reset to `q_sync`.

**Waveforms help here:** `WAVES=1 learn check`, then `surfer wave.vcd` and look at `rst_n` vs `q_async`.
The async reset clears `q_async` between clock edges.
