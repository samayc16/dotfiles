# Level 18 · SHOUTING hostnames

> The inventory file has the same hosts in three different capitalisations.

**Task:** Print the distinct hostnames from `hosts.txt`, lowercased, sorted.

**Input** `$DATA/hosts.txt` (first lines):
```text
cache-01.nimbus.example
db-01.nimbus.example
```

**Expected result** (first lines):
```text
api-01.nimbus.example
api-02.nimbus.example
api-03.nimbus.example
api-04.nimbus.example
cache-01.nimbus.example
db-01.nimbus.example
```
_8 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 147 characters**, counting code only (comments and the indentation don't count).
- Concepts: `tr`, `input redirection <`
