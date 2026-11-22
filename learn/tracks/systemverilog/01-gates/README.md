# 01 · Logic gates

**Concepts:** modules and ports, `logic`, continuous assignment (`assign`), bitwise operators.

Hardware isn't a program that runs top to bottom. A module describes **wires and gates that all exist at
once**. `assign y = a & b;` doesn't mean "compute once". It means "y is permanently wired to the output of an
AND gate".

| operator | gate | example |
|---|---|---|
| `&` | AND | `a & b` |
| `\|` | OR | `a \| b` |
| `^` | XOR | `a ^ b` |
| `~` | NOT | `~a` |

**Your task:** in `gates.sv`, replace each `1'b0` with the right expression. (`1'b0` means "a 1-bit value, written
in binary, equal to 0".)

**Check:** `learn check`. It compiles your module with a read-only testbench using Verilator and tries all
four input combinations. Verilator's `-Wall` lint warnings about *your* code are shown as tips, but they never
fail the check.

**Explore:** open `tb.sv` next to your design: `gates dut (.*);` connects every port to the signal of the same
name. That's how a testbench "plugs in" the design under test (DUT).
