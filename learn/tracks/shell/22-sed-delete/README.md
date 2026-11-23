# Level 22 · Config, minus the chatter

> Diffing configs is easier without comments.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `/re/d` | delete matching lines | `printf 'keep\ndrop me\nkeep too\n' \| sed '/drop/d'` → `keep`, `keep too` |
| `s/re//` | an empty NEW deletes the matched text | `echo 'hello world' \| sed 's/ world//'` → `hello` |
| `-e A -e B` | several commands, applied in order to every line | `echo 'a b' \| sed -e 's/a/A/' -e 's/b/B/'` → `A B` |

## Your task

Print `services.conf` with all comments removed (whole-line **and** inline, plus the spaces before them) and no blank lines.

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
- ⛳ Golf: ★★★ needs a solution of **≤ 153 characters**, counting code only (comments and the indentation don't count).
- Concepts: `sed -e (multiple)`, `d command`
