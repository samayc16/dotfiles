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
         hints=["`assign y_and = a & b;`, and the others follow the same shape.",
                "NAND is NOT of AND: `~(a & b)`."]),
    dict(dir="02-vectors", title="Vectors, slices, reductions", d=1,
         concepts=["[7:0] vectors", "slices", "{concat}", "{N{replicate}}", "reduction ^a &a |a", "{<<{a}}"],
         files=["vectors.sv"],
         hints=["Nibble swap: `{a[3:0], a[7:4]}`.", "Reduction operators take one operand: `^a`, `&a`, `|a`.",
                "Sign extension: `{{8{a[7]}}, a}`. Bit reverse: `{<<{a}}`."]),
    dict(dir="03-mux", title="Multiplexers", d=1, concepts=["ternary ?:", "always_comb", "unique case"],
         files=["mux.sv"],
         hints=["`assign y2 = sel2 ? d1 : d0;`", "In always_comb: `unique case (sel4) 2'd0: y4 = d0; ... endcase`."]),
    dict(dir="04-adder", title="Parameterized adder", d=2, concepts=["parameter", "width extension", "casts N'(x)", "overflow"],
         files=["adder.sv"],
         hints=["Widen before adding: `{1'b0, a} + {1'b0, b}`.",
                "Signed overflow: operands share a sign bit, but the sum's sign bit differs from it."]),
    dict(dir="05-priority-encoder", title="Priority encoder", d=2, concepts=["always_comb", "for loops in hardware", "default assignments"],
         files=["prio_enc.sv"],
         hints=["Assign defaults first (`idx = '0; valid = 0;`), then let later loop iterations override earlier ones.",
                "Loop from bit 0 upward and overwrite, so the highest set bit wins.",
                "Or use `casez` with `?` wildcards."]),
    dict(dir="06-hex-to-7seg", title="Hex to 7-segment", d=2, concepts=["case tables", "default", "bit ordering"],
         files=["hex7seg.sv"],
         hints=["Write out a 16-entry `case`; each segment pattern is a 7-bit constant `7'b gfedcba`.",
                "Draw the digit and mark which of a..g light up; bit 0 is segment a."]),
    dict(dir="07-flip-flops", title="Flip-flops and resets", d=2, concepts=["always_ff", "nonblocking <=", "async vs sync reset", "enable"],
         files=["regs.sv"],
         hints=["Async reset goes in the sensitivity list: `always_ff @(posedge clk or negedge rst_n)`.",
                "Sync reset is just an `if` inside `always_ff @(posedge clk)`.",
                "Always use `<=` (nonblocking) in always_ff."]),
    dict(dir="08-counter", title="Counter", d=2, concepts=["registers + next-state logic", "wrap-around", "terminal count"],
         files=["counter.sv"],
         hints=["Priority: reset, then load, then count when enabled.",
                "Wrap: `count <= (count == MAX) ? '0 : count + 1'b1;`",
                "`tc` is combinational: `en && count == MAX`."]),
    dict(dir="09-lfsr", title="LFSR", d=3, concepts=["shift registers", "feedback taps", "pseudo-random sequences"],
         files=["lfsr.sv"],
         hints=["Feedback = XOR of the tap bits: `q[7] ^ q[5] ^ q[4] ^ q[3]`.",
                "Shift left and insert the feedback at bit 0: `q <= {q[6:0], fb};`"]),
    dict(dir="10-sequence-detector", title="Sequence detector FSM", d=3, concepts=["typedef enum", "Moore FSM", "next-state logic", "overlap"],
         files=["seq_det.sv"],
         hints=["States = how much of `1011` you've seen: IDLE, S1, S10, S101, S1011.",
                "From S1011, a `1` means you've seen `...1` (S1) and a `0` means `...10` (S10). That's the overlap.",
                "Two processes: `always_ff` for `state <= next;`, `always_comb` for `next` (default `next = state`)."]),
    dict(dir="11-traffic-light", title="Traffic light", d=3, concepts=["FSM + timer", "package enums on ports", "parameters"],
         files=["traffic.sv"], support=["traffic_pkg.sv"],
         hints=["Keep a timer that counts cycles spent in the current state.",
                "When the timer reaches DURATION-1, move to the next colour and reset the timer.",
                "`walk = (light == RED);`"]),
    dict(dir="12-debouncer", title="Debouncer + edge detector", d=3, concepts=["counters as timers", "edge detection", "registered vs combinational"],
         files=["debounce.sv"],
         hints=["Count consecutive cycles where `noisy != clean`; reset the counter whenever they agree.",
                "When the counter hits N-1 (and they still differ), flip `clean`.",
                "Edges: keep `clean_q` (clean delayed by one cycle). `rise = clean & ~clean_q`."]),
    dict(dir="13-sync-fifo", title="Synchronous FIFO", d=4, concepts=["memories (arrays)", "read/write pointers", "full/empty/count"],
         files=["fifo.sv"],
         hints=["Track `count`; full = (count == DEPTH), empty = (count == 0).",
                "`do_push = push && !full; do_pop = pop && !empty;` and update count by +1, -1 or 0.",
                "Pointers wrap at DEPTH; `dout = mem[rd_ptr]` (show-ahead)."]),
    dict(dir="14-packages-structs", compile_hint="instr_t and instr_u don't exist until you define them in cpu_pkg.sv (open it with :e cpu_pkg.sv).", title="Packages, structs, unions", d=3, concepts=["package", "typedef struct packed", "union packed", "import"],
         files=["cpu_pkg.sv", "alu.sv"],
         hints=["`typedef struct packed { opcode_t op; logic [4:0] shamt; logic [7:0] imm; } instr_t;` (16 bits, MSB first).",
                "`typedef union packed { instr_t f; logic [15:0] raw; } instr_u;`",
                "In alu.sv: `import cpu_pkg::*;` then `case (instr.op)`."]),
    dict(dir="15-interfaces", compile_hint="summer.sv uses stream_if.sink, so add the sink modport to stream_if.sv first (open it with :e stream_if.sv).", title="Interfaces and modports", d=3, concepts=["interface", "modport", "valid/ready handshake"],
         files=["stream_if.sv", "summer.sv"],
         hints=["A modport lists each signal with its direction from that side: `modport sink (input valid, data, output ready);`",
                "A beat transfers on a clock edge where `valid && ready`.",
                "Drive `s.ready = !stall;`"]),
    dict(dir="16-generate", compile_hint="the testbench looks inside generate blocks named g_bit, each holding a full_adder instance named fa (see the TODO in ripple_adder.sv).", title="Generate: ripple-carry adder", d=3, concepts=["generate for", "genvar", "instance arrays", "named blocks"],
         files=["ripple_adder.sv"], support=["full_adder.sv"],
         hints=["Declare a carry vector `logic [W:0] c;` with `c[0] = cin`.",
                "`for (genvar i = 0; i < W; i++) begin : g_bit full_adder fa (...); end`",
                "`cout = c[W]`."]),
    dict(dir="17-functions", title="Functions", d=3, concepts=["function automatic", "packages of functions", "loops", "return"],
         files=["bits_pkg.sv"],
         hints=["Gray code: `b ^ (b >> 1)`.",
                "gray2bin: each binary bit is the XOR of all gray bits at or above it. Loop from the MSB down.",
                "Power of two: exactly one bit set, so `x != 0 && (x & (x - 1)) == 0`."]),
    dict(dir="18-assertions", title="Assertions (SVA)", d=4,
         concepts=["immediate assert", "concurrent assert property", "|-> and |=>", "##[m:n]", "$past", "$onehot0"],
         files=["hs_checker.sv"],
         runs="good bad_onehot bad_late bad_spurious bad_drop",
         expect={"bad_onehot": "a_gnt_onehot", "bad_late": "a_ack_in_time", "bad_spurious": "a_no_spurious_ack",
                 "bad_drop": "a_req_held"},
         hints=["Immediate: `always_comb a_gnt_onehot: assert ($onehot0(gnt));`",
                "Concurrent: `a_ack_in_time: assert property (@(posedge clk) disable iff (!rst_n) req |-> ##[1:3] ack);`",
                "`|=>` means \"from the next cycle\": `req && !ack |=> req`. `$past(req)` is req one cycle ago."]),
    dict(dir="19-classes", compile_hint="the testbench uses a class named CorruptPacket that extends Packet. Define it at the bottom of packet_pkg.sv.", title="Classes and inheritance", d=3, concepts=["class", "new()", "virtual methods", "extends/super", "static members"],
         files=["packet_pkg.sv"],
         hints=["`function new(bit [7:0] addr, bit [7:0] payload[4]); this.addr = addr; ... count++; endfunction`",
                "Mark methods `virtual` in the base class so a base-class handle calls the derived version.",
                "In the subclass constructor call `super.new(addr, payload);` first."]),
    dict(dir="20-constraints", title="Constrained random", d=4,
         concepts=["rand", "constraint blocks", "inside", "implication ->", "dist", "randomize() with"],
         files=["txn_pkg.sv"], needs_z3=True,
         hints=["`constraint c_align { addr[1:0] == 0; }`",
                "`constraint c_len { (kind == IDLE) -> len == 0; (kind != IDLE) -> len inside {[1:8]}; }`",
                "`constraint c_kind { kind dist { READ := 4, WRITE := 4, IDLE := 2 }; }`"]),
    dict(dir="21-mailbox-fork", title="Mailboxes, fork/join, events", d=4,
         concepts=["mailbox #(T)", "fork/join, join_any, join_none", "disable fork", "events"],
         files=["workers_pkg.sv"],
         hints=["`m.put(x)` blocks only on a bounded, full mailbox; `m.get(x)` blocks until an item arrives.",
                "Timeout pattern: `fork begin work(); ok = 1; end begin #limit; end join_any disable fork;`",
                "Events: `-> done;` to trigger, `@(done)` to wait."]),
    dict(dir="22-uvm-lite", title="Boss: a UVM-style testbench", d=5,
         concepts=["virtual interfaces", "driver/monitor/scoreboard", "reference models", "mailboxes between components"],
         files=["fifo_tb_pkg.sv"], support=["fifo_if.sv", "fifo.sv"],
         runs="good buggy",
         hints=["Monitor: every `@(posedge vif.clk)`, look at push/pop/full/empty *before* the edge updates them, "
                "and send what actually happened to the scoreboard.",
                "Scoreboard: keep a queue model. On a pop, compare `dout` with `model.pop_front()`.",
                "Count `num_matches` and `num_mismatches`; the testbench reads them at the end."]),
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
