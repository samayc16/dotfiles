# 20 · Constrained random

**Concepts:** `rand` fields, `constraint` blocks, `inside`, implication `->`, `dist`, `randomize() with {}`.

Hand-written tests only cover what you thought of. **Constrained-random** stimulus describes the *legal space*
and lets the solver pick values, millions of them. That's how real bugs get found.

```systemverilog
class BusTxn;
  rand bit [15:0] addr;
  rand kind_e     kind;
  constraint c_align { addr[1:0] == 0; }
  constraint c_range { (kind != IDLE) -> addr inside {[16'h1000:16'h1FFF]}; }
  constraint c_mix   { kind dist { READ := 4, WRITE := 4, IDLE := 1 }; }
endclass

t.randomize();                              // obey every constraint
t.randomize() with { kind == WRITE; };      // ...plus an inline one, for a directed test
```

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `rand bit [7:0] x;` | `randomize()` chooses a value for this field | `rand bit [7:0] size;` |
| `constraint name { e1; e2; }` | rules every `randomize()` result must obey | `constraint c_even { size[0] == 0; }` |
| `x inside {[lo:hi]}` | x lies in the range (or a set: `{1, 3, 5}`) | `size inside {[4:12]}` |
| `(c) -> e` | implication: whenever `c` is true, `e` must be too | `(mode == FAST) -> size inside {[4:12]};` |
| `x dist { A := 3, B := 1 }` | weighted choice: A is 3x as likely as B | `mode dist { SLOW := 1, FAST := 3 };` |
| `t.randomize()` | solve the constraints; returns 1 on success, 0 if they contradict | `t.randomize() == 1` |
| `t.randomize() with { ... }` | add extra constraints for this one call | `j.randomize() with { mode == SLOW; }` |
| `typedef enum bit [1:0]` | an enum stored in 2-state bits | |

**Your task:** add constraints to `BusTxn` so every result obeys the four rules in `txn_pkg.sv`, while still
spreading over many addresses (don't over-constrain!).

Under the hood Verilator hands constraints to the **z3** SMT solver at runtime (`brew install z3`).
**Check:** `learn check`
