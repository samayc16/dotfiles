#!/usr/bin/env bash
# Linux: user-local dev tools via mise (neovim, ripgrep, fd, fzf, atuin, …) — no root.
# Set GITHUB_TOKEN to avoid GitHub API rate limits on shared IPs.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
# shellcheck source=pins.sh
source "$(dirname "$0")/pins.sh"

[[ "$OS" == macos ]] && skip "macOS gets these tools from Homebrew"

MISE_BIN="$LOCAL_PREFIX/bin/mise"
export PATH="$LOCAL_PREFIX/bin:$HOME/.local/share/mise/shims:$PATH"
# Upstream publishes these for glibc only (mise/global.toml lists why); musl systems skip them.
GLIBC_ONLY="github:neovim/neovim,conda:tree-sitter-cli"
MUSL_CONFIG="$HOME/.config/mise/conf.d/musl.toml"
NODE_MUSL_MIRROR="https://unofficial-builds.nodejs.org/download/release/"

ensure_mise() {
  if has mise; then
    ok "mise $(mise --version 2>/dev/null | awk '{print $1}')"
    return 0
  fi
  local script url version
  read -r url version < <(pin_lookup mise) || { err "mise is not in pins.txt"; return 1; }
  info "Installing mise $version (static musl build, checksum-verified) → $MISE_BIN"
  script="$(mktemp)"
  fetch https://mise.run "$script"
  run env MISE_INSTALL_PATH="$MISE_BIN" MISE_VERSION="$version" MISE_INSTALL_MUSL=1 sh "$script"
  rm -f "$script"
}

# On musl, keep mise (and every shell's `mise activate`) away from the glibc-only tools, and take
# Node's musl build from the Node.js project's unofficial-builds (checked against its SHASUMS256).
musl_setup() {
  if ! is_musl; then
    [[ -f "$MUSL_CONFIG" ]] && run rm -f "$MUSL_CONFIG"
    return 0
  fi
  export MISE_DISABLE_TOOLS="$GLIBC_ONLY" MISE_NODE_FLAVOR=musl MISE_NODE_MIRROR_URL="$NODE_MUSL_MIRROR" MISE_NODE_COMPILE=false
  warn "musl libc: Neovim and tree-sitter publish no musl build, so they're skipped." \
    "Install neovim ≥ 0.12 and tree-sitter yourself (Alpine: apk add neovim tree-sitter-cli)."
  [[ "$DRY_RUN" == 1 ]] && return 0
  mkdir -p "$(dirname "$MUSL_CONFIG")"
  {
    echo "# Written by the dotfiles installer for this musl system (see mise/global.toml)"
    echo "[settings]"
    printf 'disable_tools = ["%s"]\n' "${GLIBC_ONLY//,/\", \"}"
    printf 'node.flavor = "musl"\nnode.mirror_url = "%s"\nnode.compile = false\n' "$NODE_MUSL_MIRROR"
  } >"$MUSL_CONFIG"
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
  musl_setup
  # Use the repo manifest directly so this works even before links.sh has run.
  # Keep going if a single tool fails; only the core tools below are required.
  retry 3 run env MISE_GLOBAL_CONFIG_FILE="$DOTFILES/mise/global.toml" mise install --yes || warn "some mise tools failed (see above)"
  [[ "$DRY_RUN" == 1 ]] && return 0
  run env MISE_GLOBAL_CONFIG_FILE="$DOTFILES/mise/global.toml" mise reshim
  local tool missing=0
  for tool in nvim rg fd fzf bat eza delta lazygit zoxide tree-sitter tmux jq atuin sesh yazi btop direnv; do
    if has "$tool"; then
      ok "$tool"
    elif is_musl && [[ "$tool" == nvim || "$tool" == tree-sitter ]]; then
      info "${C_DIM}$tool: skipped on musl${C_RESET}"
    else
      err "$tool missing after mise install"
      missing=1
    fi
  done
  check_node
  return "$missing"
}

main "$@"
