#!/usr/bin/env bash
# Neovim first run, headless:
#   lazy      plugins pinned by nvim/lazy-lock.json                         (every profile)
#   bootstrap language servers, formatters, debug adapters (mason) and all
#             treesitter parsers, synchronously — nvim/scripts/bootstrap.lua (dev, full)
# Skip either with --without lazy / --without bootstrap.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

NVIM_MIN_VERSION="0.12.0"
BOOTSTRAP_SCRIPT="$DOTFILES/nvim/scripts/bootstrap.lua"

check_prereqs() {
  export PATH="$LOCAL_PREFIX/bin:$HOME/.local/share/mise/shims:$PATH"
  if ! has nvim && is_musl; then skip "no Neovim: it publishes no musl build (Alpine: apk add neovim)"; fi
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

# mason's PyPI packages (basedpyright, debugpy) need Python ≥ 3.10; RHEL 8/9 and SUSE
# Leap ship older. uv puts python3.13 in ~/.local/bin, where mason looks for it.
ensure_modern_python() {
  local py
  for py in python3 python3.14 python3.13 python3.12 python3.11 python3.10; do
    has "$py" && "$py" -c 'import sys; sys.exit(sys.version_info < (3, 10))' 2>/dev/null && return 0
  done
  has uv || { warn "no Python ≥ 3.10 and no uv: basedpyright/debugpy won't install"; return 0; }
  info "Python ≥ 3.10 for mason (uv python install 3.13)…"
  run uv python install 3.13 || warn "uv python install failed"
}

main() {
  section "Neovim plugins, parsers, language servers"
  check_prereqs
  use_repo_nvim_config
  local failed=0
  if wants lazy cli; then
    info "plugins (lazy-lock.json)…"
    run nvim --headless "+Lazy! restore" +qa || { warn "Lazy restore reported errors"; failed=1; }
  fi
  if wants bootstrap dev && [[ -f "$BOOTSTRAP_SCRIPT" || "$DRY_RUN" == 1 ]]; then
    ensure_modern_python
    # tree-sitter compiles parsers with $CC; GCC 12 (Debian 12) spends 30+ min on Swift's.
    local cc="${CC:-cc}"
    [[ -z "${CC:-}" ]] && has clang && cc=clang
    info "language servers + treesitter parsers (several minutes on first run)…"
    run env CC="$cc" nvim --headless -c "luafile $BOOTSTRAP_SCRIPT" || { warn "bootstrap reported errors"; failed=1; }
  fi
  [[ "$failed" == 0 ]] && ok "nvim ready"
  return "$failed"
}

main "$@"
