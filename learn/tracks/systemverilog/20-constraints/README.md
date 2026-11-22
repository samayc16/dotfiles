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

**Your task:** add constraints to `BusTxn` so every result obeys the four rules in `txn_pkg.sv`, while still
spreading over many addresses (don't over-constrain!).

Under the hood Verilator hands constraints to the **z3** SMT solver at runtime (`brew install z3`).
**Check:** `learn check`
