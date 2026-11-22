# shell track

35 levels of grep, ripgrep, cut/sort/uniq/tr/wc, sed and awk, played as an on-call engineer at a fictional
SaaS. Each level is a `solution.sh` whose output is checked against `expected.txt`. Most levels have a golf
par (characters of code) for the third star.

- Play: `learn` (this repo's CLI) · requirements: bash, perl, ripgrep, POSIX grep/sed/awk.
- Data: `data/` (synthetic: fictional people, example.com/.org/.net emails, RFC 5737 TEST-NET IPs).
- Rebuild data, levels and expected outputs: `python3 -I _gen/build.py`
- Verify every level (starter fails, reference passes, reference within par): `./_verify.sh`
  and `./_verify.sh --gnu` to repeat it with GNU grep/sed/awk/coreutils (Homebrew gnubin), as on Linux.
- Shared checker: `_lib/check.sh` (modes: exact, ws, sorted; REQUIRE/FORBID tools; file-editing levels).
