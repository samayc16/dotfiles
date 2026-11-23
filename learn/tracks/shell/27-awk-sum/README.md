# Level 27 · Revenue check

> Finance asks whether payments still worked during the incident.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `t += $1` | add to a variable; variables need no declaration and start as 0 / `""` | `printf '1.2\n2.3\n' \| awk '{t += $1} END {print t}'` → `3.5` |
| `END {...}` | runs once, after the last line (`BEGIN {...}` runs before the first) | |
| `&&`, `\|\|`, `!` | and, or, not | `$1 > 0 && $2 == "x"` |
| `printf "%.1f\n", x` | formatted print: here 1 decimal. printf adds no newline, so write `\n` | `awk 'BEGIN {printf "%.1f\n", 3.14159}'` → `3.1` |

## Your task

Print the total `amount` of `paid` orders in `USD` from `orders.csv`, with 2 decimals.

**Input** `$DATA/orders.csv` (first lines):
```text
order_id,user_id,amount,currency,status,created_at
o1001,u004,134.95,USD,paid,2026-03-01
```

**Expected result**:
```text
17006.07
```
_1 line in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 186 characters**, counting code only (comments and the indentation don't count).
- Concepts: `accumulators`, `END block`, `printf %.2f`
