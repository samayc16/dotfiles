# Level 12 · Which endpoints?

> Which endpoints returned 503? Ripgrep can print a capture group instead of the whole match.

**Task:** Print the distinct `path` values from `app.log` lines with `status=503`, sorted.

**Input** `$DATA/app.log` (first lines):
```text
2026-03-14T09:00:00Z INFO  worker  request_id=b79ecb user=u015 path=/healthz status=200 ms=113 msg="ok"
2026-03-14T09:00:25Z INFO  billing request_id=043f9f user=u057 path=/api/orders status=200 ms=95 msg="cache hit"
```

**Expected result**:
```text
/api/checkout
/api/login
/api/orders
/api/search
/api/users
```
_5 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 155 characters**, counting code only (comments and the indentation don't count).
- Concepts: `rg -o -r '$1'`, `capture groups`, `\S`
