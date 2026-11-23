#!/usr/bin/env bash
# `learn` exercise tracks: fetch vendored exercises/example projects into ~/learn
# (opt-in: --with learn; part of --profile full). Delegates to learn/fetch.sh.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

script="$DOTFILES/learn/fetch.sh"
[[ -f "$script" ]] || skip "learn/fetch.sh not found"
section "Learning tracks"
run bash "$script"
run bash "$DOTFILES/claude/trust.sh" # trust the newly cloned example projects
