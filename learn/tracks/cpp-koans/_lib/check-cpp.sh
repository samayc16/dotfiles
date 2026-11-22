#!/usr/bin/env bash
# Compile the learner's koan.cpp (included by the exercise's test.cpp) as C++26 with
# AddressSanitizer + UndefinedBehaviorSanitizer, then run the checks.
set -euo pipefail
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CXX="${CXX:-$(command -v clang++ || command -v g++)}"
BUILD="$(mktemp -d)"
trap 'rm -rf "$BUILD"' EXIT
if ! "$CXX" -std=c++26 -Wall -Wextra -g -O0 -fsanitize=address,undefined -fno-omit-frame-pointer \
    -I"$LEARN_WORKSPACE" -I"$LIB" "$LEARN_EXERCISE_DIR/test.cpp" -o "$BUILD/koan"; then
  echo "✗ doesn't compile yet: fix the errors above (in nvim: ]d jumps to the next diagnostic, K explains a symbol)"
  exit 1
fi
cd "$LEARN_WORKSPACE"
ASAN_OPTIONS="detect_leaks=0" UBSAN_OPTIONS="print_stacktrace=1:halt_on_error=1" "$BUILD/koan"
