#!/usr/bin/env bash
# zsh itself, prompt/plugins, and making zsh the login shell — with no-root fallbacks.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
# shellcheck source=pins.sh
source "$(dirname "${BASH_SOURCE[0]}")/pins.sh"

PLUGIN_DIR="$HOME/.local/share/zsh-plugins"

# Linux: clone the prompt + plugins user-locally (macOS gets them from Homebrew).
sync_plugins() {
  [[ "$OS" == macos ]] && return 0
  run mkdir -p "$PLUGIN_DIR"
  git_sync https://github.com/romkatv/powerlevel10k.git "$PLUGIN_DIR/powerlevel10k"
  git_sync https://github.com/zsh-users/zsh-autosuggestions.git "$PLUGIN_DIR/zsh-autosuggestions"
  git_sync https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR/zsh-syntax-highlighting"
  git_sync https://github.com/Aloxaf/fzf-tab.git "$PLUGIN_DIR/fzf-tab"
  ok "zsh plugins in $PLUGIN_DIR"
}

# Linux: tools from mise don't install zsh completions, so generate them (Homebrew
# ships its own on macOS).
generate_completions() {
  [[ "$OS" == macos ]] && return 0
  local dir="$HOME/.local/share/zsh/site-functions" spec name
  run mkdir -p "$dir"
  for spec in "rg --generate complete-zsh" "fd --gen-completions zsh" "bat --completion zsh" \
    "delta --generate-completion zsh" "gh completion -s zsh" "mise completion zsh" \
    "uv generate-shell-completion zsh" "tree-sitter complete --shell zsh" \
    "atuin gen-completions --shell zsh" "sesh completion zsh"; do
    name="${spec%% *}"
    has "$name" || continue
    if [[ "$DRY_RUN" == 1 ]]; then info "would generate _$name"; continue; fi
    # shellcheck disable=SC2086 # spec is a command line
    $spec >"$dir/_$name" 2>/dev/null || rm -f "$dir/_$name"
  done
  # yazi ships its completions instead of printing them
  local yazi
  if [[ "$DRY_RUN" != 1 ]] && yazi="$(mise where github:sxyazi/yazi 2>/dev/null)"; then
    cp "$yazi"/completions/_yazi "$yazi"/completions/_ya "$dir/" 2>/dev/null || true
  fi
  ok "zsh completions in $dir"
}

# atuin starts with the zsh history typed before it: imported once, the first time this step finds
# atuin (a marker remembers). From then on atuin records each command itself; importing again would
# be harmless anyway, since atuin skips entries it already has. No history file: nothing to import.
import_history() {
  local marker="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/atuin-imported" history="$HOME/.zsh_history" out
  has atuin || return 0
  if [[ -e "$marker" ]]; then
    info "${C_DIM}atuin: history imported earlier${C_RESET}"
    return 0
  fi
  if [[ "$DRY_RUN" == 1 ]]; then
    info "would import $history into atuin (once)"
    return 0
  fi
  if [[ -s "$history" ]]; then
    # quiet unless it fails: atuin prints a banner
    if ! out="$(SHELL="$(command -v zsh)" HISTFILE="$history" atuin import auto 2>&1)"; then
      printf '%s\n' "$out" | tail -n 5 >&2
      warn "atuin could not import $history; run \`atuin import auto\` in zsh to retry"
      return 0
    fi
    ok "atuin: imported $history ($(wc -l <"$history" | tr -d ' ') lines)"
  else
    info "atuin: no zsh history to import yet"
  fi
  mkdir -p "$(dirname "$marker")" && : >"$marker"
}

# No zsh and no root: romkatv/zsh-bin, a static zsh that runs on any Linux. Its install script,
# pinned to a commit in pins.txt, checks the archive's sha256 before unpacking into ~/.local.
install_zsh_bin() {
  local url rev script status=0
  read -r url rev < <(pin_lookup zsh-bin) || { err "zsh-bin is not in pins.txt"; return 1; }
  if [[ "$DRY_RUN" == 1 ]]; then info "would install zsh-bin (static zsh) into $LOCAL_PREFIX"; return 0; fi
  script="$(mktemp)"
  { fetch "https://raw.githubusercontent.com/${url#https://github.com/}/$rev/install" "$script" &&
    retry 3 run sh "$script" -q -d "$LOCAL_PREFIX" -e no -a sha256 </dev/null; } || status=$?
  rm -f "$script"
  if [[ "$status" != 0 ]]; then
    warn "zsh-bin install failed — staying on bash (aliases in zshrc won't load)"
    return 1
  fi
  ok "zsh (static, zsh-bin) → $LOCAL_PREFIX/bin/zsh"
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
  current="$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7 || dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}' || true)"
  [[ "$(basename "${current:-$SHELL}")" == zsh ]] && { ok "login shell is zsh"; return 0; }
  if detect_sudo; then
    # shellcheck disable=SC2086
    grep -qx "$zsh_path" /etc/shells || echo "$zsh_path" | run $SUDO tee -a /etc/shells >/dev/null
    # shellcheck disable=SC2086
    has chsh && run $SUDO chsh -s "$zsh_path" "$(id -un)" && { ok "login shell → $zsh_path"; return 0; }
  elif [[ -t 0 ]] && has chsh && grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
    run chsh -s "$zsh_path" && { ok "login shell → $zsh_path"; return 0; }
  fi
  bash_handoff "$zsh_path"
}

main() {
  section "zsh"
  export PATH="$LOCAL_PREFIX/bin:$PATH"
  if ! has zsh; then install_zsh_bin || exit 1; fi
  if ! has zsh; then
    [[ "$DRY_RUN" == 1 ]] && return 0
    err "zsh still not found after installing zsh-bin"
    exit 1
  fi
  sync_plugins
  generate_completions
  import_history
  make_login_shell
}

# Sourced (by the tests), only the functions are defined.
[[ "${BASH_SOURCE[0]}" != "$0" ]] || main "$@"
