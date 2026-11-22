#!/usr/bin/env bash
# zsh itself, prompt/plugins, and making zsh the login shell — with no-root fallbacks.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

PLUGIN_DIR="$HOME/.local/share/zsh-plugins"
ZSH_SRC_URL="https://sourceforge.net/projects/zsh/files/zsh/5.9/zsh-5.9.tar.xz/download"

# Linux: clone the prompt + plugins user-locally (macOS gets them from Homebrew).
sync_plugins() {
  [[ "$OS" == macos ]] && return 0
  run mkdir -p "$PLUGIN_DIR"
  git_sync https://github.com/romkatv/powerlevel10k.git "$PLUGIN_DIR/powerlevel10k"
  git_sync https://github.com/zsh-users/zsh-autosuggestions.git "$PLUGIN_DIR/zsh-autosuggestions"
  git_sync https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR/zsh-syntax-highlighting"
  ok "zsh plugins in $PLUGIN_DIR"
}

# No zsh and no root: build it into ~/.local (needs a C compiler + ncurses headers).
build_zsh() {
  if ! has cc || ! has make; then
    warn "no compiler: can't build zsh — staying on bash (aliases in zshrc won't load)"
    return 1
  fi
  [[ "$DRY_RUN" == 1 ]] && { info "would build zsh 5.9 from source into $LOCAL_PREFIX"; return 0; }
  local work
  work="$(mktemp -d)"
  info "building zsh 5.9 into $LOCAL_PREFIX (a minute or two)…"
  fetch "$ZSH_SRC_URL" "$work/zsh.tar.xz"
  run tar -xJf "$work/zsh.tar.xz" -C "$work"
  (cd "$work/zsh-5.9" && run ./configure --prefix="$LOCAL_PREFIX" --enable-multibyte >/dev/null && run make -j4 >/dev/null && run make install >/dev/null) \
    || { warn "zsh build failed (missing ncurses headers?) — staying on bash"; return 1; }
  rm -rf "$work"
  ok "zsh → $LOCAL_PREFIX/bin/zsh"
}

# A login shell that isn't in /etc/shells can't be chsh'ed to without root, so as a
# last resort bash execs zsh for interactive sessions.
bash_handoff() {
  local zsh_path="$1" marker='# >>> dotfiles: start zsh >>>' file
  for file in "$HOME/.bash_profile" "$HOME/.bashrc"; do
    grep -qF "$marker" "$file" 2>/dev/null && continue
    [[ "$DRY_RUN" == 1 ]] && { info "would append zsh hand-off to $file"; continue; }
    # shellcheck disable=SC2016  # \${ZSH_VERSION} must stay literal in the rc file
    printf '\n%s\n[ -t 1 ] && [ -z "${ZSH_VERSION:-}" ] && [ -x %s ] && exec %s -l\n# <<< dotfiles: start zsh <<<\n' \
      "$marker" "$zsh_path" "$zsh_path" >>"$file"
  done
  ok "bash will hand interactive sessions to $zsh_path"
}

make_login_shell() {
  local zsh_path current
  zsh_path="$(command -v zsh)"
  current="$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7 || dscl . -read "$HOME" UserShell 2>/dev/null | awk '{print $2}')"
  [[ "$(basename "${current:-$SHELL}")" == zsh ]] && { ok "login shell is zsh"; return 0; }
  if detect_sudo; then
    # shellcheck disable=SC2086
    grep -qx "$zsh_path" /etc/shells || echo "$zsh_path" | run $SUDO tee -a /etc/shells >/dev/null
    # shellcheck disable=SC2086
    run $SUDO chsh -s "$zsh_path" "$(id -un)" && { ok "login shell → $zsh_path"; return 0; }
  elif [[ -t 0 ]] && grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
    run chsh -s "$zsh_path" && { ok "login shell → $zsh_path"; return 0; }
  fi
  bash_handoff "$zsh_path"
}

main() {
  section "zsh"
  export PATH="$LOCAL_PREFIX/bin:$PATH"
  if ! has zsh; then build_zsh || exit 1; fi
  if ! has zsh; then
    [[ "$DRY_RUN" == 1 ]] && return 0
    err "zsh still not found after building"
    exit 1
  fi
  sync_plugins
  make_login_shell
}

main "$@"
