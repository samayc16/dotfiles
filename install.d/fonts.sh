#!/usr/bin/env bash
# Meslo Nerd Font (kitty uses "MesloLGM Nerd Font"). The font matters on the machine
# running the terminal; on a headless SSH box this step skips itself.
#   macOS → Homebrew cask    Linux → latest Nerd Fonts release into ~/.local/share/fonts
set -euo pipefail
source "$(dirname "$0")/lib.sh"

FONT_DIR="$HOME/.local/share/fonts/NerdFonts/Meslo"
RELEASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz"

install_mac() {
  if brew list --cask font-meslo-lg-nerd-font >/dev/null 2>&1; then
    ok "Meslo Nerd Font present"
    return 0
  fi
  run brew install --cask font-meslo-lg-nerd-font
}

install_linux() {
  has fc-cache || skip "no fontconfig (headless?) — install the font where your terminal runs"
  if compgen -G "$FONT_DIR/MesloLGMNerdFont-Regular.ttf" >/dev/null; then
    ok "Meslo Nerd Font present ($FONT_DIR)"
    return 0
  fi
  if ! has tar || ! has xz; then
    err "need tar + xz to unpack the font"
    return 1
  fi
  local archive
  archive="$(mktemp)"
  fetch "$RELEASE_URL" "$archive"
  run mkdir -p "$FONT_DIR"
  run tar -xJf "$archive" -C "$FONT_DIR"
  rm -f "$archive"
  run fc-cache -f "$FONT_DIR"
  ok "Meslo Nerd Font → $FONT_DIR"
}

main() {
  section "Fonts"
  if [[ "$OS" == macos ]]; then install_mac; else install_linux; fi
}

main "$@"
