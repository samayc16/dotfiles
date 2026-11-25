#!/usr/bin/env bash
# Neovim first run, headless:
#   lazy      plugins pinned by nvim/lazy-lock.json                         (every profile)
#   bootstrap language servers, formatters, debug adapters (mason) and all
#             treesitter parsers, synchronously — nvim/scripts/bootstrap.lua (dev, full)
# Skip either with --without lazy / --without bootstrap.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/pins.sh"
source "$(dirname "$0")/libc.sh"

NVIM_MIN_VERSION="0.12.0"
BOOTSTRAP_SCRIPT="$DOTFILES/nvim/scripts/bootstrap.lua"
LSP_CONFIG="$HOME/.config/mise/conf.d/lsp-old-glibc.toml"

# Mason's basedpyright, clangd and clang-format don't run on glibc older than 2.28 (CentOS 7):
# basedpyright's npm build runs on the Node the installer set up, and conda-forge's clang-tools
# (clangd, clang-format) needs glibc 2.17. Neovim leaves those three to PATH there (util/tools.lua).
old_glibc_lsps() {
  local pyright clang node
  if ! wants_old_glibc_lsps; then
    if [[ -f "$LSP_CONFIG" ]]; then run rm -f "$LSP_CONFIG"; fi
    return 0
  fi
  read -r _ pyright < <(pin_lookup mise/basedpyright-old-glibc) || { err "mise/basedpyright-old-glibc is not in pins.txt"; return 1; }
  read -r _ clang < <(pin_lookup mise/clang-tools-old-glibc) || { err "mise/clang-tools-old-glibc is not in pins.txt"; return 1; }
  info "glibc $(glibc_version) is older than the $LSP_GLIBC_FLOOR Mason's Python and C servers need: basedpyright $pyright from npm, clangd + clang-format $clang from conda-forge"
  [[ "$DRY_RUN" == 1 ]] && return 0
  mkdir -p "$(dirname "$LSP_CONFIG")"
  cat >"$LSP_CONFIG" <<EOF
# Written by the dotfiles installer: glibc $(glibc_version) is older than $LSP_GLIBC_FLOOR (pins.txt: mise/*-old-glibc)
[tools]
"npm:basedpyright" = "$pyright"
"conda:clang-tools" = "$clang"
EOF
  # npm runs from Node's own directory: under this one-file config, mise's node shim has no version
  node="$(mise which node 2>/dev/null || true)"
  retry 3 run env ${node:+PATH="$(dirname "$node"):$PATH"} MISE_GLOBAL_CONFIG_FILE="$LSP_CONFIG" mise install --yes ||
    { warn "the Python / C language servers for old glibc failed to install (see above)"; return 1; }
  run mise reshim
}

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
    old_glibc_lsps || failed=1
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
