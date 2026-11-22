# 09 · LFSR

**Concepts:** shift registers, XOR feedback, pseudo-random sequences.

A **linear-feedback shift register** shifts left every clock and feeds an XOR of a few bits (the *taps*) back
into bit 0. With the right taps an 8-bit LFSR visits all 255 non-zero states before repeating. It's cheap
pseudo-randomness used in tests, scramblers, CRCs and BIST.

```text
  q[7] q[6] q[5] q[4] q[3] q[2] q[1] q[0]   <- shift left
   |         |    |    |
   +---XOR---+----+----+---> feedback ---> new q[0]
```

`{q[6:0], fb}` is the whole shift: drop the MSB, append the feedback.

**Your task:** compute `fb` and shift it in. The testbench checks the sequence, the enable, two different seeds,
and that the period really is 255.

**Waveforms:** `WAVES=1 learn check` → `surfer wave.vcd`, and show `q1` as an analog plot for a nice
pseudo-random sawtooth.
