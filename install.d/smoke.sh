#!/usr/bin/env bash
# Final check: per-language smoke test in headless nvim (treesitter, LSP attach,
# diagnostics, completion, compile + run). Languages whose toolchain is absent are
# skipped by the script. Restrict with SMOKE_ONLY=<lang>.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

SMOKE_SCRIPT="$DOTFILES/nvim/scripts/smoke.lua"

main() {
  section "Smoke test (nvim)"
  export PATH="$LOCAL_PREFIX/bin:$HOME/.local/share/mise/shims:$PATH"
  if ! has nvim && is_musl; then skip "no Neovim: it publishes no musl build (Alpine: apk add neovim)"; fi
  has nvim || skip "nvim not installed"
  [[ -f "$SMOKE_SCRIPT" ]] || skip "no smoke test at $SMOKE_SCRIPT"
  use_repo_nvim_config
  run nvim --headless -c "luafile $SMOKE_SCRIPT"
}

main "$@"
