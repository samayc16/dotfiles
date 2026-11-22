# Level 08 · Five hundreds

> Switch to the edge proxy's `access.log`. Which requests got a 5xx?

**Task:** Print every line of `access.log` whose HTTP status is 5xx. The status comes right after the quoted request: `"GET /x HTTP/1.1" 503 1234 ...`

**Input** `$DATA/access.log` (first lines):
```text
203.0.113.42 - - [14/Mar/2026:09:00:10 +0000] "GET /favicon.ico HTTP/1.1" 200 3675 "-" "Go-http-client/1.1"
203.0.113.222 - - [14/Mar/2026:09:00:11 +0000] "POST /api/orders HTTP/1.1" 200 6882 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_4) Firefox/124.0"
```

**Expected result** (first lines):
```text
192.0.2.15 - - [14/Mar/2026:09:03:08 +0000] "GET /healthz HTTP/1.1" 500 1441 "-" "Mozilla/5.0 (X11; Linux x86_64) Chrome/123.0"
203.0.113.222 - - [14/Mar/2026:09:03:27 +0000] "GET /api/search?q=shoes HTTP/1.1" 503 4836 "-" "curl/8.4.0"
192.0.2.15 - - [14/Mar/2026:09:03:46 +0000] "GET /api/users HTTP/1.1" 500 2695 "-" "python-requests/2.31.0"
203.0.113.150 - - [14/Mar/2026:09:06:03 +0000] "GET /favicon.ico HTTP/1.1" 502 4737 "-" "python-requests/2.31.0"
198.51.100.7 - - [14/Mar/2026:09:07:12 +0000] "GET /api/users HTTP/1.1" 503 1735 "-" "Mozilla/5.0 (X11; Linux x86_64) Chrome/123.0"
203.0.113.5 - - [14/Mar/2026:09:09:16 +0000] "POST /favicon.ico HTTP/1.1" 503 8532 "-" "Go-http-client/1.1"
```
_59 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 131 characters**, counting code only (comments and the indentation don't count).
- Concepts: `grep -E`, `{n} repetition`, `regex literals`
