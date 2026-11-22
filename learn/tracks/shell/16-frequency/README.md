# Level 16 · Where are our users?

> Is the outage regional? Start with where users live.

**Task:** Count users per `country` in `users.csv` and print `COUNT COUNTRY`, highest first.

**Input** `$DATA/users.csv` (first lines):
```text
id,name,email,team,country,signup_date,plan
u001,Vik Silva,vik.silva@example.org,growth,US,2025-10-10,pro
```

**Expected result**:
```text
  18 US
  14 IN
  11 DE
   8 BR
   6 JP
   3 CA
```
_6 lines in total._

_Leading and repeated spaces are ignored when checking._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 162 characters**, counting code only (comments and the indentation don't count).
- Concepts: `uniq -c`, `sort -rn`
