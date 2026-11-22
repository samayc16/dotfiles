# Level 32 · The 15 minutes that mattered

> The dashboard shows the spike between 10:15 and 10:30. Zoom in.

**Task:** For `ERROR` lines in `app.log` with a time from `10:15:00` up to (not including) `10:30:00`, print `HH:MM:SS PATH STATUS` (values only, e.g. `10:16:03 /api/checkout 503`).

**Input** `$DATA/app.log` (first lines):
```text
2026-03-14T09:00:00Z INFO  worker  request_id=b79ecb user=u015 path=/healthz status=200 ms=113 msg="ok"
2026-03-14T09:00:25Z INFO  billing request_id=043f9f user=u057 path=/api/orders status=200 ms=95 msg="cache hit"
```

**Expected result** (first lines):
```text
10:15:06 /api/users 502
10:16:03 /api/orders 503
10:16:22 /api/search 502
10:19:17 /api/search 503
10:20:27 /api/search 503
10:21:26 /api/checkout 502
```
_24 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 277 characters**, counting code only (comments and the indentation don't count).
- Concepts: `substr()`, `string comparison`, `split()`
