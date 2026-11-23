# 21 · Mailboxes, fork/join, events

**Concepts:** `mailbox #(T)`, `put`/`get`/`try_get`, `fork ... join / join_any / join_none`,
`disable fork`, named `event`s, the guarded-fork idiom.

Testbench components run **in parallel**: a generator makes transactions, a driver wiggles pins, a monitor
watches, a scoreboard checks. They talk through **mailboxes**, which are thread-safe FIFOs between processes.

```systemverilog
fork  a();  b();  join        // wait for both
fork  a();  b();  join_any    // wait for the first; the other keeps running...
disable fork;                 // ...unless you kill it
fork  a();  join_none         // start it and move on

-> ev;      // trigger an event
@(ev);      // wait for it
```

`disable fork` kills **every** child of the current process. Wrap the race in its own `fork begin ... end join`
so you don't accidentally kill unrelated threads.

Note: these are class tasks storing results in members (`sum`, `got_event`). SystemVerilog forbids writing an
automatic task's `output`/`ref` argument after a delay, and member variables are the idiomatic way around it.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `task t(args); ... endtask` | like a function, but may consume time (`#`, `@`, blocking calls); no return value | |
| `#1;` / `#(n);` | wait 1 / n time units | `#5;` |
| `mailbox #(int) mb = new();` | a thread-safe FIFO; `#(int)` = it carries `int`s | `mailbox #(string) names = new();` |
| `mb.put(x)` / `mb.get(x)` | send / receive. `get` waits until an item arrives and writes it into `x` | `box.get(v);` |
| `mb.try_get(x)` | like `get` but never waits: returns 0 if empty | |
| `repeat (n) begin ... end` | do it n times | `repeat (3) begin #2; box.put(7); end` |
| `fork A; B; join` | run A and B in parallel; continue when both finish | |
| `join_any` / `join_none` | continue when the first finishes / immediately | |
| `disable fork;` | kill the still-running children of this thread | |
| `event e;` · `-> e;` · `@(e);` | declare / trigger / wait for an event | `@(ping);` |

**Your task:** implement the four tasks in `workers_pkg.sv`. The testbench also checks *timing*: running
things in parallel must actually be parallel.
