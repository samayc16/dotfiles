"""Beginner scaffolding for the shell track's READMEs, imported by build.py.

PRIMERS: slug -> markdown with its own `## ...` heading (level 01 only).
SYNTAX:  slug -> body of the level's `## New syntax` section. Each construct is explained
         the first time a level needs it, in track order, with an example on made-up input
         (never the level's own answer). Inside table cells, `|` is written as `\\|`.
Every example's shown output was checked with macOS (BSD) and GNU tools.
"""

PRIMERS = {
    "first-grep": r"""
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
""",
}

SYNTAX = {
    "first-grep": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `grep PATTERN FILE` | print every line of FILE that contains PATTERN | `grep tea menu.txt` |
| `cmd \| grep PATTERN` | with no FILE, grep reads the piped-in text | `printf 'tea\ncoffee\ngreen tea\n' \| grep tea` → `tea`, `green tea` |
| `printf 'a\nb\n'` | print text; `\n` is a newline. Handy for trying a command on fake input | `printf 'x\ny\n'` → two lines |
""",
    "ignore-case": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| (default) | matching is case-sensitive | `printf 'Tea\n' \| grep tea` → nothing |
| `-i` | ignore case: `tea` also matches `Tea` and `TEA` | `printf 'Tea\nTEA\ncoffee\n' \| grep -i tea` → `Tea`, `TEA` |
""",
    "count": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `-c` | print how many lines match, instead of the lines | `printf 'tea\ncoffee\ngreen tea\n' \| grep -c tea` → `2` |
""",
    "invert-anchors": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `-v` | invert: print the lines that do **not** match | `printf 'a\nb\n' \| grep -v a` → `b` |
| `^x` | `x` at the start of a line | `grep '^cat'` matches `catnip`, not `bobcat` |
| `x$` | `x` at the end of a line | `grep 'cat$'` matches `bobcat`, not `catnip` |
| `^$` | a start immediately followed by an end: an empty line | |
| `-e P1 -e P2` | several patterns; a line counts if it matches **any** of them | `printf 'cat\ndog\nemu\n' \| grep -e cat -e dog` → `cat`, `dog` |
| `'^#'` | single-quote every regex so the shell leaves `$`, `*`, `#` alone | |
""",
    "line-numbers": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `-n` | prefix each matching line with its line number and `:` | `printf 'tea\ncoffee\ngreen tea\n' \| grep -n tea` → `1:tea`, `3:green tea` |
""",
    "only-matching": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `-o` | print only the matched text, one match per line | `echo 'room 101, floor 3' \| grep -o '[0-9]*'` → `101`, `3` |
| `[abc]` | one character from the set | `gr[ae]y` matches `gray` and `grey` |
| `[a-f]`, `[0-9]` | ranges inside the brackets | `[0-9a-f]` = one hex digit |
| `x*` | zero or more of the item just before it | `[0-9]*` = a run of digits |
""",
    "whole-word": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `-w` | whole words only: no letter, digit or `_` directly before or after the match | `printf 'cat\ncats\ncat_food\nthe cat sat\n' \| grep -w cat` → `cat`, `the cat sat` |
""",
    "extended-regex": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `-E` | extended regex: `+ ? {} \| ()` work without backslashes | |
| `x{3}`, `x{2,4}` | exactly 3 / between 2 and 4 of `x` | `printf 'v1\nv22\nv333\n' \| grep -E '^v[0-9]{2}$'` → `v22` |
| `x+`, `x?` | one or more / optional | `grep -E 'colou?r'` matches `color` and `colour` |
| basic regex | without `-E` the same features need backslashes: `\{2\}`, `\+`, `\?`, `\\|`, `\(\)` | `grep '^v[0-9]\{2\}$'` = the `-E` version above |
| `'say "hi"'` | inside single quotes a `"` is just a character | `echo 'say "hi"' \| grep 'say "hi"'` → `say "hi"` |
""",
    "char-classes": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `-oE` | short flags combine: same as `-o -E` | |
| `[[:alnum:]]` | named class: a letter or digit. Also `[[:digit:]]`, `[[:alpha:]]`, `[[:space:]]`, `[[:upper:]]`, `[[:lower:]]` | `echo 'id 42x' \| grep -oE '[[:digit:]]+'` → `42` |
| `[[:alnum:]_-]` | add characters to a class; inside `[...]` a `.` is literal | |
| `.` vs `\.` | any one character / a literal dot | `a.c` matches `abc`; `a\.c` matches only `a.c` |
| `(x\|y)` | alternation (needs `-E`): `x` or `y` | `echo 'a.txt b.csv c.md' \| grep -oE '[[:alnum:]]+\.(txt\|md)'` → `a.txt`, `c.md` |
""",
    "rg-types": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `rg PATTERN [DIR]` | ripgrep: search every file under DIR (default: here), skipping hidden and ignored files | `rg install` |
| `-t TYPE` | only files of one type; `rg --type-list` lists them | `rg -t md install` → only Markdown files |
| `-l` | print the names of matching files, not the lines | `rg -l install` → `run.py`, `setup.md` |
| `a && b` | run `b` only if `a` succeeded | `cd /tmp && ls` |
| `.ignore` | a file of gitignore-style paths that rg skips | a line `old/` hides that folder |

_Examples run in a made-up folder: `setup.md`, `run.py`, `draft.md` and an ignored `old/`._
""",
    "rg-globs": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `rg -c` | count matching lines **per file**, printed as `path:count` | `rg -c TODO` → `draft.md:2`, `run.py:1` |
| `-g 'GLOB'` | only search paths that match the glob | `rg -c TODO -g '*.md'` → `draft.md:2` |
| `-g '!GLOB'` | skip paths that match the glob | `rg TODO -g '!*.md'` |
| glob `*` | in a glob, `*` means "any text" (a regex would say `.*`) | `*_old.*` = names containing `_old.` |
| quoting | quote globs, or the shell expands `*` (and `!`) before rg sees them | |

_Examples use level 10's made-up folder: `draft.md` has 2 TODOs, `run.py` has 1._
""",
    "rg-replace": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `( )` | a capture group: remembers the text it matched | `user=(\w+)` captures the name |
| `-o -r '$1'` | rg prints group 1 instead of the whole match. Single quotes stop the shell expanding `$1` | `echo 'user=ana id=7' \| rg -o -r '$1' 'user=(\w+)'` → `ana` |
| `\S`, `\w`, `\d` | non-space, word character, digit (rg/Perl shorthands; grep knows `\S` and `\w`, not `\d`) | `echo 'id=42' \| rg -o '\d+'` → `42` |
| `sort`, `sort -u` | sort lines / sort and drop duplicates | `printf 'pear\napple\npear\n' \| sort -u` → `apple`, `pear` |
""",
    "rg-multiline": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `-U` | multiline: a pattern may span lines; write the newline as `\n` | `printf 'name:\n  ana\n' \| rg -U -o -r '$1' 'name:\n  (.+)'` → `ana` |
| `.*`, `.+` | any run of characters (zero or more / one or more); `.` never matches a newline | `Trace.*` = the rest of that line |
| `(?:...)` | a group that does **not** capture, so `$1` still points at your real group | `echo 'k: v' \| rg -o -r '$1' '(?:k\|key): (\w+)'` → `v` |
| `(...)+` | repeat a whole group | `echo 'abababc' \| rg -o '(?:ab)+'` → `ababab` |
""",
    "cut": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `tail -n +K` | print from line K to the end (`+2` skips a header) | `printf 'h\na\nb\n' \| tail -n +2` → `a`, `b` |
| `tail -n K` | just the last K lines | `tail -n 1 notes.txt` |
| `cut -d, -f2` | split each line on `,` and keep field 2 | `printf 'a,b,c\n1,2,3\n' \| cut -d, -f2` → `b`, `2` |
| `-f1,3`, `-f2-` | several fields / field 2 onward | `cut -d, -f1,3` on `a,b,c` → `a,c` |
""",
    "sort-uniq": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `uniq` | drop **adjacent** repeated lines, so it usually comes after `sort` | `printf 'b\nb\na\nb\n' \| uniq` → `b`, `a`, `b` |
| `sort \| uniq` | the same result as `sort -u` (level 12) | |

Everything else here is from levels 12 and 14.
""",
    "frequency": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `uniq -c` | prefix each line with how often it repeated (adjacent only, so `sort` first) | `printf 'x\nx\ny\n' \| uniq -c` → `2 x`, `1 y` |
| `sort -n` | numeric sort: `2 9 10` instead of text order `10 2 9` | `printf '9\n10\n2\n' \| sort -n` → `2`, `9`, `10` |
| `sort -r`, `sort -rn` | reverse / numeric, highest first | `printf '9\n10\n2\n' \| sort -rn` → `10`, `9`, `2` |
""",
    "head-tail": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `head -n 3` (or `head -3`) | only the first 3 lines | |
| `sort -t, -k2,2n` | split on `,`, sort by field 2 only, numerically | `printf 'b,7\na,12\nc,3\n' \| sort -t, -k2,2n` → `c,3`, `b,7`, `a,12` |
| `-k2,2nr` | letters glued to a key apply to that key: numeric, reversed | |
| `$'\t'` | bash: a real tab character (`$'\n'` is a newline) | `printf 'x\ty\n' \| cut -d$'\t' -f2` → `y` |
""",
    "tr": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `tr SET1 SET2` | swap each character of SET1 for the matching one in SET2. Reads stdin only | `echo Hi \| tr 'a-z' 'A-Z'` → `HI` |
| `'[:lower:]'`, `'[:upper:]'` | named character sets in tr | `echo Ab \| tr '[:lower:]' '[:upper:]'` → `AB` |
| `tr -d`, `tr -s` | delete those characters / squeeze repeats into one | `echo a-b-c \| tr -d -` → `abc` |
| `cmd < file` | feed a file into a command's stdin | `sort < list.txt` |
""",
    "wc": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `wc -l` | count lines (`-w` words, `-c` bytes) | `printf 'a\nb\n' \| wc -l` → `2` |
| padding | macOS prints the number with leading spaces; this level ignores them | |
""",
    "sed-substitute": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `sed 's/OLD/NEW/' FILE` | on every line, replace the first match of regex OLD with NEW; print every line | `echo a-b-c \| sed 's/-/+/'` → `a+b-c` |
| `s/OLD/NEW/g` | replace every match on the line | `echo a-b-c \| sed 's/-/+/g'` → `a+b+c` |
| `[^,]` | any one character **except** the listed ones | `echo 'tel: 555-1234' \| sed 's/[^ ]*$/<hidden>/'` → `tel: <hidden>` |
| NEW | plain text, except `&` (the whole match) and `\1` (level 23) | `echo cat \| sed 's/a/[&]/'` → `c[a]t` |
| `s#a#b#` | any delimiter works; handy when the text contains `/` | `echo /usr/local/bin \| sed 's#/usr/local#/opt#'` → `/opt/bin` |
""",
    "sed-range": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `sed -n '...p'` | `-n`: print nothing unless told to; `p`: print this line | `printf 'l1\nl2\nl3\n' \| sed -n '2p'` → `l2` |
| `2,4p`, `/re/p` | address lines by number range / by regex | `sed -n '/tea/p'` acts like `grep tea` |
| `/A/,/B/` | a range: from a line matching A through the next line matching B | `printf 'a\nSTART\nb\nEND\nc\n' \| sed -n '/START/,/END/p'` → `START`, `b`, `END` |
| `ADDR{cmd;}` | run commands only on the addressed lines; end each with `;` | `sed -n '/A/,/B/{/x/p;}'` |
| `\[` | a literal `[` (a bare `[` starts a class) | `sed -n '/^\[a\]/p'` matches the line `[a]` |
""",
    "sed-delete": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `/re/d` | delete matching lines | `printf 'keep\ndrop me\nkeep too\n' \| sed '/drop/d'` → `keep`, `keep too` |
| `s/re//` | an empty NEW deletes the matched text | `echo 'hello world' \| sed 's/ world//'` → `hello` |
| `-e A -e B` | several commands, applied in order to every line | `echo 'a b' \| sed -e 's/a/A/' -e 's/b/B/'` → `A B` |
""",
    "sed-capture": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `sed -E` | extended regex in sed: `( )`, `{4}`, `+` without backslashes (same on macOS and Linux) | |
| `\1`, `\2` in NEW | insert what group 1, 2 captured | `echo 'Doe, Jane' \| sed -E 's/([A-Za-z]+), ([A-Za-z]+)/\2 \1/'` → `Jane Doe` |
| `\1` in a pattern | a backreference: the same text again | `printf 'book\nbok\n' \| grep -E '(o)\1'` → `book` |
""",
    "sed-inplace": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `sed -i.bak '...' F` | edit F in place and keep the original as `F.bak`; works on BSD and GNU | |
| `sed -i '' ...` / `sed -i ...` | in place with no backup: the BSD (macOS) form / the GNU (Linux) form | |
| `ADDR{s/a/b/;s/c/d/;}` | several commands on one range: `;` between them, and before `}` for BSD sed | |

```sh
printf 'n = 1\n' > t.conf
sed -i.bak 's/1/2/' t.conf && rm t.conf.bak
cat t.conf                      # n = 2
```
""",
    "awk-fields": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `awk 'COND {ACTION}' F` | for every line where COND is true, run ACTION. No COND = every line; no ACTION = print the line | |
| `-F,` | split fields on `,` (without `-F`: on runs of spaces and tabs) | |
| `$1`, `$2`, ... | the fields of the current line | `echo 'a b c' \| awk '{print $2}'` → `b` |
| `==` `!=` `<` `>` | comparisons; string literals need double quotes | `$2 == "admin"` |
| `print a "x" b` | values written side by side are glued together | `print "[" $1 "]"` |
| `print a, b` | a comma puts one space between them | `echo 'a b' \| awk '{print $2, $1}'` → `b a` |

```sh
printf 'ana,admin\nbo,guest\n' | awk -F, '$2 == "admin" {print "[" $1 "]"}'   # [ana]
```
""",
    "awk-nr-nf": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `NF` | number of fields on this line | |
| `$NF` | the last field | |
| `NR` | the line (record) number, from 1 | |
| `$0` | the whole line | `printf 'a b\nc\n' \| awk 'NF != 2 {print NR, $0}'` → `2 c` |
| `-F'\t'` | split on tabs | |

```sh
printf 'a b c\nd e\n' | awk '{print NR ": " NF " fields, last " $NF}'
# 1: 3 fields, last c
# 2: 2 fields, last e
```
""",
    "awk-sum": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `t += $1` | add to a variable; variables need no declaration and start as 0 / `""` | `printf '1.2\n2.3\n' \| awk '{t += $1} END {print t}'` → `3.5` |
| `END {...}` | runs once, after the last line (`BEGIN {...}` runs before the first) | |
| `&&`, `\|\|`, `!` | and, or, not | `$1 > 0 && $2 == "x"` |
| `printf "%.1f\n", x` | formatted print: here 1 decimal. printf adds no newline, so write `\n` | `awk 'BEGIN {printf "%.1f\n", 3.14159}'` → `3.1` |
""",
    "awk-groupby": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `a[key]` | an associative array (a dict): any string key, created on first use | `n[$1]` |
| `x++` | add 1 | `n[$1]++` counts each first field |
| `for (k in a)` | loop over the keys, in **no particular order**, so pipe the output into `sort` | |
| `printf "%s %d\n", a, b` | `%s` string, `%d` whole number, `%.2f` two decimals | |

```sh
printf 'x\ny\nx\n' | awk '{n[$1]++} END {for (k in n) print k, n[k]}' | sort
# x 2
# y 1
```
""",
    "awk-printf": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `%-10s`, `%5d` | left-align in 10 columns / right-align in 5 | `awk 'BEGIN {printf "[%-6s][%4d]\n", "ab", 42}'` → `[ab    ][  42]` |
| `print ... \| "sort"` | inside awk: send these lines through a shell command | |
| `close("sort")` | finish that command (flush its output) before printing more | |
| `a; b` | several awk statements on one line | `{n++; t += $1}` |
| `{ a; b; }` | shell: group commands so their outputs form one stream | `{ echo top; ls; } \| head -3` |
""",
    "awk-join": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `awk '...' f1 f2` | one program reads f1, then f2 | |
| `FNR` | the line number within the current file (`NR` keeps counting across files) | |
| `NR == FNR` | true only while reading the first file | |
| `next` | stop working on this line and move on to the next one | |

```sh
# colors.txt: "1 red"  "2 blue"      items.txt: "pen 1"  "cup 2"
awk 'NR == FNR {c[$1] = $2; next} {print $1, c[$2]}' colors.txt items.txt
# pen red
# cup blue
```
""",
    "top-n": r"""
Nothing new: this is the classic top-N recipe, built from levels 16, 17 and 25.
In words: extract one column → `sort` → `uniq -c` → `sort -rn` → `head`.
Without `-F`, awk splits fields on spaces, so `awk '{print $1}'` is the first word of each line.
""",
    "time-window": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `substr(s, i, n)` | n characters of s, starting at position i (counting from 1) | `awk 'BEGIN {print substr("2026-01-31", 6, 2)}'` → `01` |
| `"10:05" < "10:30"` | comparing strings is alphabetical, which works for zero-padded times (`"9:00" < "10:00"` is false!) | |
| `split(s, a, "=")` | split s on `=` into `a[1]`, `a[2]`, ... | `echo 'k=v' \| awk '{split($1, p, "="); print p[2]}'` → `v` |
| multi-line program | a program inside `'...'` may span several lines | |
""",
    "flatten-config": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `-F' *= *'` | the separator can be a regex: here `=` with any spaces around it | `echo 'a - b' \| awk -F' *- *' '{print $2}'` → `b` |
| `/re/ {...}` | a regex as the condition: lines that match | `/^#/ {next}` skips comment lines |
| `sub(/re/, "x", v)`, `gsub(...)` | replace the first / every match inside v (default `$0`) | `echo '(x)' \| awk '{gsub(/[()]/, ""); print}'` → `x` |
| `toupper(s)`, `tolower(s)` | change case | `toupper("ab")` → `AB` |
| `[][]` | a class holding `]` and `[` (the `]` must come first) | |
| memory | a variable set on one line keeps its value on the following lines | |
""",
    "incident-report": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| several rules | `{...}` with no condition runs on every line; later `COND {...}` rules see the same line | |
| `if (c) stmt` | an `if` inside an action | `echo '3 9' \| awk '{if ($1 > 2) print "big"}'` → `big` |
| `/` | awk arithmetic is floating point | `awk 'BEGIN {print 7 / 2}'` → `3.5` |
| `sort -k2,2nr -k1,1` | sort by field 2 (numeric, descending), break ties by field 1 | `printf 'b 2\na 2\nc 5\n' \| sort -k2,2nr -k1,1` → `c 5`, `a 2`, `b 2` |
""",
    "culprit": r"""
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `x=$(cmd)` | run cmd and store its output in x (no spaces around `=`) | `x=$(echo hi \| tr a-z A-Z)` |
| `"$x"` | use the value; inside double quotes it can be part of a pattern | `grep "^$x,"` = lines starting with the value and a comma |
| `cut -d= -f2` | any single character can be cut's separator | `echo k=v \| cut -d= -f2` → `v` |
""",
}
