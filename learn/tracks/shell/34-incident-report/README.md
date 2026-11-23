# Level 34 · Boss: incident report

> Post-mortem time. Which endpoints failed, how often, and how slowly?

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| several rules | `{...}` with no condition runs on every line; later `COND {...}` rules see the same line | |
| `if (c) stmt` | an `if` inside an action | `echo '3 9' \| awk '{if ($1 > 2) print "big"}'` → `big` |
| `/` | awk arithmetic is floating point | `awk 'BEGIN {print 7 / 2}'` → `3.5` |
| `sort -k2,2nr -k1,1` | sort by field 2 (numeric, descending), break ties by field 1 | `printf 'b 2\na 2\nc 5\n' \| sort -k2,2nr -k1,1` → `c 5`, `a 2`, `b 2` |

## Your task

From `app.log`, for each `path` with **at least 3** responses with status ≥ 500, print `PATH COUNT AVG_MS`. `AVG_MS` is the mean `ms` of those 5xx responses, with 1 decimal. Sort by count (highest first), then by path.

**Input** `$DATA/app.log` (first lines):
```text
2026-03-14T09:00:00Z INFO  worker  request_id=b79ecb user=u015 path=/healthz status=200 ms=113 msg="ok"
2026-03-14T09:00:25Z INFO  billing request_id=043f9f user=u057 path=/api/orders status=200 ms=95 msg="cache hit"
```

**Expected result**:
```text
/api/search 25 2877.6
/api/login 24 3027.8
/api/users 15 2763.5
/api/checkout 14 2955.1
/api/orders 14 3160.2
```
_5 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 324 characters**, counting code only (comments and the indentation don't count).
- Concepts: `multi-field aggregation`, `averages`, `multi-key sort`
