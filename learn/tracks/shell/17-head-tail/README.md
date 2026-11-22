# Level 17 · Hottest moments

> The metrics export is a TSV. When was the CPU hottest?

**Task:** Print the 3 data rows of `metrics.tsv` with the highest `cpu` (3rd column), highest first. Skip the header.

**Input** `$DATA/metrics.tsv` (first lines):
```text
timestamp	host	cpu	mem_mb
2026-03-14T09:00:00Z	api-04	19.6	1627
```

**Expected result**:
```text
2026-03-14T10:00:00Z	cache-01	99.1	14388
2026-03-14T09:58:30Z	api-02	97.3	14210
2026-03-14T10:01:30Z	api-02	95.8	13990
```
_3 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 155 characters**, counting code only (comments and the indentation don't count).
- Concepts: `sort -t -k`, `head`, `$'\t'`
