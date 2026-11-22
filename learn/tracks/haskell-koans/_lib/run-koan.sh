#!/usr/bin/env bash
# Shared koan runner. Interprets the exercise's read-only Test.hs with `runghc`, putting
# the learner's workspace and this _lib dir on GHC's import path. Only GHC's bundled
# packages are used, so it works offline.
set -u
ex="${LEARN_EXERCISE_DIR:?LEARN_EXERCISE_DIR is not set; run this via: learn check}"
ws="${LEARN_WORKSPACE:-$PWD}"
lib="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v runghc >/dev/null 2>&1; then
  echo "✘ runghc not found. Install GHC (macOS: brew install ghc · Arch: pacman -S ghc)."
  exit 2
fi

# Run Test.hs from a scratch copy so the only `import <YourModule>` match is the workspace.
run_dir="$(mktemp -d "${TMPDIR:-/tmp}/koan.XXXXXX")"
trap 'rm -rf "$run_dir"' EXIT
cp "$ex/Test.hs" "$run_dir/Test.hs"

# perl's alarm is a portable timeout (macOS has no `timeout` by default).
out="$(cd "$ws" && perl -e 'alarm shift; exec @ARGV' 90 \
  runghc --ghc-arg=-i"$ws" --ghc-arg=-i"$lib" --ghc-arg=-fdiagnostics-color=never \
  "$run_dir/Test.hs" 2>&1)"
status=$?

if printf '%s\n' "$out" | grep -q '^☯ '; then
  printf '%s\n' "$out" # the harness ran; its report lists every koan
  exit "$status"
fi

if [ "$status" -eq 142 ]; then
  echo "✘ Timed out after 90s. Is something looping forever?"
  exit 1
fi

echo "✘ Your code doesn't compile yet. GHC says:"
echo
printf '%s\n' "$out" | sed -e "s|$ws/||g" -e "s|$run_dir/||g" | head -40
echo
echo "Tip: in nvim, HLS underlines the same error. Hover it with K, or try a code action (gra)."
exit 1
