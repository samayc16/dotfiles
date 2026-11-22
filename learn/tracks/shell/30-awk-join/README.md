# Level 30 · Which team spends the most?

> Orders know user IDs; users know teams. Join them.

**Task:** Join `users.csv` and `orders.csv` and print `TEAM TOTAL` (2 decimals) of `paid` **USD** orders per team, biggest total first.

**Input** `$DATA/users.csv` (first lines):
```text
id,name,email,team,country,signup_date,plan
u001,Vik Silva,vik.silva@example.org,growth,US,2025-10-10,pro
```

**Input** `$DATA/orders.csv` (first lines):
```text
order_id,user_id,amount,currency,status,created_at
o1001,u004,134.95,USD,paid,2026-03-01
```

**Expected result**:
```text
payments 4986.85
platform 4267.61
growth 3164.37
search 2946.32
infra 1640.92
```
_5 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 291 characters**, counting code only (comments and the indentation don't count).
- Concepts: `NR==FNR two-file join`, `next`
