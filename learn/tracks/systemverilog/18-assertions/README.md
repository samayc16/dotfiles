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

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `label: assert (expr) else $error(...);` | immediate assertion, checked when the line runs (inside `always_comb` or `initial`); the label names it in failures | `a_small: assert (level < 8'd200);` |
| `$onehot0(v)` / `$onehot(v)` | at most one / exactly one bit of `v` set | `$onehot0(4'b0100)` → `1` |
| `assert property (@(posedge clk) P);` | concurrent assertion: P is checked at every clock edge | |
| `disable iff (!rst_n)` | don't check while in reset | |
| `A \|-> B` | when A holds at an edge, B must hold starting at that **same** edge | `start \|-> busy` |
| `A \|=> B` | ...B must hold starting at the **next** edge | `start \|=> busy` |
| `##[m:n] B` | B within m to n cycles (`##2` = exactly 2) | `$rose(go) \|-> ##[2:4] done` |
| `$rose(x)` | x was 0 at the previous edge and is 1 now | `$rose(start)` |
| `$past(x)` | the value x had at the previous edge | `done \|-> $past(go)` |
| `$error("...%b", v)` | report a failure; `%b` binary, `%0d` decimal, `%h` hex | `$error("g=%b", g)` |

**Your task:** write the four named assertions described in `hs_checker.sv`. The check runs five simulations:
`good` (legal traffic only: nothing may fire) and four `bad_*` runs, each injecting one violation that
**its** assertion must catch. An empty checker passes `good` but misses all four bugs, and so does a checker
that's too loose.

**Waveforms:** `WAVES=1 learn check` → `surfer wave.vcd` to see exactly where a property failed.
