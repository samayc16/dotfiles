#!/usr/bin/env bash
# Compile the learner's Koan.swift with the exercise's main.swift (the checks) in
# Swift 6 language mode (strict concurrency), then run it.
set -euo pipefail
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v swiftc >/dev/null; then
  echo "✗ swiftc not found: install Xcode or the Swift toolchain (https://swift.org/install)"
  exit 127 # learn's "the checker couldn't run" code: not counted against the learner
fi
BUILD="$(mktemp -d)"
trap 'rm -rf "$BUILD"' EXIT
if ! swiftc -swift-version 6 -Onone -g -module-name Koans -o "$BUILD/koan" \
    "$LEARN_WORKSPACE/Koan.swift" "$LIB/KoanHarness.swift" "$LEARN_EXERCISE_DIR/main.swift"; then
  echo "✗ doesn't compile yet: fix the errors above (in nvim: ]d next diagnostic, K for docs)"
  exit 1
fi
cd "$LEARN_WORKSPACE"
"$BUILD/koan"
