#!/usr/bin/env bash
# Claude Code CLI, the language servers its LSP plugins use, and the plugins themselves.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

install_cli() {
  if has claude; then
    ok "claude already installed ($(claude --version 2>/dev/null | head -n1))"
  elif [[ "$OS" == macos ]]; then
    run brew install --cask claude-code
  else
    # Official native installer: user-local, no root, auto-updates.
    local script
    script="$(mktemp)"
    fetch https://claude.ai/install.sh "$script"
    run bash "$script"
    rm -f "$script"
  fi
}

# pyright-lsp and lua-lsp plugins expect these on PATH.
install_lsp_servers() {
  if has pyright-langserver; then
    ok "pyright-langserver present"
  elif has npm; then
    run npm install --global --silent pyright
  else
    warn "npm not found: skipping pyright (Claude's Python LSP plugin)"
  fi

  local mason_lua="$HOME/.local/share/nvim/mason/bin/lua-language-server"
  if has lua-language-server; then
    ok "lua-language-server present"
  elif [[ -x "$mason_lua" ]]; then
    link "$mason_lua" "$LOCAL_PREFIX/bin/lua-language-server" # reuse Neovim's copy
  elif [[ "$OS" == macos ]]; then
    run brew install lua-language-server
  else
    warn "lua-language-server not found yet: re-run \`./install.sh --only claude\` after the nvim step"
  fi
}

main() {
  section "Claude Code"
  export PATH="$LOCAL_PREFIX/bin:$PATH"
  install_cli
  has claude || return 0
  install_lsp_servers
  if [[ "$DRY_RUN" == 1 ]]; then
    info "would run claude/install-plugins.sh"
  elif bash "$DOTFILES/claude/install-plugins.sh"; then
    ok "plugins installed"
  else
    warn "plugin install failed (offline?): re-run claude/install-plugins.sh later"
  fi
}

main "$@"
