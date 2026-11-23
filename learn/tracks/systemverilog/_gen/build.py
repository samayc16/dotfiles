#!/usr/bin/env python3
"""Generate exercise.json + check.sh for every systemverilog exercise, and track.json.

Usage:  python3 -I learn/tracks/systemverilog/_gen/build.py

READMEs, starter files, solutions and testbenches are hand-written in each
exercise directory; this script only owns the metadata and the check wrappers.
"""

from __future__ import annotations

import json
from pathlib import Path

TRACK = Path(__file__).resolve().parent.parent
XP = {1: 10, 2: 20, 3: 30, 4: 40, 5: 60}

# dir, title, difficulty, concepts, files (learner-editable, compile order), hints, extra check settings
EXERCISES: list[dict] = [
    dict(dir="01-gates", title="Logic gates", d=1, concepts=["module", "assign", "& | ^ ~"],
         files=["gates.sv"],
         hints=["Each TODO comment names a gate; the README's New syntax table has the operator for each one.",
                "AND, OR and XOR sit between `a` and `b`. NOT is `~` in front of one signal. NAND is NOT applied to a whole AND, so group the AND in parentheses first.",
                "Same shapes on other names: `assign led = btn & en;` · `assign z = ~x;` · NOR: `assign n = ~(x | y);`",
                "Near-answer for the trickiest one: `assign y_nand = ~(a & b);`. The other four are one operator each."]),
    dict(dir="02-vectors", title="Vectors, slices, reductions", d=1,
         concepts=["[7:0] vectors", "slices", "{concat}", "{N{replicate}}", "reduction ^a &a |a", "{<<{a}}"],
         files=["vectors.sv"],
         hints=["Every TODO comment names the tool (slice, concatenation, reduction, replication, streaming); each has a row in the README's New syntax table.",
                "`both` is bitwise with two operands. `parity`, `all_ones`, `any_set` are reductions (one operand, 1-bit result). `swapped` glues two slices. `reversed` is the streaming operator.",
                "On a 16-bit `w`: byte swap `{w[7:0], w[15:8]}` · zero-extend to 24 bits `{{8{1'b0}}, w}` · any bit set `|w`.",
                "Sign extension = 8 copies of the sign bit, then `a`: `{{8{a[7]}}, a}`. Bit reverse: `{<<{a}}`."]),
    dict(dir="03-mux", title="Multiplexers", d=1, concepts=["ternary ?:", "always_comb", "unique case"],
         files=["mux.sv"],
         hints=["The README's code block is a mux written both ways; the starter comments say which one each output uses.",
                "`y2`: one ternary that picks `d1` when `sel2` is 1. `y4`: inside `always_comb`, a `unique case (sel4)` with one arm per value 0..3, each assigning `y4`.",
                "Other data: `assign speed = turbo ? 8'd200 : 8'd50;` · `unique case (mode) 2'd0: speed = 8'd0; 2'd1: speed = 8'd10; ... endcase`",
                "Near-answer: `assign y2 = sel2 ? d1 : d0;` and arms `2'd0: y4 = d0;` through `2'd3: y4 = d3;`."]),
    dict(dir="04-adder", title="Parameterized adder", d=2, concepts=["parameter", "width extension", "casts N'(x)", "overflow"],
         files=["adder.sv"],
         hints=["The README explains both outputs; the starter comment gives the formula `{cout, sum} = a + b + cin` and warns about widths.",
                "Make every operand W+1 bits so the carry has room: put a `1'b0` in front of `a` and `b`, and cast `cin` to W+1 bits. Overflow: compare the sign bits `[W-1]` of a, b and sum.",
                "4-bit example: `4'b1111 + 4'b0001` in 5 bits is `5'b10000` (carry 1, sum 0). Signed: `4'b0111 + 4'b0001` = `4'b1000`, 7+1 became -8: both inputs had MSB 0, the sum has MSB 1.",
                "Near-answer: `assign {cout, sum} = {1'b0, a} + {1'b0, b} + (W+1)'(cin);` and `overflow = (a[W-1] == b[W-1]) && (sum[W-1] != a[W-1]);`"]),
    dict(dir="05-priority-encoder", title="Priority encoder", d=2, concepts=["always_comb", "for loops in hardware", "default assignments"],
         files=["prio_enc.sv"],
         hints=["The README's code block is the pattern: defaults (already in the starter), then a `for` loop with an `if`.",
                "Loop i from 0 to 7. Whenever `req[i]` is 1, set `idx` to i and `valid` to 1. Later (higher) i overwrite earlier ones, so the highest set bit wins.",
                "Lowest-wins on a 4-bit `flags`, loop downwards: `for (int i = 3; i >= 0; i--) if (flags[i]) begin first = 2'(i); found = 1'b1; end`",
                "Near-answer: `for (int i = 0; i < 8; i++) if (req[i]) begin idx = 3'(i); valid = 1'b1; end`"]),
    dict(dir="06-hex-to-7seg", title="Hex to 7-segment", d=2, concepts=["case tables", "default", "bit ordering"],
         files=["hex7seg.sv"],
         hints=["The drawing at the top of `hex7seg.sv` names the segments, and `seg = {g, f, e, d, c, b, a}`: the rightmost bit of each literal is segment a.",
                "For each digit, list the lit segments, then write a 1 in those positions (g on the left, a on the right). One `case` arm per digit, like the 0 and 1 arms.",
                "Worked examples on other shapes: a minus sign (only g) is `7'b1000000`; an `L` (d, e, f) is `7'b0111000`.",
                "Near-answer for two digits: 2 lights a b d e g → `7'b1011011`; 7 lights a b c → `7'b0000111`. The testbench draws your shape next to the expected one."]),
    dict(dir="07-flip-flops", title="Flip-flops and resets", d=2, concepts=["always_ff", "nonblocking <=", "async vs sync reset", "enable"],
         files=["regs.sv"],
         hints=["Compare the starter with the README's code block: the async reset is in the sensitivity list, the sync one isn't.",
                "`q_async`: wake on `posedge clk` or `negedge rst_n`, check `!rst_n` first, then load `d` only when `en`. `q_sync`: keep `@(posedge clk)`; if `srst` load `8'hFF`, else `d`.",
                "Other data: `always_ff @(posedge clk or negedge rst_n) if (!rst_n) led <= 1'b0; else if (tick) led <= ~led;`",
                "Near-answer: `if (!rst_n) q_async <= 8'h00; else if (en) q_async <= d;` and `if (srst) q_sync <= 8'hFF; else q_sync <= d;`"]),
    dict(dir="08-counter", title="Counter", d=2, concepts=["registers + next-state logic", "wrap-around", "terminal count"],
         files=["counter.sv"],
         hints=["The README's priority table is the order of your `if / else if` chain; reset is already done.",
                "After reset: `else if (load)` takes `load_val`; `else if (en)` wraps to 0 at MAX or adds 1. `tc` is a plain `assign`. Compare against a sized `localparam` copy of MAX (see the width tip).",
                "Saturating counter on other names: `localparam logic [3:0] Top = 4'(12);` and `else if (inc) level <= (level == Top) ? level : level + 1'b1;`",
                "Near-answer: `else if (en) count <= (count == MaxVal) ? '0 : count + 1'b1;` and `assign tc = en && (count == MaxVal);`"]),
    dict(dir="09-lfsr", title="LFSR", d=3, concepts=["shift registers", "feedback taps", "pseudo-random sequences"],
         files=["lfsr.sv"],
         hints=["The comment above `fb` gives the tap formula, and the README shows the shift `{q[6:0], fb}`.",
                "`fb` is an `assign`: the XOR of four bits of `q`. Then in `always_ff`, shift `fb` in instead of `1'b0`.",
                "A 4-bit LFSR on other names: `assign f = r[3] ^ r[2];` and `r <= {r[2:0], f};`",
                "Near-answer: `assign fb = q[7] ^ q[5] ^ q[4] ^ q[3];` and `q <= {q[6:0], fb};`"]),
    dict(dir="10-sequence-detector", title="Sequence detector FSM", d=3, concepts=["typedef enum", "Moore FSM", "next-state logic", "overlap"],
         files=["seq_det.sv"],
         hints=["The README diagram gives the forward edges; the comment on each state in `seq_det.sv` says how much of `1011` it has seen.",
                "For each state and each value of `din`, ask: what is the longest tail of the bits so far that is still a start of `1011`? That state is `next`. `found` is just `state == S1011`.",
                "Worked edges: in S10 (seen ...10) a 0 gives ...100, and no start of 1011 ends in 0, so IDLE. In S1 a 1 gives ...11, whose tail 1 is a start, so stay in S1.",
                "Near-answer arms: `IDLE: next = din ? S1 : IDLE;` · `S101: next = din ? S1011 : S10;` · `S1011: next = din ? S1 : S10;` (that last one is the overlap)."]),
    dict(dir="11-traffic-light", title="Traffic light", d=3, concepts=["FSM + timer", "package enums on ports", "parameters"],
         files=["traffic.sv"], support=["traffic_pkg.sv"],
         hints=["The README's 'Nice pattern' paragraph and the TODO inside `always_ff` are the plan; the colours live in `traffic_pkg.sv`.",
                "Every clock: if `timer` equals the current colour's duration - 1, move to the next colour and clear `timer`; otherwise add 1. `walk` is an `assign` comparing `light` with `RED`.",
                "A helper on other data: `function automatic logic [3:0] blink_len(mode_t m); unique case (m) OFF: return 4'd0; default: return 4'd3; endcase endfunction`",
                "Near-answer: `end else if (timer == last_cycle(light)) begin light <= after(light); timer <= '0; end else timer <= timer + 1'b1;` with `last_cycle(RED)` returning `8'(RED_T - 1)`."]),
    dict(dir="12-debouncer", title="Debouncer + edge detector", d=3, concepts=["counters as timers", "edge detection", "registered vs combinational"],
         files=["debounce.sv"],
         hints=["Follow the three rules at the top of `debounce.sv`, in order. First delete `assign clean = noisy;`: a signal can't be driven by both an `assign` and an `always_ff`.",
                "One `always_ff` with reset. Every edge: copy `clean` into `clean_q`; then if `noisy == clean` clear the counter, else if the counter is N-1 set `clean <= noisy` and clear it, else count up. `rise`/`fall` stay `assign`s.",
                "Sizing on other numbers: for N = 10, `$clog2(10 + 1)` is 4 bits and `localparam logic [3:0] Last = 4'(10 - 1);`",
                "Near-answer: `clean_q <= clean; if (noisy == clean) cnt <= '0; else if (cnt == Last) begin clean <= noisy; cnt <= '0; end else cnt <= cnt + 1'b1;` with `localparam int CW = $clog2(N + 1);`"]),
    dict(dir="13-sync-fifo", title="Synchronous FIFO", d=4, concepts=["memories (arrays)", "read/write pointers", "full/empty/count"],
         files=["fifo.sv"],
         hints=["The TODO in `fifo.sv` and the README's rules list every piece. Declare `do_push`/`do_pop` yourself, and delete `assign count = '0;` when `count` moves into `always_ff`.",
                "full/empty come from `count`; do_push/do_pop from push/pop and those flags. Write `mem` in its own `always_ff`. Advance each pointer with wrap-around, and update `count` with a case on `{do_push, do_pop}`.",
                "Wrap a pointer for DEPTH = 5 on other names: `localparam logic [2:0] Last = 3'(5 - 1);` and `p <= (p == Last) ? '0 : p + 1'b1;`",
                "Near-answer: `unique case ({do_push, do_pop}) 2'b10: count <= count + 1'b1; 2'b01: count <= count - 1'b1; default: count <= count; endcase` and `assign full = (count == Depth);` (Depth: a sized localparam copy of DEPTH)."]),
    dict(dir="14-packages-structs", compile_hint="instr_t and instr_u don't exist until you define them in cpu_pkg.sv (open it with :e cpu_pkg.sv).", title="Packages, structs, unions", d=3, concepts=["package", "typedef struct packed", "union packed", "import"],
         files=["cpu_pkg.sv", "alu.sv"],
         hints=["Start in `cpu_pkg.sv` (`:e cpu_pkg.sv`): its TODO lists the three fields and their bit ranges. The README shows a struct of the same shape.",
                "`instr_t`: a packed struct with fields op, shamt, imm, MSB first. `instr_u`: a packed union of an `instr_t` named `f` and a 16-bit `raw`. In `alu.sv`: `unique case (instr.op)`, one arm per opcode comment.",
                "Other data: `typedef struct packed { logic [3:0] kind; logic [7:0] len; } hdr_t;` and `typedef union packed { hdr_t h; logic [11:0] bits; } hdr_u;`",
                "Near-answer: `typedef struct packed { opcode_t op; logic [4:0] shamt; logic [7:0] imm; } instr_t;` · ALU arms like `OP_SHL: y = a << instr.shamt;` and `OP_PASS: y = instr.imm;`"]),
    dict(dir="15-interfaces", compile_hint="summer.sv uses stream_if.sink, so add the sink modport to stream_if.sv first (open it with :e stream_if.sv).", title="Interfaces and modports", d=3, concepts=["interface", "modport", "valid/ready handshake"],
         files=["stream_if.sv", "summer.sv"],
         hints=["Two files: add the modport in `stream_if.sv` (copy the shape of `source`), then fill in the TODOs in `summer.sv`.",
                "The sink mirrors the source: it reads valid, data and clk, and drives ready. In `summer`: ready is not stall; at each clock edge where valid && ready, add data to `sum` and 1 to `beats`.",
                "Other data: a watch-only view `modport monitor (input valid, ready, data, clk);` · widen before adding: `total <= total + 16'(m.data);`",
                "Near-answer: `modport sink(input valid, data, clk, output ready);` · `assign s.ready = !stall;` · `end else if (s.valid && s.ready) begin sum <= sum + 16'(s.data); beats <= beats + 1'b1; end`"]),
    dict(dir="16-generate", compile_hint="the testbench looks inside generate blocks named g_bit, each holding a full_adder instance named fa (see the TODO in ripple_adder.sv).", title="Generate: ripple-carry adder", d=3, concepts=["generate for", "genvar", "instance arrays", "named blocks"],
         files=["ripple_adder.sv"], support=["full_adder.sv"],
         hints=["The starter's TODO already sketches the loop, and `full_adder.sv` shows the port names (a, b, cin, s, cout).",
                "One generate `for` over i = 0..W-1, block named `g_bit`, instance named `fa`. Bit i takes `a[i]`, `b[i]` and carry `c[i]`, and produces `sum[i]` and carry `c[i+1]`. Delete `assign sum = '0;`.",
                "Other data: `for (genvar k = 0; k < 4; k++) begin : g_inv inverter inv (.a(x[k]), .y(nx[k])); end`",
                "Near-answer: `full_adder fa (.a(a[i]), .b(b[i]), .cin(c[i]), .s(sum[i]), .cout(c[i+1]));` inside `begin : g_bit ... end`."]),
    dict(dir="17-functions", title="Functions", d=3, concepts=["function automatic", "packages of functions", "loops", "return"],
         files=["bits_pkg.sv"],
         hints=["Each function's comment says what to compute; the README's `bin2gray` block shows the full shape (signature, body, `return`).",
                "bin2gray: b XOR (b shifted right by 1). gray2bin: b[7] = g[7], then each lower bit is the bit above it XOR g[i]. popcount: loop and add bits. is_pow2: nonzero and `x & (x - 1)` is 0. lowest_set: first set i, else -1.",
                "Loop pattern on other data: `function automatic int count_zeros(logic [7:0] x); int n = 0; for (int i = 0; i < 8; i++) if (!x[i]) n += 1; return n; endfunction`",
                "Near-answer: `return b ^ (b >> 1);` · `for (int i = 6; i >= 0; i--) b[i] = b[i+1] ^ g[i];` · `for (int i = 0; i < 32; i++) if (x[i]) return i; return -1;`"]),
    dict(dir="18-assertions", title="Assertions (SVA)", d=4,
         concepts=["immediate assert", "concurrent assert property", "|-> and |=>", "##[m:n]", "$past", "$onehot0"],
         files=["hs_checker.sv"],
         runs="good bad_onehot bad_late bad_spurious bad_drop",
         expect={"bad_onehot": "a_gnt_onehot", "bad_late": "a_ack_in_time", "bad_spurious": "a_no_spurious_ack",
                 "bad_drop": "a_req_held"},
         hints=["The TODO in `hs_checker.sv` names all four labels and the system function each one needs, and gives a concurrent template.",
                "gnt: an immediate `assert` inside `always_comb`. The others are concurrent on `posedge clk`, disabled in reset: req rising leads to ack in 1..3 cycles; ack means req was high last cycle; req && !ack means req next cycle.",
                "Other protocol: `a_done_soon: assert property (@(posedge clk) disable iff (!rst_n) $rose(go) |-> ##[2:4] done);` and `a_busy: assert property (@(posedge clk) start |=> busy);`",
                "Near-answer: `always_comb a_gnt_onehot: assert ($onehot0(gnt));` and `a_no_spurious_ack: assert property (@(posedge clk) disable iff (!rst_n) ack |-> $past(req));`"]),
    dict(dir="19-classes", compile_hint="the testbench uses a class named CorruptPacket that extends Packet. Define it at the bottom of packet_pkg.sv.", title="Classes and inheritance", d=3, concepts=["class", "new()", "virtual methods", "extends/super", "static members"],
         files=["packet_pkg.sv"],
         hints=["The TODOs in `packet_pkg.sv` list each method; the README's class example and 'Classic gotcha' explain the syntax.",
                "Constructor: copy both arguments with `this.` and bump `count`. checksum: start from addr and add every payload byte in an 8-bit variable (it wraps mod 256). to_string: one `$sformatf`. CorruptPacket: see its TODO.",
                "Other data: `int t = 0; foreach (prices[i]) t += prices[i];` · `$sformatf(\"id=0x%02x\", 8'h1f)` gives `\"id=0x1f\"` · `class Dime extends Coin; function new(); super.new(10); endfunction endclass`",
                "Near-answer: `class CorruptPacket extends Packet; function new(bit [7:0] addr, bit [7:0] payload[4]); super.new(addr, payload); endfunction virtual function bit [7:0] checksum(); return ~super.checksum(); endfunction ... endclass`"]),
    dict(dir="20-constraints", title="Constrained random", d=4,
         concepts=["rand", "constraint blocks", "inside", "implication ->", "dist", "randomize() with"],
         files=["txn_pkg.sv"], needs_z3=True,
         hints=["The four rules are in the TODO in `txn_pkg.sv`; the README class shows one constraint of each kind.",
                "One constraint per rule: the low two addr bits are 0; an implication for the addr range of READ/WRITE (and addr == 0 for IDLE); an implication for len; a `dist` on kind with weights 4, 4, 1.",
                "Other data: `constraint c_even { size[0] == 0; }` · `constraint c_fast { (mode == FAST) -> size inside {[4:12]}; }` · `constraint c_mix { mode dist { SLOW := 1, FAST := 3 }; }`",
                "Near-answer: `constraint c_len { (kind == IDLE) -> len == 0; (kind != IDLE) -> len inside {[1:8]}; }` and `constraint c_kind { kind dist { READ := 4, WRITE := 4, IDLE := 1 }; }`"]),
    dict(dir="21-mailbox-fork", title="Mailboxes, fork/join, events", d=4,
         concepts=["mailbox #(T)", "fork/join, join_any, join_none", "disable fork", "events"],
         files=["workers_pkg.sv"],
         hints=["Each task's comment in `workers_pkg.sv` says exactly what to do; the README block shows the fork/join variants and events.",
                "produce: loop 1..n, `#1` then put. consume: `get` n times into a local int and add. run_pipeline: fork both, `join`. wait_or_timeout: guarded fork; one branch waits `@(ev)` and sets got_event, the other waits `#(limit)`.",
                "Other data: `repeat (3) begin #2; box.put(7); end` · a race: `fork begin @(ping); seen = 1; end #(10); join_any disable fork;`",
                "Near-answer: `task consume(int n); int x; sum = 0; repeat (n) begin mb.get(x); sum += x; end endtask` and wrap the race as `fork begin fork ... join_any disable fork; end join`."]),
    dict(dir="22-uvm-lite", title="Boss: a UVM-style testbench", d=5,
         concepts=["virtual interfaces", "driver/monitor/scoreboard", "reference models", "mailboxes between components"],
         files=["fifo_tb_pkg.sv"], support=["fifo_if.sv", "fifo.sv"],
         runs="good buggy",
         hints=["The TODO comments above `Monitor` and `Scoreboard` describe each loop; `Observation` lists the fields to fill; the README explains sampling right after `@(posedge vif.clk)`.",
                "Monitor, forever: wait for posedge, make a NEW Observation, pushed = push && !full, popped = pop && !empty, copy din/dout/full/empty, put it. Scoreboard, forever: get one; if popped compare dout with `model.pop_front()`; if pushed `push_back(din)`.",
                "Queue + mailbox on other data: `int q[$]; q.push_back(5); x = q.pop_front();` and `forever begin Item it; box.get(it); if (it.ok) n++; end`",
                "Near-answer (monitor): `forever begin Observation o; @(posedge vif.clk); o = new(); o.pushed = vif.push && !vif.full; o.dout = vif.dout; ... to_sb.put(o); end`. Treat a pop from an empty model as a mismatch."]),
]


def check_sh(ex: dict) -> str:
    lines = ["#!/usr/bin/env bash", "# Generated by _gen/build.py", f'SOURCES="{" ".join(ex["files"])}"']
    if ex.get("support"):
        lines.append(f'SUPPORT="{" ".join(ex["support"])}"')
    if ex.get("runs"):
        lines.append(f'RUNS="{ex["runs"]}"')
    for run, label in ex.get("expect", {}).items():
        lines.append(f'EXPECT_{run}="{label}"')
    if ex.get("needs_z3"):
        lines.append("NEEDS_Z3=1")
    if ex.get("compile_hint"):
        lines.append("COMPILE_HINT='" + ex["compile_hint"].replace("'", "'\\''") + "'")
    lines.append('. "$LEARN_EXERCISE_DIR/../_lib/check.sh"')
    return "\n".join(lines) + "\n"


def main() -> None:
    order = []
    for ex in EXERCISES:
        exdir = TRACK / ex["dir"]
        if not exdir.is_dir():
            print(f"skip (not written yet): {ex['dir']}")
            continue
        meta = {"title": ex["title"], "difficulty": ex["d"], "xp": XP[ex["d"]], "concepts": ex["concepts"],
                "files": ex["files"], "open": ex["files"][-1], "check": "check.sh", "hints": ex["hints"]}
        (exdir / "exercise.json").write_text(json.dumps(meta, indent=2, ensure_ascii=False) + "\n")
        check = exdir / "check.sh"
        check.write_text(check_sh(ex))
        check.chmod(0o755)
        order.append(ex["dir"])
    track = {"name": "SystemVerilog: from gates to testbenches", "slug": "systemverilog", "language": "systemverilog",
             "description": "Start from AND gates, end writing a UVM-style class-based testbench. Each exercise is "
                            "checked by a self-checking testbench compiled with Verilator (-Wall lint as tips). "
                            "WAVES=1 learn check dumps wave.vcd for surfer.",
             "order": order}
    (TRACK / "track.json").write_text(json.dumps(track, indent=2) + "\n")
    print(f"wrote {len(order)} exercises")


if __name__ == "__main__":
    main()
