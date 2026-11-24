#!/bin/bash
# Offline games & trainers — run once while online, play anywhere.
#
# Usage: games/install.sh [--help]
#
# Installs, in order of usefulness:
#   Train: terminal  grep / sed / awk / CLI exercise TUIs (learnbyexample), GameShell,
#                    Command Line Murder Mystery, bashcrawl
#   Play             roguelikes + arcade classics (brew / pacman), sedtris, awkaster, Zork I-III
# Neovim games live in nvim/lua/plugins/games.lua and install with the rest of the
# plugins (`nvim --headless "+Lazy! install" +qa`). Launch anything with `play`.
#
# Everything non-packaged goes in $GAMES_DIR (default ~/games). Re-running is safe:
# existing games (and your save files / progress) are left alone.
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
fi

GAMES_DIR="${GAMES_DIR:-$HOME/games}"
BIN_DIR="$GAMES_DIR/bin"
OS="$(uname -s)"

GAMESHELL_VERSION="v0.6.0"
FROTZ_VERSION="2.55"
# All five learnbyexample apps pin textual==0.85.2, so they share one venv.
PY_TRAINERS=(grepexercises sedexercises awkexercises cliexercises awktutorial)

# Terminal games. Heavy ones (cataclysm, brogue, bastet, nudoku, brew frotz) are left
# out on purpose: SDL / boost / cairo / audio stacks cost hundreds of MB.
BREW_GAMES=(nethack angband vitetris nsnake ninvaders moon-buggy tty-solitaire c2048 myman curseofwar sl)
# GNU grep/sed/awk/coreutils so the exercises behave like Linux; tree/pstree/nano for GameShell.
BREW_TOOLS=(gawk grep gnu-sed coreutils tree pstree nano)
# Arch: official repos only (no AUR helper assumed).
PACMAN_PKGS=(nethack angband tty-solitaire sl frotz-ncurses gawk python tree psmisc nano gettext git make gcc)

say() { printf '\n\033[1;38;2;169;220;118m── %s\033[0m\n' "$*"; }
note() { printf '  %s\n' "$*"; }

# ── Packages ──────────────────────────────────────────────────────────
# brew refuses to run while another brew holds its lock; wait instead of failing.
brew_install() {
  local log attempt
  log="$(mktemp)"
  for attempt in $(seq 1 60); do
    if brew install "$@" 2>&1 | tee "$log"; then rm -f "$log"; return 0; fi
    if grep -q "has already locked" "$log"; then
      note "brew is busy (another install is running) — retrying in 15s ($attempt/60)"
      sleep 15
      continue
    fi
    rm -f "$log"
    return 1
  done
  rm -f "$log"
  echo "brew lock was never released" >&2
  return 1
}

install_packages_macos() {
  command -v brew >/dev/null || { echo "Homebrew is required (run ../install.sh first)" >&2; exit 1; }
  local missing=() f
  for f in "${BREW_GAMES[@]}" "${BREW_TOOLS[@]}"; do
    brew list --formula "$f" >/dev/null 2>&1 || missing+=("$f")
  done
  if ((${#missing[@]})); then
    brew_install "${missing[@]}"
  else
    note "all brew packages already installed"
  fi
}

install_packages_arch() {
  if [[ "${NO_SUDO:-0}" == 1 ]]; then
    note "--no-sudo: skipping pacman packages (${PACMAN_PKGS[*]})"
    return 0
  fi
  sudo -n pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}" || note "pacman needs sudo; skipped (${PACMAN_PKGS[*]})"
}

# ── Helpers ───────────────────────────────────────────────────────────
clone_once() {
  local url="$1" dest="$2"
  if [[ -d "$dest" ]]; then
    note "have $(basename "$dest") (left untouched — your progress lives there)"
  else
    git clone --quiet --depth 1 "$url" "$dest"
    note "cloned $(basename "$dest")"
  fi
}

fetch_once() {
  local url="$1" dest="$2"
  if [[ -s "$dest" ]]; then
    note "have $(basename "$dest")"
  else
    mkdir -p "$(dirname "$dest")"
    curl -fsSL --retry 3 -o "$dest.part" "$url"
    mv "$dest.part" "$dest"
    note "downloaded $(basename "$dest")"
  fi
}

# ── Text-processing & shell trainers ──────────────────────────────────
install_py_trainers() {
  local venv="$GAMES_DIR/venv" app
  [[ -x "$venv/bin/python" ]] || python3 -m venv "$venv"
  "$venv/bin/python" -m pip install --quiet --disable-pip-version-check "${PY_TRAINERS[@]}"
  for app in "${PY_TRAINERS[@]}"; do
    ln -sf "$venv/bin/$app" "$BIN_DIR/$app"
  done
  note "installed ${PY_TRAINERS[*]}"
}

install_shell_games() {
  clone_once https://github.com/veltman/clmystery.git "$GAMES_DIR/clmystery"
  clone_once https://gitlab.com/slackermedia/bashcrawl.git "$GAMES_DIR/bashcrawl"
  fetch_once "https://github.com/phyver/GameShell/releases/download/$GAMESHELL_VERSION/gameshell.sh" \
    "$GAMES_DIR/gameshell/gameshell.sh"
}

# ── Fun ───────────────────────────────────────────────────────────────
install_novelties() {
  clone_once https://github.com/uuner/sedtris.git "$GAMES_DIR/sedtris"
  clone_once https://github.com/TheMozg/awk-raycaster.git "$GAMES_DIR/awkaster"
}

# Zork I-III: Microsoft released the source + compiled story files under MIT (2025).
install_zork() {
  local n
  for n in 1 2 3; do
    fetch_once "https://raw.githubusercontent.com/historicalsource/zork$n/master/COMPILED/zork$n.z3" \
      "$GAMES_DIR/zork/zork$n.z3"
  done
  fetch_once https://raw.githubusercontent.com/historicalsource/zork1/master/LICENSE "$GAMES_DIR/zork/LICENSE"
}

# Homebrew's frotz drags in ~25 audio libraries; a sound-less curses build is ~1 MB.
build_frotz_macos() {
  if command -v frotz >/dev/null || [[ -x "$BIN_DIR/frotz" ]]; then
    note "have frotz"
    return
  fi
  local src="$GAMES_DIR/src/frotz-$FROTZ_VERSION"
  if [[ ! -d "$src" ]]; then
    mkdir -p "$GAMES_DIR/src"
    curl -fsSL --retry 3 "https://gitlab.com/DavidGriffith/frotz/-/archive/$FROTZ_VERSION/frotz-$FROTZ_VERSION.tar.gz" |
      tar -xz -C "$GAMES_DIR/src"
  fi
  make -s -C "$src" frotz SOUND_TYPE=none >/dev/null 2>&1
  cp "$src/frotz" "$BIN_DIR/frotz"
  rm -rf "$GAMES_DIR/src"
  note "built frotz $FROTZ_VERSION (curses, no sound)"
}

# ── Main ──────────────────────────────────────────────────────────────
mkdir -p "$GAMES_DIR" "$BIN_DIR"

say "Packages"
case "$OS" in
  Darwin) install_packages_macos ;;
  Linux)
    if command -v pacman >/dev/null; then install_packages_arch; else note "not Arch — skipping system packages"; fi
    ;;
esac

say "Trainers: grep / sed / awk / CLI exercises"
install_py_trainers

say "Trainers: shell games"
install_shell_games

say "Fun: sedtris, awkaster, Zork"
install_novelties
install_zork
if [[ "$OS" == Darwin ]]; then build_frotz_macos; fi

say "Done — run \`play\` to pick a game ($GAMES_DIR)"
