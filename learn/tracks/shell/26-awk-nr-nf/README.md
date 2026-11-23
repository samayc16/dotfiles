# Level 26 · Malformed metrics

> The metrics pipeline choked on some rows. Find the broken ones.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `NF` | number of fields on this line | |
| `$NF` | the last field | |
| `NR` | the line (record) number, from 1 | |
| `$0` | the whole line | `printf 'a b\nc\n' \| awk 'NF != 2 {print NR, $0}'` → `2 c` |
| `-F'\t'` | split on tabs | |

```sh
printf 'a b c\nd e\n' | awk '{print NR ": " NF " fields, last " $NF}'
# 1: 3 fields, last c
# 2: 2 fields, last e
```

## Your task

Print `LINE: ROW` for every line of `metrics.tsv` that does not have exactly 4 tab-separated fields (`LINE` is the line number in the file).

**Input** `$DATA/metrics.tsv` (first lines):
```text
timestamp	host	cpu	mem_mb
2026-03-14T09:00:00Z	api-04	19.6	1627
```

**Expected result**:
```text
58: 2026-03-14T10:25:30Z	db-01	41.0
74: 2026-03-14T10:49:30Z	api-03	12.5	4100	OVERFLOW
97: 2026-03-14T11:24:00Z	cache-01
```
_3 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 150 characters**, counting code only (comments and the indentation don't count).
- Concepts: `NF (field count)`, `NR (record number)`
