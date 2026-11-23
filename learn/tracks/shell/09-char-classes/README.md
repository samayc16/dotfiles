# Level 09 · Not from around here

> Support says users with non-`.com` emails can't log in. Find their addresses.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `-oE` | short flags combine: same as `-o -E` | |
| `[[:alnum:]]` | named class: a letter or digit. Also `[[:digit:]]`, `[[:alpha:]]`, `[[:space:]]`, `[[:upper:]]`, `[[:lower:]]` | `echo 'id 42x' \| grep -oE '[[:digit:]]+'` → `42` |
| `[[:alnum:]_-]` | add characters to a class; inside `[...]` a `.` is literal | |
| `.` vs `\.` | any one character / a literal dot | `a.c` matches `abc`; `a\.c` matches only `a.c` |
| `(x\|y)` | alternation (needs `-E`): `x` or `y` | `echo 'a.txt b.csv c.md' \| grep -oE '[[:alnum:]]+\.(txt\|md)'` → `a.txt`, `c.md` |

## Your task

Print every email address in `users.csv` at `example.org` or `example.net` (just the address), in file order.

**Input** `$DATA/users.csv` (first lines):
```text
id,name,email,team,country,signup_date,plan
u001,Vik Silva,vik.silva@example.org,growth,US,2025-10-10,pro
```

**Expected result** (first lines):
```text
vik.silva@example.org
omar.weber@example.org
mira.novak@example.net
pia.byrne@example.net
mira.silva@example.net
yara.silva@example.org
```
_9 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 153 characters**, counting code only (comments and the indentation don't count).
- Concepts: `POSIX classes [[:alnum:]]`, `alternation (a|b)`
