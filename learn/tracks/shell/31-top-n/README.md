# Level 31 · Top talkers

> Is someone hammering the edge proxy?

**Task:** Print the 3 client IPs with the most requests in `access.log` as `COUNT IP`, most first.

**Input** `$DATA/access.log` (first lines):
```text
203.0.113.42 - - [14/Mar/2026:09:00:10 +0000] "GET /favicon.ico HTTP/1.1" 200 3675 "-" "Go-http-client/1.1"
203.0.113.222 - - [14/Mar/2026:09:00:11 +0000] "POST /api/orders HTTP/1.1" 200 6882 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_4) Firefox/124.0"
```

**Expected result**:
```text
  61 203.0.113.42
  48 198.51.100.7
  37 192.0.2.15
```
_3 lines in total._

_Leading and repeated spaces are ignored when checking._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 166 characters**, counting code only (comments and the indentation don't count).
- Concepts: `top-N pipeline`, `awk '{print $1}'`
