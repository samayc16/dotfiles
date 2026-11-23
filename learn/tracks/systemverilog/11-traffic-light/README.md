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

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `package p; ... endpackage` | a named bag of shared types and functions (no hardware) | `traffic_pkg.sv` |
| `import p::*;` | make everything in `p` visible; in a module header it sits between the name and `#(` | `module m import p::*; #(...) (...);` |
| `p::NAME` | `::` reaches one item of a package without importing it | `traffic_pkg::RED` |
| `output color_t light` | ports can have enum types | |
| `function automatic T f(args); ... endfunction` | a function returning a value of type `T`; call it like `f(x)` | see below |
| `return x;` | leave the function with this value | |
| `8'(RED_T - 1)` | cast an `int` expression to 8 bits | `4'(DEPTH - 1)` |

```systemverilog
function automatic logic [3:0] blink_len(mode_t m);
  unique case (m)
    OFF:     return 4'd0;
    ON:      return 4'd15;
    default: return 4'd3;
  endcase
endfunction
```

**Your task:** finish `traffic.sv`. The testbench checks a 4/5/2 light and a 1/1/1 light from the same code.
**Waveforms:** `WAVES=1 learn check` → `surfer wave.vcd`
