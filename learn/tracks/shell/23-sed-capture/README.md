# Level 23 · Dates for the Berlin office

> Finance in Berlin wants the orders export with dates as `DD.MM.YYYY`.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `sed -E` | extended regex in sed: `( )`, `{4}`, `+` without backslashes (same on macOS and Linux) | |
| `\1`, `\2` in NEW | insert what group 1, 2 captured | `echo 'Doe, Jane' \| sed -E 's/([A-Za-z]+), ([A-Za-z]+)/\2 \1/'` → `Jane Doe` |
| `\1` in a pattern | a backreference: the same text again | `printf 'book\nbok\n' \| grep -E '(o)\1'` → `book` |

## Your task

Print `orders.csv` with every `YYYY-MM-DD` date rewritten as `DD.MM.YYYY`.

**Input** `$DATA/orders.csv` (first lines):
```text
order_id,user_id,amount,currency,status,created_at
o1001,u004,134.95,USD,paid,2026-03-01
```

**Expected result** (first lines):
```text
order_id,user_id,amount,currency,status,created_at
o1001,u004,134.95,USD,paid,01.03.2026
o1002,u023,56.10,USD,pending,14.03.2026
o1003,u024,494.99,USD,paid,11.03.2026
o1004,u015,144.97,GBP,paid,12.03.2026
o1005,u028,405.79,USD,paid,04.03.2026
```
_151 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 165 characters**, counting code only (comments and the indentation don't count).
- Concepts: `sed -E`, `capture groups \1`
