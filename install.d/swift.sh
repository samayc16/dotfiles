#!/usr/bin/env bash
# Swift on Linux via swiftly (user-local, ~/.local/share/swiftly). macOS uses Xcode.
# zshrc sources ~/.local/share/swiftly/env.sh when it exists.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

SWIFTLY_HOME="$HOME/.local/share/swiftly"

install_swiftly() {
  [[ -x "$SWIFTLY_HOME/bin/swiftly" ]] && return 0
  local work
  work="$(mktemp -d)"
  fetch "https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz" "$work/swiftly.tar.gz"
  run tar -xzf "$work/swiftly.tar.gz" -C "$work"
  # --no-modify-profile: ~/.zshrc is a symlink into this repo; zshrc sources env.sh itself
  run "$work/swiftly" init --no-modify-profile --assume-yes --quiet-shell-followup --skip-install
  rm -rf "$work"
}

# swiftly writes the system packages a toolchain needs (libcurl, libxml2, …) to a script.
run_post_install() {
  local post="$1"
  [[ -s "$post" ]] || return 0
  if detect_sudo; then
    # shellcheck disable=SC2086
    run $SUDO bash "$post"
  else
    warn "Swift needs system packages (no sudo here) — ask an admin to run:"
    sed 's/^/      /' "$post" >&2
  fi
}

main() {
  [[ "$OS" == macos ]] && skip "macOS uses the Swift toolchain from Xcode"
  section "Swift (swiftly)"
  install_swiftly
  [[ "$DRY_RUN" == 1 ]] && { info "would install the latest Swift toolchain"; return 0; }
  # shellcheck disable=SC1091
  source "$SWIFTLY_HOME/env.sh"
  local post
  post="$(mktemp)"
  run swiftly install latest --use --assume-yes --post-install-file="$post"
  run_post_install "$post"
  rm -f "$post"
  ok "$(swift --version 2>/dev/null | head -n1)"
}

main "$@"
