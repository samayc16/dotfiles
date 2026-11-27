#!/usr/bin/env bash
# Run a Python koan: the learner's koan.py (workspace) against test_koan.py (exercise dir).
# The koans use 3.12 syntax (def f[T]), so take the first interpreter new enough: the learn
# venv (learn/fetch.sh makes it), then python3, then versioned names.
set -euo pipefail
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PY="${LEARN_HOME:-$HOME/learn}/.venv/bin/python"

new_enough() { "$1" -c 'import sys; sys.exit(sys.version_info < (3, 12))' 2>/dev/null; }

PY=""
for candidate in "$VENV_PY" python3 python3.14 python3.13 python3.12; do
  path="$(command -v "$candidate" 2>/dev/null || true)"
  if [[ -n "$path" ]] && new_enough "$path"; then
    PY="$path"
    break
  fi
done
if [[ -z "$PY" ]]; then
  found="$(command -v python3 >/dev/null 2>&1 && python3 -c 'import platform; print(platform.python_version())' || echo none)"
  echo "✗ these koans need Python 3.12 or newer (python3 here: $found)."
  echo "  Install one (macOS: brew install python · Arch: pacman -S python), or run learn/fetch.sh for the learn venv."
  exit 127 # learn's "the checker couldn't run" code: not counted against the learner
fi
cd "$LEARN_WORKSPACE"
PYTHONPATH="$LEARN_WORKSPACE:$LIB" PYTHONDONTWRITEBYTECODE=1 exec "$PY" -P "$LEARN_EXERCISE_DIR/test_koan.py"
