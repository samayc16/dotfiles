# 22 · Boss: a UVM-style testbench

**Concepts:** virtual interfaces, layered testbench components, monitors, scoreboards with reference models,
mailboxes between components, bug injection.

This is the architecture of every serious verification environment (UVM is a library that standardizes it):

```text
             +--------+   pins   +------+   pins   +---------+  mailbox  +------------+
  stimulus ->| Driver |--------->| FIFO |--------->| Monitor |---------->| Scoreboard |
             +--------+          +------+          +---------+           +------------+
                                                                          reference model:
                                                                          bit [7:0] model[$]
```

* The **driver** turns transactions into pin wiggles (done for you).
* The **monitor** only *watches* the pins and reports what actually happened. It never drives anything.
* The **scoreboard** predicts what *should* happen with a simple model (a queue), and compares.
* `virtual fifo_if vif` is how a class (dynamic, created at runtime) reaches a static interface instance.

Sampling trick: right after `@(posedge vif.clk)` the flip-flops haven't updated yet, so you see the values
that were present **at** the edge: exactly what the FIFO acted on.

Verilator note: declare mailboxes of your own classes as `std::mailbox #(Observation)`, as in the
starter. The plain `mailbox` spelling trips a Verilator parser quirk in this file.

**Your task:** write `Monitor.run()` and `Scoreboard.run()` in `fifo_tb_pkg.sv`. The check runs twice:
`good` (a correct FIFO: zero mismatches allowed) and `buggy` (`fifo.sv` corrupts one slot: your scoreboard
has to notice). A scoreboard that never complains fails the second run.

**Debugging:** `WAVES=1 learn check` → `surfer wave.vcd`. When you're done, you've written a real testbench.
Next stop: the UVM library itself (`uvm-core` on GitHub) runs the same pattern with factories and phases.
