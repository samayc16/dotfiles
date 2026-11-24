#!/usr/bin/env bash
# plexamp-tui (https://github.com/samayc16/plexamp-tui), command `tamp`: a Plex music player for the terminal, installed with
# `uv tool`, plus mpv to play music locally. Without mpv tamp still works as a remote and
# synced-lyrics screen for Plexamp on another device.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

TAMP_SOURCE="git+https://github.com/samayc16/plexamp-tui"

install_mpv() {
  if has mpv; then
    ok "mpv present"
    return 0
  fi
  if ! can_install_system; then
    warn "no root: skipping mpv (tamp will control and follow other players only)"
    return 0
  fi
  case "$OS" in
    macos) run brew install mpv ;;
    debian) run $SUDO apt-get install -y -qq mpv ;;
    arch) run $SUDO pacman -S --needed --noconfirm mpv ;;
    suse) run $SUDO zypper --non-interactive install mpv ;;
    rhel)
      # Fedora ships mpv; RHEL/Rocky only have it in RPM Fusion, which we don't enable for you.
      run $SUDO dnf install -y -q mpv || warn "mpv isn't in your repos (RPM Fusion has it); tamp will control other players only"
      ;;
    *) warn "don't know how to install mpv here" ;;
  esac
}

main() {
  section "Music (tamp)"
  has uv || { err "uv is required (installed by the packages / mise steps)"; return 1; }
  install_mpv
  # it was published as "tamp" before; that tool owns the `tamp` command, so it has to go first
  if uv tool list 2>/dev/null | grep -q "^tamp v"; then run uv tool uninstall tamp; fi
  run uv tool install --upgrade --quiet "$TAMP_SOURCE"
  [[ "$DRY_RUN" == 1 ]] || ok "$(tamp --version 2>/dev/null || echo "tamp installed")"
}

main "$@"
