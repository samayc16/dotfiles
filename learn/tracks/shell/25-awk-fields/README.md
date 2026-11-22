# Level 25 · Who pays us?

> Product wants to reach out to affected **pro** customers personally.

**Task:** Print `NAME <EMAIL>` for every user on the `pro` plan in `users.csv`, in file order.

**Input** `$DATA/users.csv` (first lines):
```text
id,name,email,team,country,signup_date,plan
u001,Vik Silva,vik.silva@example.org,growth,US,2025-10-10,pro
```

**Expected result** (first lines):
```text
Vik Silva <vik.silva@example.org>
Eli Duarte <eli.duarte@example.com>
Tess Weber <tess.weber@example.com>
Hana Lindqvist <hana.lindqvist@example.com>
Joss Vance <joss.vance@example.com>
Quinn Novak <quinn.novak@example.com>
```
_18 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 154 characters**, counting code only (comments and the indentation don't count).
- Concepts: `awk -F`, `$N fields`, `pattern {action}`
