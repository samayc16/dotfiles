# Level 35 · Final boss: find the culprit

> One account triggered more errors than anyone else. Is it a bot? Find out who it is.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `x=$(cmd)` | run cmd and store its output in x (no spaces around `=`) | `x=$(echo hi \| tr a-z A-Z)` |
| `"$x"` | use the value; inside double quotes it can be part of a pattern | `grep "^$x,"` = lines starting with the value and a comma |
| `cut -d= -f2` | any single character can be cut's separator | `echo k=v \| cut -d= -f2` → `v` |

## Your task

Find the user with the most `ERROR` lines in `app.log`, then print their `NAME,EMAIL` from `users.csv`.

**Input** `$DATA/app.log` (first lines):
```text
2026-03-14T09:00:00Z INFO  worker  request_id=b79ecb user=u015 path=/healthz status=200 ms=113 msg="ok"
2026-03-14T09:00:25Z INFO  billing request_id=043f9f user=u057 path=/api/orders status=200 ms=95 msg="cache hit"
```

**Input** `$DATA/users.csv` (first lines):
```text
id,name,email,team,country,signup_date,plan
u001,Vik Silva,vik.silva@example.org,growth,US,2025-10-10,pro
```

**Expected result**:
```text
Jade Moreau,jade.moreau@example.com
```
_1 line in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 256 characters**, counting code only (comments and the indentation don't count).
- Concepts: `command substitution $( )`, `joins`, `everything`
