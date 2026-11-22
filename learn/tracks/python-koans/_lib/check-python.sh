#!/usr/bin/env bash
# Run a Python koan: the learner's koan.py (workspace) against test_koan.py (exercise dir).
set -euo pipefail
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY="$HOME/learn/.venv/bin/python"
[[ -x "$PY" ]] || PY="$(command -v python3)"
cd "$LEARN_WORKSPACE"
PYTHONPATH="$LEARN_WORKSPACE:$LIB" PYTHONDONTWRITEBYTECODE=1 exec "$PY" -P "$LEARN_EXERCISE_DIR/test_koan.py"
