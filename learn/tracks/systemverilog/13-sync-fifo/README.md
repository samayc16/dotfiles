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

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `logic [W-1:0] mem[DEPTH];` | unpacked array: DEPTH separate W-bit words, i.e. a memory | `logic [7:0] regs[16];` |
| `mem[i]` | read or write one word | `regs[3] <= 8'h42;` |
| several `always_ff` blocks | each is its own group of flops; each signal still has one driver | |
| `case ({x, y})` | switch on several bits at once by concatenating them | `case ({rd, wr}) 2'b10: ...` |
| `logic [15:0] q[$]` | a **queue** (testbench only): grows and shrinks at runtime. The checker's model is one | |

**Your task:** finish `fifo.sv`: `do_push`/`do_pop`, the memory write, both pointers, `count`, `full` and
`empty` (the TODO lists every rule).

**Check:** `learn check`. Your FIFO runs against a queue model (`logic [15:0] q[$]`) for 600+ cycles.
**Waveforms:** `WAVES=1 learn check` → `surfer wave.vcd`
