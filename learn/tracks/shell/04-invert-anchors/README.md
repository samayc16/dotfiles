# Level 04 · Strip the noise

> Maybe it's a config problem. `services.conf` is mostly comments, though.

**Task:** Print `services.conf` **without** comment lines (lines starting with `#`) and without blank lines. Inline comments after a value stay.

**Input** `$DATA/services.conf` (first lines):
```text
# Nimbus service configuration
# Read once at boot. Restart the service after editing.
```

**Expected result** (first lines):
```text
[web]
host = 0.0.0.0
port = 8000
debug = false
workers = 4
[database]
```
_22 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 135 characters**, counting code only (comments and the indentation don't count).
- Concepts: `grep -v`, `^ and $ anchors`, `multiple -e`
