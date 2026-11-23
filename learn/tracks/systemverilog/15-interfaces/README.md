# 15 · Interfaces and modports

**Concepts:** `interface`, `modport`, valid/ready handshakes (the heart of AXI-Stream and friends).

Real buses have dozens of signals. An **interface** bundles them so a single port carries the whole bus, and
**modports** say which side drives which signal:

```systemverilog
interface stream_if (input logic clk);
  logic valid, ready; logic [7:0] data;
  modport source(output valid, data, input  ready, clk);
  modport sink  (input  valid, data, clk, output ready);
endinterface

module summer (stream_if.sink s, ...);   // this module is a sink
  assign s.ready = ...;                  // only `ready` may be driven from here
```

**Handshake rule:** a beat moves on a rising edge where **valid && ready**. The source holds `valid` and `data`
steady until that happens; the sink can stall with `ready = 0`.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `interface i #(...) (input logic clk); ... endinterface` | a bundle of signals with its own parameters and ports | `stream_if.sv` |
| `modport m (input a, output b);` | one side's view of the bundle, directions as seen from that side | `modport monitor (input valid, ready, data, clk);` |
| `stream_if.sink s` (a port) | a module port carrying the whole interface, through one modport | `bus_if.monitor m` |
| `s.valid` | a signal inside the interface port | `m.ready` |
| `stream_if bus (clk);` (in `tb.sv`) | an interface is instantiated like a module | |
| `16'(x)` | widen 8-bit data to 16 bits before adding it to a 16-bit sum | `total + 16'(m.data)` |

**Your task:** add the `sink` modport to `stream_if.sv`, then make `summer.sv` accept beats and keep a running
`sum` and `beats` count. (This exercise opens `summer.sv`. Open the interface too: `:e stream_if.sv`.)

**Waveforms:** `WAVES=1 learn check` → `surfer wave.vcd`, and add `bus.valid`, `bus.ready`, `bus.data`.
