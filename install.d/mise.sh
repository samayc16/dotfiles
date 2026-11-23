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

check_node() {
  has node && node --version >/dev/null 2>&1 && { ok "node $(node --version)"; return 0; }
  if ! ldconfig -p 2>/dev/null | grep -q libatomic.so.1; then
    warn "node needs libatomic.so.1 (dnf install libatomic / zypper install libatomic1);" \
      "npm-based language servers (bash-language-server) are skipped until then"
  else
    warn "node unavailable; npm-based language servers are skipped"
  fi
}

main() {
  section "mise tools (user-local)"
  ensure_mise
  # Use the repo manifest directly so this works even before links.sh has run.
  # Keep going if a single tool fails; only the core tools below are required.
  run env MISE_GLOBAL_CONFIG_FILE="$DOTFILES/mise/global.toml" mise install --yes || warn "some mise tools failed (see above)"
  [[ "$DRY_RUN" == 1 ]] && return 0
  run env MISE_GLOBAL_CONFIG_FILE="$DOTFILES/mise/global.toml" mise reshim
  local tool missing=0
  for tool in nvim rg fd fzf bat eza delta lazygit zoxide tree-sitter tmux jq; do
    if has "$tool"; then ok "$tool"; else err "$tool missing after mise install"; missing=1; fi
  done
  check_node
  return "$missing"
}

main "$@"
