#!/usr/bin/env bash
# Verify every systemverilog exercise:
#   (a) the starter files fail the check   (b) the reference solution passes
#
# Usage: learn/tracks/systemverilog/_verify.sh [EXERCISE_DIR...]
set -u
TRACK=$(cd "$(dirname "$0")" && pwd)

if [ $# -gt 0 ]; then
  exercises=("$@")
else
  exercises=()
  while IFS= read -r e; do exercises+=("$e"); done < <(python3 -I -c 'import json,sys; print("\n".join(json.load(open(sys.argv[1]))["order"]))' "$TRACK/track.json")
fi

ok=0 bad=0
for name in "${exercises[@]}"; do
  name=${name%/}
  name=${name##*/}
  ex="$TRACK/$name"
  problems=""
  ws=$(mktemp -d "${TMPDIR:-/tmp}/verify-sv.XXXXXX")
  for f in $(python3 -I -c 'import json,sys; print(" ".join(json.load(open(sys.argv[1]))["files"]))' "$ex/exercise.json"); do
    cp "$ex/$f" "$ws/"
  done
  if (cd "$ws" && LEARN_EXERCISE_DIR="$ex" LEARN_WORKSPACE="$ws" bash "$ex/check.sh") >"$ws/.starter.log" 2>&1; then
    problems="$problems starter-passes"
  fi
  cp "$ex/solution/"* "$ws/"
  if ! (cd "$ws" && LEARN_EXERCISE_DIR="$ex" LEARN_WORKSPACE="$ws" bash "$ex/check.sh") >"$ws/.solution.log" 2>&1; then
    problems="$problems solution-fails"
    sed 's/^/      /' "$ws/.solution.log" | tail -20
  fi
  if grep -q 'Lint (' "$ws/.solution.log"; then
    problems="$problems solution-has-lint-warnings"
    sed -n '/Lint (/,/^[^ ]/p' "$ws/.solution.log" | sed 's/^/      /' | head -8
  fi
  starter_summary=$(grep -m1 -E '✗' "$ws/.starter.log" | sed 's/\x1b\[[0-9;]*m//g')
  rm -rf "$ws"
  if [ -z "$problems" ]; then
    ok=$((ok + 1))
    printf '  ok   %-24s starter: %s\n' "$name" "$starter_summary"
  else
    bad=$((bad + 1))
    printf '  FAIL %s:%s\n' "$name" "$problems"
  fi
done
echo "verified: $ok ok, $bad failing"
[ "$bad" -eq 0 ]
