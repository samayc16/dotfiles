# Level 14 · Columns, please

> Comms wants to email everyone. Pull the email column from the user list.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `tail -n +K` | print from line K to the end (`+2` skips a header) | `printf 'h\na\nb\n' \| tail -n +2` → `a`, `b` |
| `tail -n K` | just the last K lines | `tail -n 1 notes.txt` |
| `cut -d, -f2` | split each line on `,` and keep field 2 | `printf 'a,b,c\n1,2,3\n' \| cut -d, -f2` → `b`, `2` |
| `-f1,3`, `-f2-` | several fields / field 2 onward | `cut -d, -f1,3` on `a,b,c` → `a,c` |

## Your task

Print the `email` column (3rd field) of `users.csv`, **without** the header line.

**Input** `$DATA/users.csv` (first lines):
```text
id,name,email,team,country,signup_date,plan
u001,Vik Silva,vik.silva@example.org,growth,US,2025-10-10,pro
```

**Expected result** (first lines):
```text
vik.silva@example.org
quinn.byrne@example.com
eli.duarte@example.com
ari.moreau@example.com
bea.costa@example.com
kemi.vance@example.com
```
_60 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 132 characters**, counting code only (comments and the indentation don't count).
- Concepts: `cut -d -f`, `tail -n +2`
