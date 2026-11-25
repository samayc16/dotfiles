#!/usr/bin/env bash
# plexamp-tui (https://github.com/samayc16/plexamp-tui), command `tamp`: a Plex music player for the terminal, installed with
# `uv tool`, plus mpv to play music locally. Without mpv tamp still works as a remote and
# synced-lyrics screen for Plexamp on another device.
#
# Which plexamp-tui: the wheel a release tarball bundles in dist/, else the release pinned in
# pins.txt (its wheel, or the tag from git if that wheel is missing); `tamp update` moves it on
# later. An editable dev install (uv tool install -e) is never replaced.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
# shellcheck source=pins.sh
source "$(dirname "$0")/pins.sh"

TAMP_PACKAGE="plexamp-tui"
TAMP_RECEIPT="${UV_TOOL_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/uv/tools}/$TAMP_PACKAGE/uv-receipt.toml"

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
    alpine) run $SUDO apk add --no-cache mpv ;;
    rhel)
      # Fedora ships mpv; RHEL/Rocky only have it in RPM Fusion, which we don't enable for you.
      run $SUDO dnf install -y -q mpv || warn "mpv isn't in your repos (RPM Fusion has it); tamp will control other players only"
      ;;
    *) warn "don't know how to install mpv here" ;;
  esac
}

# Prints what to install from, best first: the bundled wheel, the pinned release's wheel, its tag.
tamp_sources() {
  local wheel url tag
  for wheel in "$DOTFILES"/dist/plexamp_tui-*.whl; do
    if [[ -f "$wheel" ]]; then echo "$wheel"; fi
  done
  read -r url tag < <(pin_lookup "$TAMP_PACKAGE") || { err "$TAMP_PACKAGE is not in pins.txt"; return 1; }
  if [[ "$tag" == - ]]; then
    warn "no numbered $TAMP_PACKAGE release pinned yet: installing its main branch"
    echo "git+$url"
    return 0
  fi
  echo "$url/releases/download/$tag/plexamp_tui-${tag#v}-py3-none-any.whl"
  echo "git+$url@$tag"
}

install_tamp() {
  local source
  while read -r source; do
    run uv tool install --upgrade --quiet "$source" </dev/null && return 0
    warn "could not install from $source"
  done < <(tamp_sources)
  return 1
}

main() {
  section "Music (tamp)"
  if ! has uv; then
    [[ "$DRY_RUN" == 1 ]] || { err "uv is required (installed by the packages / mise steps)"; return 1; }
    warn "uv not installed yet (the packages / mise steps install it)"
  fi
  install_mpv
  if grep -q '^[^#]*editable =' "$TAMP_RECEIPT" 2>/dev/null; then
    ok "$TAMP_PACKAGE: your editable dev install, left alone"
    return 0
  fi
  # it was published as "tamp" before; that tool owns the `tamp` command, so it has to go first
  if has uv && uv tool list 2>/dev/null | grep -q "^tamp v"; then run uv tool uninstall tamp; fi
  install_tamp || { err "could not install $TAMP_PACKAGE"; return 1; }
  [[ "$DRY_RUN" == 1 ]] || ok "$(tamp --version 2>/dev/null || echo "tamp installed")"
}

main "$@"
