#!/usr/bin/env bash
# Shared checker for the shell track. Each level's check.sh sets a few variables
# and sources this file:
#
#   MODE=exact|ws|sorted   exact: compare as-is (trailing spaces ignored)
#                          ws:     also ignore leading/repeated spaces (uniq -c, wc)
#                          sorted: ws + ignore line order (multi-file rg output)
#   PAR=<n>                golf target in characters (informational here)
#   REQUIRE=<ERE>          solution code must match (e.g. must use rg)
#   REQUIRE_HINT=<text>    human-readable version of REQUIRE
#   FORBID=<ERE>           solution code must NOT match
#   FORBID_HINT=<text>
#   CHECK_FILE=<name>      file-editing level: run in a scratch dir holding a fresh
#                          copy of <name> and compare the edited file instead of stdout
#
# Contract (learn CLI): cwd = workspace, LEARN_EXERCISE_DIR = exercise dir in repo,
# LEARN_WORKSPACE = workspace. Exit 0 = pass.
set -u

EX=${LEARN_EXERCISE_DIR:?LEARN_EXERCISE_DIR is not set - run this through: learn check}
WS=${LEARN_WORKSPACE:-$PWD}
SOL="$WS/solution.sh"
MODE=${MODE:-exact}
TIMEOUT=${TIMEOUT:-10}

if [ -z "${NO_COLOR:-}" ] && { [ -t 1 ] || [ -n "${LEARN_FORCE_COLOR:-}" ]; }; then
  G=$'\033[32m' R=$'\033[31m' Y=$'\033[33m' D=$'\033[2m' N=$'\033[0m'
else
  G= R= Y= D= N=
fi
pass() { printf '%s✓ %s%s\n' "$G" "$*" "$N"; }
fail() { printf '%s✗ %s%s\n' "$R" "$*" "$N"; exit 1; }
note() { printf '%s%s%s\n' "$D" "$*" "$N"; }
# 127 is learn's "the checker couldn't run" code: a missing tool isn't counted against the learner.
missing() { printf '%s✗ %s%s\n' "$R" "$*" "$N"; exit 127; }

command -v perl >/dev/null || missing "perl not found (the checker uses it for timeouts)"
required=${REQUIRE_HINT:-}
tool=${required%% *}
if [ -n "$tool" ] && ! command -v "$tool" >/dev/null; then
  [ "$tool" = rg ] && how=" (macOS: brew install ripgrep · Arch: pacman -S ripgrep · Debian: apt install ripgrep)"
  missing "$tool is not installed, and this level is about it${how:-}"
fi
[ -f "$SOL" ] || fail "No solution.sh in $WS"

# Code without comments/blank lines, used for REQUIRE/FORBID and the golf count.
code=$(grep -v -E '^[[:space:]]*(#|$)' "$SOL" || true)
chars=$(printf '%s\n' "$code" | awk '{ gsub(/^[[:space:]]+|[[:space:]]+$/, ""); n += length($0) } END { print n + 0 }')

if [ -n "${REQUIRE:-}" ] && ! printf '%s\n' "$code" | grep -Eq -- "$REQUIRE"; then
  fail "This level wants you to use: ${REQUIRE_HINT:-$REQUIRE}"
fi
if [ -n "${FORBID:-}" ] && printf '%s\n' "$code" | grep -Eq -- "$FORBID"; then
  fail "Not allowed on this level: ${FORBID_HINT:-$FORBID}"
fi

tmp=$(mktemp -d "${TMPDIR:-/tmp}/learn-shell.XXXXXX")
trap 'rm -rf "$tmp"' EXIT

# Run with a hard timeout (perl is everywhere; coreutils `timeout` is not on macOS).
run_solution() {
  LC_ALL=C LEARN_EXERCISE_DIR="$EX" perl -e 'alarm shift; exec @ARGV or die "exec failed: $!\n"' "$TIMEOUT" bash "$SOL"
}

mkdir -p "$tmp/run"
if [ -n "${CHECK_FILE:-}" ]; then
  cp "$EX/$CHECK_FILE" "$tmp/run/$CHECK_FILE"
  (cd "$tmp/run" && run_solution) >"$tmp/stdout" 2>"$tmp/stderr"
  rc=$?
  cp "$tmp/run/$CHECK_FILE" "$tmp/got.raw" 2>/dev/null || : >"$tmp/got.raw"
else
  (cd "$WS" && run_solution) >"$tmp/got.raw" 2>"$tmp/stderr"
  rc=$?
fi

if [ "$rc" -eq 142 ]; then
  fail "Timed out after ${TIMEOUT}s. A command is probably waiting on stdin - did you forget the input file?"
fi

normalize() {
  # strip trailing whitespace; drop trailing blank lines
  sed -e 's/[[:space:]]*$//' |
    awk '{ line[NR] = $0 } END { n = NR; while (n > 0 && line[n] == "") n--; for (i = 1; i <= n; i++) print line[i] }' |
    case "$MODE" in
      exact) cat ;;
      ws) sed -e 's/^[[:space:]]*//' -e 's/[[:space:]][[:space:]]*/ /g' ;;
      sorted) sed -e 's/^[[:space:]]*//' -e 's/[[:space:]][[:space:]]*/ /g' | LC_ALL=C sort ;;
      *) cat ;;
    esac
}

normalize <"$EX/expected.txt" >"$tmp/exp"
normalize <"$tmp/got.raw" >"$tmp/got"

if cmp -s "$tmp/exp" "$tmp/got"; then
  if [ -n "${CHECK_FILE:-}" ]; then
    leftovers=$(cd "$tmp/run" && ls -A | grep -v -x -F "$CHECK_FILE" || true)
    [ -z "$leftovers" ] || fail "The file is right, but you left extra files behind: $(echo $leftovers). Clean up backups too."
  fi
  lines=$(wc -l <"$tmp/exp" | tr -d ' ')
  pass "Correct! ($lines lines match)"
  if [ -n "${PAR:-}" ]; then
    if [ "$chars" -le "$PAR" ]; then
      pass "Golf: $chars chars (par $PAR) - under par!"
    else
      note "Golf: $chars chars (par $PAR) - can you get it under par for the third star?"
    fi
  fi
  exit 0
fi

exp_n=$(wc -l <"$tmp/exp" | tr -d ' ')
got_n=$(wc -l <"$tmp/got" | tr -d ' ')
if [ -n "${CHECK_FILE:-}" ]; then
  printf '%s✗ %s does not look right yet.%s\n' "$R" "$CHECK_FILE" "$N"
else
  printf '%s✗ Output does not match yet.%s\n' "$R" "$N"
fi
note "  expected $exp_n lines, got $got_n"
first=$(awk 'NR == FNR { e[FNR] = $0; n = FNR; next } { g[FNR] = $0; m = FNR }
  END { max = n > m ? n : m; for (i = 1; i <= max; i++) if (e[i] != g[i]) { print i; exit } }' "$tmp/exp" "$tmp/got")
if [ -n "$first" ]; then
  printf '  first difference at line %s:\n' "$first"
  printf '    %sexpected:%s %s\n' "$G" "$N" "$(sed -n "${first}p" "$tmp/exp")"
  printf '    %sgot:     %s %s\n' "$R" "$N" "$(sed -n "${first}p" "$tmp/got")"
fi
if [ "$MODE" = sorted ]; then note "  (line order is ignored on this level)"; fi
if [ "$MODE" = ws ]; then note "  (leading/repeated spaces are ignored on this level)"; fi
note "--- diff: < expected  > yours (first 12 lines) ---"
diff "$tmp/exp" "$tmp/got" | head -12
if [ -s "$tmp/stderr" ]; then
  printf '%sYour script printed errors:%s\n' "$Y" "$N"
  head -5 "$tmp/stderr"
fi
[ "$rc" -eq 0 ] || note "(solution.sh exited with status $rc)"
exit 1
