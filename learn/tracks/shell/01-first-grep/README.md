# Level 01 · The pager goes off

> 03:12. Your phone buzzes: *Nimbus API error rate > 5%*. You're on call. Time to read the logs.

**Task:** Print every line of `app.log` whose level is `ERROR`.

**Input** `$DATA/app.log` (first lines):
```text
2026-03-14T09:00:00Z INFO  worker  request_id=b79ecb user=u015 path=/healthz status=200 ms=113 msg="ok"
2026-03-14T09:00:25Z INFO  billing request_id=043f9f user=u057 path=/api/orders status=200 ms=95 msg="cache hit"
```

**Expected result** (first lines):
```text
2026-03-14T09:10:18Z ERROR auth    request_id=4dd75f user=u052 path=/api/checkout status=503 ms=2428 msg="error_code=E503"
2026-03-14T09:10:40Z ERROR worker  request_id=da6178 user=u027 path=/api/orders status=504 ms=3246 msg="error_code=E503"
2026-03-14T09:16:57Z ERROR api     request_id=855401 user=u035 path=/api/login status=500 ms=1178 msg="upstream timeout"
2026-03-14T09:18:07Z ERROR search  request_id=972e6a user=u016 path=/api/checkout status=503 ms=2345 msg="error_code=E503"
2026-03-14T09:19:05Z ERROR api     request_id=f9f73e user=u011 path=/api/checkout status=500 ms=1665 msg="payment declined"
2026-03-14T09:20:09Z ERROR auth    request_id=8a4ba0 user=u017 path=/api/login status=504 ms=2172 msg="error_code=E503"
```
_92 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 115 characters**, counting code only (comments and the indentation don't count).
- Concepts: `grep PATTERN FILE`
