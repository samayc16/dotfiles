# Level 07 · error vs. errors

> Searching for `error` also finds `errors` and `error_code=...`. You only want the word itself.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `-w` | whole words only: no letter, digit or `_` directly before or after the match | `printf 'cat\ncats\ncat_food\nthe cat sat\n' \| grep -w cat` → `cat`, `the cat sat` |

## Your task

Print lines of `app.log` containing the lowercase **word** `error` (not `errors`, not `error_code`, not `ERROR`).

**Input** `$DATA/app.log` (first lines):
```text
2026-03-14T09:00:00Z INFO  worker  request_id=b79ecb user=u015 path=/healthz status=200 ms=113 msg="ok"
2026-03-14T09:00:25Z INFO  billing request_id=043f9f user=u057 path=/api/orders status=200 ms=95 msg="cache hit"
```

**Expected result** (first lines):
```text
2026-03-14T09:19:16Z WARN  billing request_id=15a535 user=u017 path=/api/search status=401 ms=318 msg="retrying after error"
2026-03-14T09:23:32Z DEBUG billing request_id=f40924 user=u021 path=/api/checkout status=200 ms=15 msg="client error ignored"
2026-03-14T09:28:52Z DEBUG api     request_id=e04de6 user=u060 path=/api/checkout status=200 ms=25 msg="client error ignored"
2026-03-14T09:29:34Z WARN  billing request_id=75c884 user=u027 path=/api/login status=404 ms=67 msg="retrying after error"
2026-03-14T09:32:41Z WARN  billing request_id=ec192b user=u054 path=/api/checkout status=400 ms=437 msg="retrying after error"
2026-03-14T09:45:06Z DEBUG worker  request_id=cc1ebe user=u030 path=/healthz status=200 ms=23 msg="client error ignored"
```
_25 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 118 characters**, counting code only (comments and the indentation don't count).
- Concepts: `grep -w`, `word boundaries`
