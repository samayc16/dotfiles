# 06 · Hex to 7-segment

**Concepts:** `case` as a lookup table, binary literals, bit ordering.

Every dev board has a 7-segment display. Segments are named `a`..`g` (see the drawing in `hex7seg.sv`); your
output packs them as `seg = {g, f, e, d, c, b, a}`, so `seg[0]` is segment `a`.

**Your task:** complete the table for `2`..`9` and `A b C d E F`. The testbench **draws** your digit next to the
expected one when they differ, so you can see which segment is off.

Lowercase `b` and `d` are standard on 7-segment displays (an uppercase B would look like 8, D like 0).

**Check:** `learn check`
