# Level 28 · Revenue by currency

> Same question, broken down by currency.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `a[key]` | an associative array (a dict): any string key, created on first use | `n[$1]` |
| `x++` | add 1 | `n[$1]++` counts each first field |
| `for (k in a)` | loop over the keys, in **no particular order**, so pipe the output into `sort` | |
| `printf "%s %d\n", a, b` | `%s` string, `%d` whole number, `%.2f` two decimals | |

```sh
printf 'x\ny\nx\n' | awk '{n[$1]++} END {for (k in n) print k, n[k]}' | sort
# x 2
# y 1
```

## Your task

For `paid` orders, print `CURRENCY TOTAL` (2 decimals) per currency, sorted by currency.

**Input** `$DATA/orders.csv` (first lines):
```text
order_id,user_id,amount,currency,status,created_at
o1001,u004,134.95,USD,paid,2026-03-01
```

**Expected result**:
```text
EUR 4542.71
GBP 5168.04
USD 17006.07
```
_3 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 205 characters**, counting code only (comments and the indentation don't count).
- Concepts: `associative arrays`, `for (k in arr)`
