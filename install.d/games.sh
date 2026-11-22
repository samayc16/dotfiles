#!/usr/bin/env bash
# Offline games + trainers (opt-in: --with games; part of --profile full).
# Delegates to games/install.sh, which owns the game list.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

script="$DOTFILES/games/install.sh"
[[ -f "$script" ]] || skip "games/install.sh not found"
section "Games"
run bash "$script"
