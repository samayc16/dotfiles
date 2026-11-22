# 11 · Traffic light

**Concepts:** FSMs with timers, enums from a `package` on module ports, parameters, helper functions.

```text
reset -> RED (RED_T cycles) -> GREEN (GREEN_T) -> YELLOW (YELLOW_T) -> RED -> ...
```

Most real FSMs don't move on every clock. They wait in a state until a **timer** expires. Keep a `timer` that
counts the cycles spent in the current colour. When it reaches *duration - 1*, change colour and clear it.

The colours live in `traffic_pkg.sv` (read-only), and the module imports them in its header:
`module traffic import traffic_pkg::*; #(...) (...)`. Packages are how you share types between modules
and testbenches.

Nice pattern: small `function automatic`s inside the module (e.g. `last_cycle(color)` and `after(color)`)
keep the `always_ff` readable.

**Your task:** finish `traffic.sv`. The testbench checks a 4/5/2 light and a 1/1/1 light from the same code.
**Waveforms:** `WAVES=1 learn check` → `surfer wave.vcd`
