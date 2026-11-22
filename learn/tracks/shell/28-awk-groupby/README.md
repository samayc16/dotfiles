# Level 28 · Revenue by currency

> Same question, broken down by currency.

**Task:** For `paid` orders, print `CURRENCY TOTAL` (2 decimals) per currency, sorted by currency.

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
