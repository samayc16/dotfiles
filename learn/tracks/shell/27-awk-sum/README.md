# Level 27 · Revenue check

> Finance asks whether payments still worked during the incident.

**Task:** Print the total `amount` of `paid` orders in `USD` from `orders.csv`, with 2 decimals.

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
