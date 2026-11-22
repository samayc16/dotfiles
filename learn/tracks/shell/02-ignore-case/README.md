# Level 02 · Timeout, TIMEOUT, timeout

> Half the errors look like timeouts, but every service spells it differently.

**Task:** Print every line of `app.log` that mentions `timeout` in **any** letter case.

**Input** `$DATA/app.log` (first lines):
```text
2026-03-14T09:00:00Z INFO  worker  request_id=b79ecb user=u015 path=/healthz status=200 ms=113 msg="ok"
2026-03-14T09:00:25Z INFO  billing request_id=043f9f user=u057 path=/api/orders status=200 ms=95 msg="cache hit"
```

**Expected result** (first lines):
```text
2026-03-14T09:16:57Z ERROR api     request_id=855401 user=u035 path=/api/login status=500 ms=1178 msg="upstream timeout"
2026-03-14T09:20:33Z ERROR worker  request_id=33097a user=u025 path=/api/login status=503 ms=2262 msg="Timeout waiting for lock"
2026-03-14T09:25:17Z ERROR search  request_id=200259 user=u040 path=/api/login status=503 ms=2191 msg="UPSTREAM TIMEOUT from search"
2026-03-14T09:36:45Z ERROR billing request_id=dfb239 user=u054 path=/api/search status=503 ms=4802 msg="upstream timeout"
2026-03-14T09:41:07Z ERROR worker  request_id=c08bfc user=u004 path=/api/users status=504 ms=1686 msg="upstream timeout"
2026-03-14T09:41:43Z ERROR api     request_id=00e1d0 user=u017 path=/api/users status=500 ms=1207 msg="upstream timeout"
```
_44 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 120 characters**, counting code only (comments and the indentation don't count).
- Concepts: `grep -i`
