# Level 20 · Privacy, please

> You need to paste the user list into the incident channel, but not the email addresses.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `sed 's/OLD/NEW/' FILE` | on every line, replace the first match of regex OLD with NEW; print every line | `echo a-b-c \| sed 's/-/+/'` → `a+b-c` |
| `s/OLD/NEW/g` | replace every match on the line | `echo a-b-c \| sed 's/-/+/g'` → `a+b+c` |
| `[^,]` | any one character **except** the listed ones | `echo 'tel: 555-1234' \| sed 's/[^ ]*$/<hidden>/'` → `tel: <hidden>` |
| NEW | plain text, except `&` (the whole match) and `\1` (level 23) | `echo cat \| sed 's/a/[&]/'` → `c[a]t` |
| `s#a#b#` | any delimiter works; handy when the text contains `/` | `echo /usr/local/bin \| sed 's#/usr/local#/opt#'` → `/opt/bin` |

## Your task

Print `users.csv` with the part of each email **before** the `@` replaced by `***` (`***@example.com`). The header line stays unchanged.

**Input** `$DATA/users.csv` (first lines):
```text
id,name,email,team,country,signup_date,plan
u001,Vik Silva,vik.silva@example.org,growth,US,2025-10-10,pro
```

**Expected result** (first lines):
```text
id,name,email,team,country,signup_date,plan
u001,Vik Silva,***@example.org,growth,US,2025-10-10,pro
u002,Quinn Byrne,***@example.com,growth,IN,2025-07-26,free
u003,Eli Duarte,***@example.com,platform,US,2025-04-13,pro
u004,Ari Moreau,***@example.com,payments,IN,2025-07-03,team
u005,Bea Costa,***@example.com,infra,DE,2025-11-12,team
```
_61 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 129 characters**, counting code only (comments and the indentation don't count).
- Concepts: `sed s///`, `negated classes [^,]`
