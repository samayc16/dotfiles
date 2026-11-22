#!/usr/bin/env bash
# Neovim first run, headless:
#   lazy      plugins pinned by nvim/lazy-lock.json                         (every profile)
#   bootstrap language servers, formatters, debug adapters (mason) and all
#             treesitter parsers, synchronously — nvim/scripts/bootstrap.lua (dev, full)
# Skip either with --without lazy / --without bootstrap.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

NVIM_MIN_VERSION="0.12.0"
BOOTSTRAP_SCRIPT="$HOME/.config/nvim/scripts/bootstrap.lua"

check_prereqs() {
  export PATH="$LOCAL_PREFIX/bin:$HOME/.local/share/mise/shims:$PATH"
  has nvim || skip "nvim not installed"
  local version
  version="$(nvim --version | head -n1 | sed 's/^NVIM v//; s/-.*//')"
  if ! version_ge "$version" "$NVIM_MIN_VERSION"; then
    err "nvim $version is too old (config needs ≥ $NVIM_MIN_VERSION) — run: ./install.sh --only mise"
    exit 1
  fi
  has git || { err "git is required for plugin installs"; exit 1; }
  if ! has cc || ! has make; then warn "no cc/make: treesitter parsers and telescope-fzf-native can't build"; fi
  has tree-sitter || warn "no tree-sitter CLI: parsers can't be built"
}

main() {
  section "Neovim plugins, parsers, language servers"
  check_prereqs
  local failed=0
  if wants lazy cli; then
    info "plugins (lazy-lock.json)…"
    run nvim --headless "+Lazy! restore" +qa || { warn "Lazy restore reported errors"; failed=1; }
  fi
  if wants bootstrap dev && [[ -f "$BOOTSTRAP_SCRIPT" || "$DRY_RUN" == 1 ]]; then
    info "language servers + treesitter parsers (several minutes on first run)…"
    run nvim --headless -c "luafile $BOOTSTRAP_SCRIPT" || { warn "bootstrap reported errors"; failed=1; }
  fi
  [[ "$failed" == 0 ]] && ok "nvim ready"
  return "$failed"
}

main "$@"
