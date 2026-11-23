# Level 19 · How many people noticed?

> How many distinct users hit at least one error?

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `wc -l` | count lines (`-w` words, `-c` bytes) | `printf 'a\nb\n' \| wc -l` → `2` |
| padding | macOS prints the number with leading spaces; this level ignores them | |

## Your task

Print the number of distinct `user=` values on `ERROR` lines in `app.log`.

**Input** `$DATA/app.log` (first lines):
```text
2026-03-14T09:00:00Z INFO  worker  request_id=b79ecb user=u015 path=/healthz status=200 ms=113 msg="ok"
2026-03-14T09:00:25Z INFO  billing request_id=043f9f user=u057 path=/api/orders status=200 ms=95 msg="cache hit"
```

**Expected result**:
```text
      37
```
_1 line in total._

_Leading and repeated spaces are ignored when checking._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 161 characters**, counting code only (comments and the indentation don't count).
- Concepts: `wc -l`, `pipeline composition`
