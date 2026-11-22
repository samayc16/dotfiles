# Level 20 · Privacy, please

> You need to paste the user list into the incident channel, but not the email addresses.

**Task:** Print `users.csv` with the part of each email **before** the `@` replaced by `***` (`***@example.com`). The header line stays unchanged.

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
