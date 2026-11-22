#!/usr/bin/env bash
# Verify every shell-track level:
#   (a) the starter fails its check   (b) the reference solution passes
#   (c) the reference fits within par
#
# Usage: learn/tracks/shell/_verify.sh [--gnu] [LEVEL_DIR...]
#   --gnu  put GNU grep/sed/awk/coreutils (Homebrew gnubin dirs) first on PATH,
#          to check that levels behave the same as on Linux.
set -u
TRACK=$(cd "$(dirname "$0")" && pwd)

if [ "${1:-}" = --gnu ]; then
  shift
  gnubin=""
  for d in /opt/homebrew/opt/{grep,gnu-sed,coreutils,gawk}/libexec/gnubin /usr/local/opt/{grep,gnu-sed,coreutils,gawk}/libexec/gnubin; do
    [ -d "$d" ] && gnubin="$gnubin$d:"
  done
  if [ -z "$gnubin" ]; then echo "no GNU tools found (brew install grep gnu-sed coreutils gawk)"; exit 2; fi
  export PATH="$gnubin$PATH"
  # gawk is installed as gawk; expose it as awk for this run
  shim=$(mktemp -d "${TMPDIR:-/tmp}/gnu-awk.XXXXXX")
  command -v gawk >/dev/null && ln -s "$(command -v gawk)" "$shim/awk" && export PATH="$shim:$PATH"
  echo "GNU mode: $(awk --version 2>&1 | head -1) · $(sed --version | head -1) · $(grep --version | head -1)"
fi

if [ $# -gt 0 ]; then
  levels=("$@")
else
  levels=()
  while IFS= read -r l; do levels+=("$l"); done < <(python3 -I -c 'import json,sys; print("\n".join(json.load(open(sys.argv[1]))["order"]))' "$TRACK/track.json")
fi

code_chars() {
  grep -v -E '^[[:space:]]*(#|$)' "$1" | awk '{ gsub(/^[[:space:]]+|[[:space:]]+$/, ""); n += length($0) } END { print n + 0 }'
}

ok=0 bad=0
for name in "${levels[@]}"; do
  name=${name%/}
  name=${name##*/}
  ex="$TRACK/$name"
  par=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1])).get("par", ""))' "$ex/exercise.json")
  problems=""

  ws=$(mktemp -d "${TMPDIR:-/tmp}/verify-shell.XXXXXX")
  for f in $(python3 -I -c 'import json,sys; print(" ".join(json.load(open(sys.argv[1]))["files"]))' "$ex/exercise.json"); do
    cp "$ex/$f" "$ws/"
  done
  if (cd "$ws" && LEARN_EXERCISE_DIR="$ex" LEARN_WORKSPACE="$ws" bash "$ex/check.sh") >/dev/null 2>&1; then
    problems="$problems starter-passes"
  fi
  cp "$ex/solution/"* "$ws/"
  if ! out=$(cd "$ws" && LEARN_EXERCISE_DIR="$ex" LEARN_WORKSPACE="$ws" bash "$ex/check.sh" 2>&1); then
    problems="$problems solution-fails"
    echo "$out" | sed 's/^/      /' | head -15
  fi
  if [ -n "$par" ]; then
    chars=$(code_chars "$ex/solution/solution.sh")
    [ "$chars" -le "$par" ] || problems="$problems over-par($chars>$par)"
  fi
  rm -rf "$ws"

  if [ -z "$problems" ]; then
    ok=$((ok + 1))
    printf '  ok   %s (par %s)\n' "$name" "$par"
  else
    bad=$((bad + 1))
    printf '  FAIL %s:%s\n' "$name" "$problems"
  fi
done
echo "verified: $ok ok, $bad failing"
[ "$bad" -eq 0 ]
