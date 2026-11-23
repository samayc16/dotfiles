# Level 05 · Where did it panic?

> Someone in chat says a Go service *panicked*. You want line numbers to jump straight there in nvim.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `-n` | prefix each matching line with its line number and `:` | `printf 'tea\ncoffee\ngreen tea\n' \| grep -n tea` → `1:tea`, `3:green tea` |

## Your task

Print every line of `app.log` containing `panic`, prefixed with its line number (`123:...`).

**Input** `$DATA/app.log` (first lines):
```text
2026-03-14T09:00:00Z INFO  worker  request_id=b79ecb user=u015 path=/healthz status=200 ms=113 msg="ok"
2026-03-14T09:00:25Z INFO  billing request_id=043f9f user=u057 path=/api/orders status=200 ms=95 msg="cache hit"
```

**Expected result**:
```text
301:2026-03-14T10:21:44Z ERROR api     request_id=23b51d user=u042 path=/api/orders status=503 ms=1130 msg="panic: nil pointer dereference"
308:2026-03-14T10:23:42Z ERROR auth    request_id=59961c user=u050 path=/api/users status=503 ms=3235 msg="panic: nil pointer dereference"
354:2026-03-14T10:36:50Z ERROR billing request_id=6d62ab user=u042 path=/api/users status=504 ms=1049 msg="panic: nil pointer dereference"
626:2026-03-14T11:55:04Z ERROR worker  request_id=4a054a user=u028 path=/api/orders status=500 ms=4391 msg="panic: nil pointer dereference"
```
_4 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 118 characters**, counting code only (comments and the indentation don't count).
- Concepts: `grep -n`
