# 02 · Vectors, slices, reductions

**Concepts:** multi-bit `logic [7:0]`, slices `a[3:0]`, concatenation `{x, y}`, replication `{8{bit}}`,
reduction operators `&a |a ^a`, the streaming operator `{<<{a}}`, the fill literal `'0`.

```systemverilog
logic [7:0] a;          // 8 bits: a[7] is the MSB, a[0] the LSB
a[3:0]                  // low nibble (a 4-bit slice)
{a[3:0], a[7:4]}        // concatenation: build a wider value from pieces
{4{1'b1}}               // replication: 4'b1111
^a                      // reduction XOR: XOR all 8 bits together into 1 bit
'0                      // "all zeros, whatever the width"
```

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `logic [7:0] a` | an 8-bit vector, written `[MSB:LSB]` | `logic [15:0] word;` |
| `a[7]`, `a[3:0]` | one bit / a slice (a narrower vector) | `word[15]`, `word[15:8]` (high byte) |
| `8'hF0`, `'0`, `'1` | sized hex literal; `'0` / `'1` = all zeros / all ones at any width | `16'hBEEF` |
| `a & b` (two operands) | bitwise: bit 0 with bit 0, bit 1 with bit 1, ...; same width out | `4'b1100 & 4'b1010` → `4'b1000` |
| `&a` `\|a` `^a` (one operand) | **reduction**: combine all bits of `a` into 1 bit (all ones? any one? odd count?) | `&4'b1110` → `0`, `\|4'b0100` → `1`, `^4'b0111` → `1` |
| `{x, y}` | concatenation: `x` becomes the high bits | `{4'hA, 4'h5}` → `8'hA5` |
| `{N{x}}` | replication: `x` repeated N times | `{3{2'b10}}` → `6'b101010` |
| `{{N{x}}, y}` | replication *inside* a concatenation (note the double braces) | `{{8{1'b0}}, word}` zero-extends to 24 bits |
| `{<<{a}}` | streaming operator: the bits of `a` in reverse order | `{<<{4'b0001}}` → `4'b1000` |

**Your task:** fill in every output of `vectors.sv` (each has a comment saying what it should be).

Sign extension: a negative 8-bit number like `8'hF0` (-16) must become `16'hFFF0`, while `8'h70` becomes
`16'h0070`. Copy the sign bit `a[7]` into the 8 new high bits.

**Check:** `learn check`. The testbench tries corner cases and 200 random values.
