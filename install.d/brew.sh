#!/usr/bin/env bash
# macOS: everything from Homebrew. Only missing formulae/casks are installed.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

[[ "$OS" == macos ]] || skip "Homebrew step is macOS-only"

CLI_FORMULAE=(
  neovim tmux zsh-autosuggestions zsh-syntax-highlighting powerlevel10k fzf-tab
  fzf ripgrep fd bat eza zoxide git-delta lazygit gh jq tldr htop trash mise git-lfs
  tree-sitter-cli uv
)
DEV_FORMULAE=(
  node cmake gcc                          # gcc: GNU GCC as gcc-NN/g++-NN (plain gcc is Apple clang)
  verilator icarus-verilog surfer z3      # HDL: simulate, waveforms, z3 = Verilator constrained-random
  xcode-build-server xcbeautify           # Swift/Xcode from nvim (xcodebuild.nvim)
)
CASKS=(raycast) # the Nerd Font is handled by fonts.sh

ensure_brew() {
  if has brew; then return 0; fi
  [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)" && return 0
  info "Installing Homebrew…"
  run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  [[ "$DRY_RUN" == 1 ]] || eval "$(/opt/homebrew/bin/brew shellenv)"
}

# Run brew, waiting if another brew process holds the lock.
brew_retry() {
  local attempt out
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if out="$(run brew "$@" 2>&1)"; then
      [[ -n "$out" ]] && printf '%s\n' "$out" | tail -n 3
      return 0
    fi
    if [[ "$out" != *"has already locked"* ]]; then
      printf '%s\n' "$out" | tail -n 5 >&2
      return 1
    fi
    warn "brew is busy (attempt $attempt), waiting…"
    sleep 15
  done
  return 1
}

# Print the subset of $@ that is not installed yet (kind: --formula | --cask).
missing() {
  local kind="$1" installed item
  shift
  installed=" $(brew list "$kind" -1 2>/dev/null | tr '\n' ' ') "
  for item in "$@"; do
    # also present when the command exists under another formula (e.g. node@22 → node)
    [[ "$installed" == *" $item "* ]] || has "$item" || printf '%s\n' "$item"
  done
}

install_missing() {
  local kind="$1" todo
  shift
  todo="$(missing "$kind" "$@" | tr '\n' ' ')"
  if [[ -z "${todo// /}" ]]; then
    ok "all ${kind#--} packages present"
    return 0
  fi
  info "installing: $todo"
  # shellcheck disable=SC2086  # word-split the package list on purpose
  brew_retry install "$kind" $todo
}

main() {
  section "Homebrew packages ($PROFILE)"
  ensure_brew
  install_missing --formula "${CLI_FORMULAE[@]}"
  if wants devtools dev; then install_missing --formula "${DEV_FORMULAE[@]}"; fi
  install_missing --cask "${CASKS[@]}"
  if [[ ! -d /Applications/kitty.app ]]; then install_missing --cask kitty; fi
}

main "$@"
