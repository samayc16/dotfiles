# Level 33 · Config to env vars

> The new deploy system wants environment variables, not INI files.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `-F' *= *'` | the separator can be a regex: here `=` with any spaces around it | `echo 'a - b' \| awk -F' *- *' '{print $2}'` → `b` |
| `/re/ {...}` | a regex as the condition: lines that match | `/^#/ {next}` skips comment lines |
| `sub(/re/, "x", v)`, `gsub(...)` | replace the first / every match inside v (default `$0`) | `echo '(x)' \| awk '{gsub(/[()]/, ""); print}'` → `x` |
| `toupper(s)`, `tolower(s)` | change case | `toupper("ab")` → `AB` |
| `[][]` | a class holding `]` and `[` (the `]` must come first) | |
| memory | a variable set on one line keeps its value on the following lines | |

## Your task

Turn `services.conf` into `SECTION_KEY=VALUE` lines (uppercase section and key, inline comments dropped), e.g. `WEB_PORT=8000`, in file order. Skip comments and blank lines.

**Input** `$DATA/services.conf` (first lines):
```text
# Nimbus service configuration
# Read once at boot. Restart the service after editing.
```

**Expected result** (first lines):
```text
WEB_HOST=0.0.0.0
WEB_PORT=8000
WEB_DEBUG=false
WEB_WORKERS=4
DATABASE_HOST=db.internal.example
DATABASE_PORT=5432
```
_17 lines in total._

---

- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same synthetic files.
- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`
- ⛳ Golf: ★★★ needs a solution of **≤ 248 characters**, counting code only (comments and the indentation don't count).
- Concepts: `regex FS`, `gsub`, `toupper`, `state across lines`
