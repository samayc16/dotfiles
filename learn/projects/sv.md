# Reading quests: Verilog / SystemVerilog

`~/learn/projects/sv/picorv32`, a complete RISC-V CPU in one readable Verilog file, used in
real chips and FPGAs. Pair it with the SystemVerilog track (`learn list systemverilog`) and
the Verilator examples (`learn docs sv`).

Keys: `gO` symbols (modules, always blocks) · `grd` jump to a signal/module definition (slang-server) ·
`grr` every driver/reader of a signal · `K` hover (type, width) · `<leader>vh` design hierarchy ·
`[x` enclosing block · `<leader>rr` simulate the current file (Verilator).

Open it: `cd ~/learn/projects/sv/picorv32 && nvim picorv32.v`

- [ ] **The module list.** `gO`: there's the core (`picorv32`), a register file, multiply/divide units and bus
      adapters (AXI, Wishbone). Which are optional, and how are they enabled? (look at the `parameter`s)
- [ ] **Parameters.** In the `picorv32` header, `K` on `ENABLE_MUL`, `ENABLE_IRQ`, `COMPRESSED_ISA`. Find one
      `generate`/`if (PARAM)` block that uses them.
- [ ] **The state machine.** Search (`/cpu_state_`) for the `localparam` states (`cpu_state_fetch`, `cpu_state_exec`…).
      `grr` on `cpu_state`: where is it assigned, and on which clock edge?
- [ ] **Decode.** Find `instr_add`, `instr_lw`… (`<leader>sg` "instr_lw"). `grr` shows where each decoded signal
      is set and where it's consumed.
- [ ] **Memory interface.** `K` on `mem_valid`, `mem_ready`: it's a valid/ready handshake. Trace one load
      from `mem_valid` going high to `mem_ready` and the data landing in a register.
- [ ] **Testbenches.** Open `testbench_ez.v`: a minimal self-contained testbench. How does it model memory?
- [ ] **Prove it.** Simulate: `iverilog -g2012 -o /tmp/ez testbench_ez.v picorv32.v && vvp /tmp/ez`
      (or `make test_ez`). Then open the waveform if one is written (`surfer testbench.vcd`).
