#!/usr/bin/env bash
# Compile the learner's koan.c (included by the exercise's test.c) as C23 with
# AddressSanitizer + UndefinedBehaviorSanitizer, then run the checks.
set -euo pipefail
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CC="${CC:-$(command -v clang || command -v gcc || true)}"
if [[ -z "$CC" ]] || ! command -v "$CC" >/dev/null; then
  echo "✗ no C compiler: install clang or gcc (macOS: xcode-select --install · Arch: pacman -S clang)"
  exit 127 # learn's "the checker couldn't run" code: not counted against the learner
fi
BUILD="$(mktemp -d)"
trap 'rm -rf "$BUILD"' EXIT
if ! "$CC" -std=c23 -Wall -Wextra -g -O0 -fsanitize=address,undefined -fno-omit-frame-pointer \
    -I"$LEARN_WORKSPACE" -I"$LIB" "$LEARN_EXERCISE_DIR/test.c" -o "$BUILD/koan" -lm; then
  echo "✗ doesn't compile yet: fix the errors above (in nvim: ]d jumps to the next diagnostic)"
  exit 1
fi
cd "$LEARN_WORKSPACE"
# Short sanitizer reports: source lines instead of addresses, no shadow-byte legend.
export ASAN_OPTIONS="detect_leaks=0:abort_on_error=0:print_legend=0:stack_trace_format='    #%n %f %S'"
export UBSAN_OPTIONS="print_stacktrace=1:halt_on_error=1:stack_trace_format='    #%n %f %S'"
status=0
"$BUILD/koan" 2>"$BUILD/stderr" || status=$?
bash "$LIB/sanitizer-report.sh" "$BUILD/stderr" "$status"
exit "$status"
