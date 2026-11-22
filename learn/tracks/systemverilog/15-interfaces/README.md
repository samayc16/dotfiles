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

**Your task:** add the `sink` modport to `stream_if.sv`, then make `summer.sv` accept beats and keep a running
`sum` and `beats` count. (This exercise opens `summer.sv`. Open the interface too: `:e stream_if.sv`.)

**Waveforms:** `WAVES=1 learn check` → `surfer wave.vcd`, and add `bus.valid`, `bus.ready`, `bus.data`.
