# 13 · Synchronous FIFO

**Concepts:** memories (unpacked arrays), read/write pointers, wrap-around for any depth, status flags.

A FIFO (first in, first out) decouples a producer from a consumer. It's in every SoC: between clock domains,
in front of DMA engines, inside network switches.

```text
 push/din -> [ mem[0] mem[1] mem[2] mem[3] ] -> dout (oldest), pop
               ^rd_ptr        ^wr_ptr          count = 2
```

Rules:
* `do_push = push && !full`, `do_pop = pop && !empty`. Both look at the state **before** the clock edge,
  so push+pop on a full FIFO pops but doesn't push.
* `dout` always shows the oldest entry (show-ahead): `assign dout = mem[rd_ptr];`
* Pointers wrap after `DEPTH-1`. Don't rely on natural overflow: the testbench uses `DEPTH=5`.
* `count` goes up by 1, down by 1, or stays (push and pop together).

Memory without reset: put the write in its own `always_ff @(posedge clk)`. Storage doesn't need resetting,
only the pointers and count do.

**Check:** `learn check`. Your FIFO runs against a queue model (`logic [15:0] q[$]`) for 600+ cycles.
**Waveforms:** `WAVES=1 learn check` → `surfer wave.vcd`
