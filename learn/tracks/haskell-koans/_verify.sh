#!/usr/bin/env bash
# Verify every koan: the starter must FAIL its check and solution/ must PASS.
# Usage: learn/tracks/haskell-koans/_verify.sh [NN-slug ...]
set -u
track="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$track" || exit 2
exercises=("$@")
[ ${#exercises[@]} -eq 0 ] && exercises=($(python3 -c 'import json; print("\n".join(json.load(open("track.json"))["order"]))'))

fails=0
for ex in "${exercises[@]}"; do
  before=$fails
  dir="$track/$ex"
  files=$(python3 -c 'import json,sys; print("\n".join(json.load(open(sys.argv[1]))["files"]))' "$dir/exercise.json")
  for mode in starter solution; do
    ws="$(mktemp -d "${TMPDIR:-/tmp}/koanws.XXXXXX")"
    for f in $files; do
      if [ "$mode" = starter ]; then cp "$dir/$f" "$ws/$f"; else cp "$dir/solution/$f" "$ws/$f"; fi
    done
    out="$(cd "$ws" && LEARN_EXERCISE_DIR="$dir" LEARN_WORKSPACE="$ws" bash "$dir/check.sh" 2>&1)"
    rc=$?
    rm -rf "$ws"
    if [ "$mode" = starter ] && [ $rc -eq 0 ]; then
      echo "✘ $ex: starter unexpectedly PASSES"; fails=$((fails + 1))
    elif [ "$mode" = solution ] && [ $rc -ne 0 ]; then
      echo "✘ $ex: solution FAILS"; printf '%s\n' "$out" | sed 's/^/    /' | head -30; fails=$((fails + 1))
    elif [ "$mode" = starter ] && ! printf '%s\n' "$out" | grep -q '^☯ '; then
      echo "✘ $ex: starter doesn't compile (learners should start with a running harness)"
      printf '%s\n' "$out" | sed 's/^/    /' | head -20; fails=$((fails + 1))
    fi
  done
  [ $fails -eq $before ] && echo "✔ $ex"
done
echo
[ $fails -eq 0 ] && echo "All ${#exercises[@]} koans verified." || { echo "$fails problem(s)."; exit 1; }
