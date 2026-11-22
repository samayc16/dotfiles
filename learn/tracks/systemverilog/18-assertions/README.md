# 18 · Assertions (SVA)

**Concepts:** immediate `assert`, concurrent `assert property`, implication `|->` / `|=>`, delay ranges
`##[1:3]`, `$rose`, `$past`, `$onehot0`, `disable iff`.

Testbenches check *outputs*. **Assertions** check *rules*, every cycle, forever, and point at the exact time
a rule broke. They're how verification engineers encode a protocol spec.

```systemverilog
always_comb a_onehot: assert ($onehot0(gnt));        // immediate: checked whenever gnt changes

a_resp: assert property (@(posedge clk) disable iff (!rst_n)
          $rose(req) |-> ##[1:3] ack);               // concurrent: when req rises, ack within 1..3 cycles

req && !ack |=> req      // |=>  "then, starting NEXT cycle"
ack |-> $past(req)       // $past(x) is x one clock earlier
```

**Your task:** write the four named assertions described in `hs_checker.sv`. The check runs five simulations:
`good` (legal traffic only: nothing may fire) and four `bad_*` runs, each injecting one violation that
**its** assertion must catch. An empty checker passes `good` but misses all four bugs, and so does a checker
that's too loose.

**Waveforms:** `WAVES=1 learn check` → `surfer wave.vcd` to see exactly where a property failed.
