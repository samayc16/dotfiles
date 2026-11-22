# Level 03 · How bad is it?

> Your manager is awake too and wants one number.

**Task:** Print the **number** of `ERROR` lines in `app.log` (just the number).

**Input** `$DATA/app.log` (first lines):
```text
2026-03-14T09:00:00Z INFO  worker  request_id=b79ecb user=u015 path=/healthz status=200 ms=113 msg="ok"
2026-03-14T09:00:25Z INFO  billing request_id=043f9f user=u057 path=/api/orders status=200 ms=95 msg="cache hit"
```

**Expected result**:
```text
92
```
_1 line in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 118 characters**, counting code only (comments and the indentation don't count).
- Concepts: `grep -c`
