# Level 15 · Team roster

> Which teams have users at all?

**Task:** Print each distinct `team` from `users.csv` once, sorted alphabetically (no header).

**Input** `$DATA/users.csv` (first lines):
```text
id,name,email,team,country,signup_date,plan
u001,Vik Silva,vik.silva@example.org,growth,US,2025-10-10,pro
```

**Expected result**:
```text
growth
infra
payments
platform
search
```
_5 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 143 characters**, counting code only (comments and the indentation don't count).
- Concepts: `sort -u`
