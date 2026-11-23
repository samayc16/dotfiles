# 10 · Sequence detector (FSM)

**Concepts:** `typedef enum`, finite state machines, the two-process FSM style, Moore outputs, overlapping
matches.

A serial line delivers one bit per clock. Raise `found` whenever the last four bits were `1 0 1 1`.
Overlaps count: `1011011` contains **two** matches.

```text
            1          0          1          1
   IDLE ------> S1 ------> S10 ------> S101 ------> S1011 (found=1)
```
Then work out the "fallback" edges. On a mismatch, how much of the pattern is *still* matched? From `S101`
a `0` gives `...1010`, whose tail `10` is the start of `1011`, so go to `S10`, not `IDLE`.

```systemverilog
typedef enum logic [2:0] {IDLE, S1, ...} state_t;   // named states, shown by name in waveforms
always_ff @(posedge clk or negedge rst_n) state <= rst ? IDLE : next;   // process 1: the register
always_comb begin                                                       // process 2: next-state logic
  next = state;
  unique case (state) ... endcase
end
assign found = (state == S1011);   // Moore: output depends only on the state
```

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `typedef enum logic [2:0] {A, B, C} t;` | a new type whose values have names (A=0, B=1, ...) stored in 3 bits | `typedef enum logic [1:0] {OFF, ON, BLINK} mode_t;` |
| `t state, next;` | declare signals of that type | `mode_t lamp, lamp_next;` |
| `A:` as a case label | case arms can be enum names | `OFF: ...` |
| `state == A` | compare with a named value | `lamp == ON` |
| two-process FSM | `always_ff` stores `state`; `always_comb` computes `next` | see below |

```systemverilog
always_comb begin
  lamp_next = lamp;                        // default: stay
  unique case (lamp)
    OFF:     if (press) lamp_next = ON;
    ON:      if (press) lamp_next = OFF;
    default: lamp_next = OFF;
  endcase
end
assign glowing = (lamp == ON);             // Moore output: depends on the state only
```

**Your task:** in `seq_det.sv`, fill in the `unique case` (one arm per state, `din` picks `next`) and the
`found` output.

**Check:** `learn check`. On a failure, the message shows the last four bits so you can trace the FSM by hand.
**Waveforms:** `WAVES=1 learn check` → `surfer wave.vcd`; surfer shows `state` by name.
