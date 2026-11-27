#!/usr/bin/env bash
# Rust koans: find the toolchain, then hand over to koancheck.py, which builds the learner's
# src/ against the exercise's pristine Cargo.toml + tests/checks.rs and prints ✓/✗ per check.
#
# Contract (learn CLI): cwd = workspace, LEARN_EXERCISE_DIR = exercise dir in the repo,
# LEARN_WORKSPACE = workspace. Exit 0 = every check passed.
set -euo pipefail
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v cargo >/dev/null; then
  # Homebrew's rustup is keg-only and rustup-init installs to ~/.cargo/bin: a GUI-launched
  # editor may have neither on PATH.
  for dir in "$HOME/.cargo/bin" /opt/homebrew/opt/rustup/bin /usr/local/opt/rustup/bin; do
    if [[ -x "$dir/cargo" ]]; then
      PATH="$dir:$PATH"
      break
    fi
  done
fi
if ! command -v cargo >/dev/null; then
  echo "✗ cargo not found: install Rust with rustup (macOS: brew install rustup · Linux: https://rustup.rs)"
  exit 127 # learn's "the checker couldn't run" code: not counted against the learner
fi
exec python3 -I "$LIB/koancheck.py"
