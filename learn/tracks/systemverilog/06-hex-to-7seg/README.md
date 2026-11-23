# 06 · Hex to 7-segment

**Concepts:** `case` as a lookup table, binary literals, bit ordering.

Every dev board has a 7-segment display. Segments are named `a`..`g` (see the drawing in `hex7seg.sv`); your
output packs them as `seg = {g, f, e, d, c, b, a}`, so `seg[0]` is segment `a`.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `case` (no `unique`) | arms are tried in order and the first match wins; `default` catches the rest | |
| `4'hA` ... `4'hF` | hex digits A..F are 10..15 | `4'hC == 4'd12` |
| `7'b0111111` | binary literal: the **leftmost** digit is the highest bit (`seg[6]`, segment g) | `7'b1000000` lights only g (a minus sign) |

**Your task:** complete the table for `2`..`9` and `A b C d E F`. The testbench **draws** your digit next to the
expected one when they differ, so you can see which segment is off.

Lowercase `b` and `d` are standard on 7-segment displays (an uppercase B would look like 8, D like 0).

**Check:** `learn check`
