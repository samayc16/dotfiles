# Level 16 · Where are our users?

> Is the outage regional? Start with where users live.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `uniq -c` | prefix each line with how often it repeated (adjacent only, so `sort` first) | `printf 'x\nx\ny\n' \| uniq -c` → `2 x`, `1 y` |
| `sort -n` | numeric sort: `2 9 10` instead of text order `10 2 9` | `printf '9\n10\n2\n' \| sort -n` → `2`, `9`, `10` |
| `sort -r`, `sort -rn` | reverse / numeric, highest first | `printf '9\n10\n2\n' \| sort -rn` → `10`, `9`, `2` |

## Your task

Count users per `country` in `users.csv` and print `COUNT COUNTRY`, highest first.

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
