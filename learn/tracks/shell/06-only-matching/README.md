# Level 06 · Collect the evidence

> The backend team wants the request IDs of every failed request.

**Task:** For every `ERROR` line in `app.log`, print just its `request_id=...` field, one per line, in log order.

**Input** `$DATA/app.log` (first lines):
```text
2026-03-14T09:00:00Z INFO  worker  request_id=b79ecb user=u015 path=/healthz status=200 ms=113 msg="ok"
2026-03-14T09:00:25Z INFO  billing request_id=043f9f user=u057 path=/api/orders status=200 ms=95 msg="cache hit"
```

**Expected result** (first lines):
```text
request_id=4dd75f
request_id=da6178
request_id=855401
request_id=972e6a
request_id=f9f73e
request_id=8a4ba0
```
_92 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 150 characters**, counting code only (comments and the indentation don't count).
- Concepts: `pipes`, `grep -o`, `character classes`
