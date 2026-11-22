#!/usr/bin/env bash
# Linux: user-local dev tools via mise (neovim, ripgrep, fd, fzf, …) — no root.
# Set GITHUB_TOKEN to avoid GitHub API rate limits on shared IPs.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

[[ "$OS" == macos ]] && skip "macOS gets these tools from Homebrew"

MISE_BIN="$LOCAL_PREFIX/bin/mise"
export PATH="$LOCAL_PREFIX/bin:$HOME/.local/share/mise/shims:$PATH"

ensure_mise() {
  if has mise; then
    ok "mise $(mise --version 2>/dev/null | awk '{print $1}')"
    return 0
  fi
  info "Installing mise → $MISE_BIN"
  local script
  script="$(mktemp)"
  fetch https://mise.run "$script"
  run env MISE_INSTALL_PATH="$MISE_BIN" sh "$script"
  rm -f "$script"
}

main() {
  section "mise tools (user-local)"
  ensure_mise
  # Use the repo manifest directly so this works even before links.sh has run.
  run env MISE_GLOBAL_CONFIG_FILE="$DOTFILES/mise/global.toml" mise install --yes
  [[ "$DRY_RUN" == 1 ]] && return 0
  run env MISE_GLOBAL_CONFIG_FILE="$DOTFILES/mise/global.toml" mise reshim
  local tool
  for tool in nvim rg fd fzf bat eza delta lazygit zoxide tree-sitter tmux; do
    if has "$tool"; then ok "$tool"; else warn "$tool not on PATH after mise install"; fi
  done
}

main "$@"
