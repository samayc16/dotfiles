# Level 29 · A report your manager can read

> Your manager wants a tidy table, not raw counts.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `%-10s`, `%5d` | left-align in 10 columns / right-align in 5 | `awk 'BEGIN {printf "[%-6s][%4d]\n", "ab", 42}'` → `[ab    ][  42]` |
| `print ... \| "sort"` | inside awk: send these lines through a shell command | |
| `close("sort")` | finish that command (flush its output) before printing more | |
| `a; b` | several awk statements on one line | `{n++; t += $1}` |
| `{ a; b; }` | shell: group commands so their outputs form one stream | `{ echo top; ls; } \| head -3` |

## Your task

Print this table from `users.csv`: a header row, one row per team (sorted by team name), and a `TOTAL` row. Team left-aligned in 10 columns, then a space, then the count right-aligned in 5.

```text
TEAM       USERS
growth        10
...
TOTAL         60
```

**Input** `$DATA/users.csv` (first lines):
```text
id,name,email,team,country,signup_date,plan
u001,Vik Silva,vik.silva@example.org,growth,US,2025-10-10,pro
```

**Expected result** (first lines):
```text
TEAM       USERS
growth        10
infra          8
payments      14
platform      16
search        12
```
_7 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 293 characters**, counting code only (comments and the indentation don't count).
- Concepts: `printf widths %-10s %5d`, `piping inside awk`, `close()`
