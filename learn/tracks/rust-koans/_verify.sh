#!/usr/bin/env bash
# Verify every koan: the starter must FAIL its check and solution/ must PASS it, with no
# clippy tips. Starters must compile (the learner starts with ✓/✗ lines), except where
# exercise.json says "starter_compiles": false because the compile error is the lesson.
#
# Usage: learn/tracks/rust-koans/_verify.sh [NN-slug ...]
# Builds go to a throwaway LEARN_HOME, never ~/learn. Set KOAN_VERIFY_HOME to a directory
# to keep the build cache between runs.
set -u
track="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$track" || exit 2
if [ -n "${KOAN_VERIFY_HOME:-}" ]; then
  home="$KOAN_VERIFY_HOME"
else
  home="$(mktemp -d "${TMPDIR:-/tmp}/rust-koans-verify.XXXXXX")"
  trap 'rm -rf "$home"' EXIT
fi
export LEARN_HOME="$home" NO_COLOR=1
unset LEARN_FORCE_COLOR

exercises=("$@")
if [ ${#exercises[@]} -eq 0 ]; then
  exercises=($(python3 -c 'import json; print("\n".join(json.load(open("track.json"))["order"]))'))
fi

# field <exercise.json> <key>: a list prints one item per line, false prints "false".
field() {
  python3 -c 'import json, sys
v = json.load(open(sys.argv[1])).get(sys.argv[2])
print("\n".join(v) if isinstance(v, list) else ("false" if v is False else ""))' "$1" "$2"
}

show() { printf '%s\n' "$1" | sed 's/^/    /' | head -"${2:-25}"; }

fails=0
for ex in "${exercises[@]}"; do
  before=$fails
  dir="$track/$ex"
  files=$(field "$dir/exercise.json" files)
  compiles=$(field "$dir/exercise.json" starter_compiles)
  summary=""
  for mode in starter solution; do
    ws="$home/ws/$ex/$mode"
    rm -rf "$ws" && mkdir -p "$ws"
    for f in $files; do
      src="$dir/$f"
      [ "$mode" = solution ] && src="$dir/solution/$f"
      mkdir -p "$(dirname "$ws/$f")" && cp "$src" "$ws/$f"
    done
    out="$(cd "$ws" && LEARN_EXERCISE_DIR="$dir" LEARN_WORKSPACE="$ws" bash "$dir/check.sh" 2>&1)"
    rc=$?
    if [ "$mode" = starter ]; then
      summary=$(printf '%s\n' "$out" | grep -E 'checks passing|doesn.t compile yet' | sed 's/^ *//; s/:.*//' | head -1)
      if [ $rc -eq 0 ]; then
        echo "✘ $ex: starter unexpectedly PASSES"; fails=$((fails + 1))
      elif [ "$compiles" = false ] && ! grep -q "doesn't compile yet" <<<"$out"; then
        echo "✘ $ex: starter should start with a compile error (starter_compiles: false)"; show "$out"; fails=$((fails + 1))
      elif [ "$compiles" != false ] && ! grep -q 'checks passing' <<<"$out"; then
        echo "✘ $ex: starter doesn't compile"; show "$out"; fails=$((fails + 1))
      fi
    elif [ $rc -ne 0 ]; then
      echo "✘ $ex: solution FAILS"; show "$out" 40; fails=$((fails + 1))
    elif grep -q 'clippy has' <<<"$out"; then
      echo "✘ $ex: solution passes but clippy has tips"; show "$out" 40; fails=$((fails + 1))
    fi
  done
  [ $fails -eq $before ] && echo "✔ $ex  (starter: $summary)"
done
echo
if [ $fails -eq 0 ]; then
  echo "All ${#exercises[@]} koans verified: every starter fails, every solution passes clippy-clean."
else
  echo "$fails problem(s)."
  exit 1
fi
