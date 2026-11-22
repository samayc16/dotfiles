# 12 · Debouncer + edge detector

**Concepts:** counters as timers, registered vs. combinational outputs, edge detection.

Mechanical buttons **bounce**: one press looks like `0 1 0 1 1 0 1 1 1 1` to a fast clock. A debouncer only
believes a new level after it has been stable for `N` cycles.

```text
noisy : 0 1 0 1 1 1 1 1 1 0 0 0 0 0
clean : 0 0 0 0 0 0 0 1 1 1 1 1 1 0     (N = 4)
rise  : 0 0 0 0 0 0 0 1 0 0 0 0 0 0
```

**Edge detection** is a one-liner once you keep the previous value: `rise = clean & ~clean_q`, where `clean_q`
is `clean` delayed by one flip-flop. You'll use this pattern constantly: detecting a start bit, a button press,
a valid going high.

The rules are written at the top of `debounce.sv`. Follow them exactly: the testbench compares every cycle
with a model.

Width tip: the counter needs `$clog2(N+1)` bits; compare it with a sized constant (`CW'(N - 1)`).

**Waveforms:** `WAVES=1 learn check` → `surfer wave.vcd`, then compare `noisy`, `clean`, `rise`.
