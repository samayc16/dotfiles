# Level 01 · The pager goes off

> 03:12. Your phone buzzes: *Nimbus API error rate > 5%*. You're on call. Time to read the logs.

## Shell text tools in 2 minutes

Each level is a tiny bash script, `solution.sh`. Write your command(s) under `# your command(s) here:`.
Whatever they print is your answer.

```sh
grep port "$DATA/services.conf" | sort
# cmd  arg  quoted path          pipe: the left side's output becomes the right side's input
```

| You type | It means |
|---|---|
| `cmd -a -b` = `cmd -ab` | short flags; most tools let you glue them together |
| `a \| b \| c` | a pipeline: read it left to right, each tool reworks the previous one's output |
| `'...'` | single quotes: the text reaches the tool exactly as typed. Use them for regexes, sed and awk programs |
| `"..."` | double quotes: `$VARS` expand, spaces don't split. Use them for paths: `"$DATA/app.log"` |
| `$DATA` | set at the top of `solution.sh`: the folder that holds every data file |
| `# ...` | a comment |
| `man grep` | the manual: `/word` searches, `n` jumps to the next hit, `q` quits |

**Run and check.** `bash solution.sh` prints your output. `learn check` (`<leader>lc`) runs it with `LC_ALL=C`
(plain byte order for sorting) and compares it with the expected result below. Trailing spaces don't matter.

```text
✓ Correct! (92 lines match)
✓ Golf: 111 chars (par 115) - under par!
```

```text
✗ Output does not match yet.
  expected 92 lines, got 0
  first difference at line 1:
    expected: 2026-03-14T09:10:18Z ERROR auth    request_id=4dd75f ...
    got:
```

The golf count covers every line of code in `solution.sh`, including the two preset lines (comments don't count).

**macOS vs Linux.** macOS ships BSD `grep`/`sed`/`awk`, Linux ships the GNU versions. Nearly everything in this
track behaves the same on both; the one real trap (`sed -i`) gets its own level.

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `grep PATTERN FILE` | print every line of FILE that contains PATTERN | `grep tea menu.txt` |
| `cmd \| grep PATTERN` | with no FILE, grep reads the piped-in text | `printf 'tea\ncoffee\ngreen tea\n' \| grep tea` → `tea`, `green tea` |
| `printf 'a\nb\n'` | print text; `\n` is a newline. Handy for trying a command on fake input | `printf 'x\ny\n'` → two lines |

## Your task

Print every line of `app.log` whose level is `ERROR`.

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
