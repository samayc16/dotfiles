# systemverilog track

22 exercises from AND gates to a class-based, UVM-style testbench. Each exercise has a read-only,
self-checking testbench (`tb.sv`) that Verilator compiles together with your files (`-Wall` lint is shown
as tips, never fails the check).

- Play: `learn` (this repo's CLI) · requirements: `verilator` (5.x), `z3` (constrained random, exercise 20),
  `perl`. Optional: `surfer` to view waveforms: `WAVES=1 learn check`, then `surfer wave.vcd`.
- Metadata (`exercise.json`, `check.sh`, `track.json`) is generated: `python3 -I _gen/build.py`
- Verify every exercise (starter fails, reference passes with no lint warnings): `./_verify.sh`
- Shared pieces: `_lib/check.sh` (build + run + multi-run assertion checks), `_lib/tbu.sv` (check helpers).
