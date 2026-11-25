#!/usr/bin/env bash
# Linux: user-local dev tools via mise (neovim, ripgrep, fd, fzf, atuin, …) — no root.
# Set GITHUB_TOKEN to avoid GitHub API rate limits on shared IPs.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
# shellcheck source=pins.sh
source "$(dirname "$0")/pins.sh"
# shellcheck source=libc.sh
source "$(dirname "$0")/libc.sh"

[[ "$OS" == macos ]] && skip "macOS gets these tools from Homebrew"

MISE_BIN="$LOCAL_PREFIX/bin/mise"
export PATH="$LOCAL_PREFIX/bin:$HOME/.local/share/mise/shims:$PATH"
# Upstream publishes these for glibc only (mise/global.toml lists why); musl systems skip them.
GLIBC_ONLY="github:neovim/neovim,conda:tree-sitter-cli"
MUSL_CONFIG="$HOME/.config/mise/conf.d/musl.toml"
NODE_UNOFFICIAL_MIRROR="https://unofficial-builds.nodejs.org/download/release/"
NODE_CONFIG="$HOME/.config/mise/conf.d/node.toml"

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
  export MISE_DISABLE_TOOLS="$GLIBC_ONLY" MISE_NODE_FLAVOR=musl MISE_NODE_MIRROR_URL="$NODE_UNOFFICIAL_MIRROR" MISE_NODE_COMPILE=false
  warn "musl libc: Neovim and tree-sitter publish no musl build, so they're skipped." \
    "Install neovim ≥ 0.12 and tree-sitter yourself (Alpine: apk add neovim tree-sitter-cli)."
  [[ "$DRY_RUN" == 1 ]] && return 0
  mkdir -p "$(dirname "$MUSL_CONFIG")"
  {
    echo "# Written by the dotfiles installer for this musl system (see mise/global.toml)"
    echo "[settings]"
    printf 'disable_tools = ["%s"]\n' "${GLIBC_ONLY//,/\", \"}"
    printf 'node.flavor = "musl"\nnode.mirror_url = "%s"\nnode.compile = false\n' "$NODE_UNOFFICIAL_MIRROR"
  } >"$MUSL_CONFIG"
}

# glibc older than Neovim's floor (Ubuntu 20.04, RHEL/Rocky 8, …): use Neovim's own glibc 2.17
# build (neovim/neovim-releases, pinned as mise/neovim-old-glibc) in place of the usual one.
OLD_GLIBC_CONFIG="$HOME/.config/mise/conf.d/old-glibc.toml"
GIT_CONFIG="$HOME/.config/mise/conf.d/git.toml"

old_glibc_setup() {
  local glibc spec version
  if ! wants_old_glibc_nvim; then
    if [[ -f "$OLD_GLIBC_CONFIG" ]]; then run rm -f "$OLD_GLIBC_CONFIG"; fi
    return 0
  fi
  glibc="$(glibc_version)"
  read -r spec version < <(pin_lookup mise/neovim-old-glibc) || { err "mise/neovim-old-glibc is not in pins.txt"; return 1; }
  info "glibc $glibc is older than the $NVIM_GLIBC_FLOOR Neovim's usual build needs: using its glibc 2.17 build ($spec → $version)"
  export MISE_DISABLE_TOOLS="${MISE_DISABLE_TOOLS:+$MISE_DISABLE_TOOLS,}github:neovim/neovim"
  [[ "$DRY_RUN" == 1 ]] && return 0
  mkdir -p "$(dirname "$OLD_GLIBC_CONFIG")"
  cat >"$OLD_GLIBC_CONFIG" <<EOF
# Written by the dotfiles installer: glibc $glibc is older than $NVIM_GLIBC_FLOOR (pins.txt: mise/neovim-old-glibc)
[settings]
disable_tools = ["github:neovim/neovim"]

[tools]
"github:neovim/neovim-releases" = { version = "$version", os = ["linux"], platforms = { linux-x64 = { asset_pattern = "nvim-linux-x86_64.tar.gz" }, linux-arm64 = { asset_pattern = "nvim-linux-arm64.tar.gz" } } }
EOF
}

# A system git older than 2.19 (CentOS 7 ships 1.8.3), or none: lazy.nvim's partial clones and
# the later steps' `git -C` need newer, and only root could upgrade it. conda-forge's git runs on
# glibc ≥ 2.17 with its libraries alongside (pins.txt: mise/git-old-system); mise's shim then comes
# before /usr/bin/git on PATH, for the later steps and your shells.
git_setup() {
  local spec version have
  if git_ok; then
    if [[ -f "$GIT_CONFIG" ]]; then run rm -f "$GIT_CONFIG"; fi
    return 0
  fi
  read -r spec version < <(pin_lookup mise/git-old-system) || { err "mise/git-old-system is not in pins.txt"; return 1; }
  have="$(git_version)"
  local why="no git here"
  [[ -n "$have" ]] && why="git $have is older than $GIT_FLOOR"
  info "$why: installing git $version from conda-forge for you ($spec)"
  [[ "$DRY_RUN" == 1 ]] && return 0
  mkdir -p "$(dirname "$GIT_CONFIG")"
  cat >"$GIT_CONFIG" <<EOF
# Written by the dotfiles installer: the system git is older than $GIT_FLOOR (pins.txt: mise/git-old-system)
[tools]
"conda:git" = "$version"
EOF
}

# Mason's Python tools (basedpyright, debugpy, clang-format) need a python3 ≥ 3.9 that can make a
# venv. With none (not installed, too old, or Debian's without python3-venv) and no root to add
# one, uv installs a private CPython (python-build-standalone, checksum-verified) as python3.
PYTHON_SERIES=3.13

ensure_python() {
  if python_ok; then
    ok "python3 $(python3 -c 'import platform; print(platform.python_version())')"
    return 0
  fi
  if ! has uv; then
    warn "no python3 ≥ 3.9 with venv here, and no uv to add one: Python language servers are skipped"
    return 0
  fi
  info "no python3 ≥ 3.9 with venv here: installing Python $PYTHON_SERIES for you with uv → $LOCAL_PREFIX/bin/python3"
  retry 3 run env UV_PYTHON_BIN_DIR="$LOCAL_PREFIX/bin" uv python install --default "$PYTHON_SERIES" ||
    { warn "uv couldn't install Python: Python language servers are skipped"; return 0; }
  [[ "$DRY_RUN" == 1 ]] && return 0
  hash -r
  if python_ok; then ok "python3 $(python3 -c 'import platform; print(platform.python_version())') (uv)"; else warn "python3 from uv isn't usable"; fi
}

# Node's official Linux build needs libatomic.so.1 and glibc 2.28: minimal RHEL-family systems
# lack the first, older ones the second, and only root can add either. On x86-64 the Node.js
# project's glibc 2.17 build (unofficial-builds, checked against its SHASUMS256) has them built
# in, so it runs there; elsewhere keep the official build.
node_setup() {
  if ! wants_glibc217_node; then
    if [[ -f "$NODE_CONFIG" ]]; then run rm -f "$NODE_CONFIG"; fi
    return 0
  fi
  info "no libatomic.so.1 or glibc < $NODE_GLIBC_FLOOR here: Node comes from the Node.js project's glibc 2.17 build"
  export MISE_NODE_FLAVOR=glibc-217 MISE_NODE_MIRROR_URL="$NODE_UNOFFICIAL_MIRROR" MISE_NODE_COMPILE=false
  [[ "$DRY_RUN" == 1 ]] && return 0
  mkdir -p "$(dirname "$NODE_CONFIG")"
  {
    echo "# Written by the dotfiles installer: this system lacks libatomic.so.1 or glibc 2.28 (see install.d/mise.sh)"
    echo "[settings]"
    printf 'node.flavor = "glibc-217"\nnode.mirror_url = "%s"\nnode.compile = false\n' "$NODE_UNOFFICIAL_MIRROR"
  } >"$NODE_CONFIG"
}

check_node() {
  has node && node --version >/dev/null 2>&1 && { ok "node $(node --version)"; return 0; }
  if ! has_libatomic; then
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
  old_glibc_setup
  node_setup
  git_setup
  # Use the repo manifest directly so this works even before links.sh has run.
  # Keep going if a single tool fails; only the core tools below are required.
  retry 3 run env MISE_GLOBAL_CONFIG_FILE="$DOTFILES/mise/global.toml" mise install --yes || warn "some mise tools failed (see above)"
  if [[ -f "$OLD_GLIBC_CONFIG" ]]; then
    retry 3 run env MISE_GLOBAL_CONFIG_FILE="$OLD_GLIBC_CONFIG" mise install --yes || warn "Neovim's glibc 2.17 build failed to install (see above)"
  fi
  if [[ -f "$GIT_CONFIG" ]]; then
    retry 3 run env MISE_GLOBAL_CONFIG_FILE="$GIT_CONFIG" mise install --yes || warn "git from conda-forge failed to install (see above)"
  fi
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
  ensure_python
  if git_ok; then
    ok "git $(git_version)"
  else
    err "git $(git_version) is still older than $GIT_FLOOR: plugin installs will fail"
    missing=1
  fi
  return "$missing"
}

main "$@"
