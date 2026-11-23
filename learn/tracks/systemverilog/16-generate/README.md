# 16 · Generate: a ripple-carry adder

**Concepts:** `generate` for-loops, `genvar`, named generate blocks, parameterized structure.

`for` inside `always_comb` repeats *logic*. A **generate** `for` at module level repeats *structure*:
instances, assigns, always blocks. It's how you build N-bit things out of 1-bit cells, arrays of identical
channels, and pipelines of configurable depth.

```systemverilog
for (genvar i = 0; i < W; i++) begin : g_bit     // the name creates hierarchy: g_bit[0], g_bit[1], ...
  full_adder fa (.a(a[i]), .b(b[i]), .cin(c[i]), .s(sum[i]), .cout(c[i+1]));
end
```

The carry *ripples* from bit 0 to bit W-1 through the `c` vector. (That's also why ripple adders are slow:
the critical path is W full adders long.)

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `for (genvar i = 0; i < W; i++) begin : name ... end` | generate loop at module level: stamps out W copies of the body | see below |
| `genvar i` | the generate loop variable; it only exists at compile time | |
| `begin : g_bit` | a label; the copies are named `g_bit[0]`, `g_bit[1]`, ... | |
| `u8.g_bit[2].fa` | hierarchical name: a path down through instances and blocks | `tb.dut.g_inv[3].inv` |
| `logic [W:0] c` | W+1 bits, indexes 0..W | |

```systemverilog
for (genvar k = 0; k < 4; k++) begin : g_inv
  inverter inv (.a(x[k]), .y(nx[k]));      // 4 instances: g_inv[0].inv ... g_inv[3].inv
end
```

**Your task:** use the read-only `full_adder.sv` to build `ripple_adder`. The testbench reaches into
`u8.g_bit[2].fa` by hierarchical name, so keep the names `g_bit` and `fa`.

**Explore:** `WAVES=1 learn check` → `surfer wave.vcd`; the hierarchy panel shows every `g_bit[i]`.
