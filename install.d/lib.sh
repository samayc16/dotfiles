#!/usr/bin/env bash
# Shared helpers for every install.d/<step>.sh. Sourced, never executed.
# install.py runs each step in its own bash process (installer/runner.py) and passes
# OS/PROFILE/WITH/WITHOUT/DRY_RUN/NO_SUDO in the environment; the defaults below make
# a step runnable on its own too:  bash install.d/fonts.sh
# Bash 3.2 compatible (macOS /bin/bash): no associative arrays, no empty "${a[@]}".

# Always the repo this file lives in (an exported DOTFILES from the shell could point elsewhere)
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# What the home links point through. A git clone is linked directly. A release install lives in
# <store>/<version>/ (bin/dotfiles) and is linked through <store>/current, so an update or a
# rollback is one atomic flip of that symlink.
release_link_root() {
  local version
  [[ -f "$DOTFILES/VERSION" && ! -e "$DOTFILES/.git" ]] || return 1
  read -r version <"$DOTFILES/VERSION" || return 1
  [[ "$(basename "$DOTFILES")" == "$version" ]] || return 1
  echo "$(dirname "$DOTFILES")/current"
}
LINK_ROOT="${DOTFILES_LINK_ROOT:-$(release_link_root || echo "$DOTFILES")}"
DRY_RUN="${DRY_RUN:-0}"
NO_SUDO="${NO_SUDO:-0}"
PROFILE="${PROFILE:-full}"
WITH="${WITH:-}"
WITHOUT="${WITHOUT:-}"
LOCAL_PREFIX="${LOCAL_PREFIX:-$HOME/.local}"
export PATH="$LOCAL_PREFIX/bin:$HOME/.local/share/mise/shims:$HOME/.cargo/bin:/opt/homebrew/opt/rustup/bin:$PATH" # tools from earlier steps
export DOTFILES LINK_ROOT DRY_RUN NO_SUDO PROFILE WITH WITHOUT LOCAL_PREFIX

# Exit code a step uses to say "nothing to do here" (shown as skipped, not failed)
SKIP=3

# ── Output ────────────────────────────────────────────────────────────
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  C_RESET=$'\033[0m' C_DIM=$'\033[2m' C_BOLD=$'\033[1m'
  C_GREEN=$'\033[38;2;169;220;118m' C_YELLOW=$'\033[38;2;255;216;102m'
  C_RED=$'\033[38;2;255;97;136m' C_CYAN=$'\033[38;2;120;220;232m'
else
  C_RESET='' C_DIM='' C_BOLD='' C_GREEN='' C_YELLOW='' C_RED='' C_CYAN=''
fi

section() { printf '\n%s── %s %s\n' "$C_CYAN$C_BOLD" "$*" "$C_RESET"; }
info() { printf '  %s\n' "$*"; }
ok() { printf '  %s✓%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '  %s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err() { printf '  %s✗%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
skip() { info "${C_DIM}skip: $*${C_RESET}"; exit "$SKIP"; }

# Run a command, or just print it under --dry-run.
run() {
  if [[ "$DRY_RUN" == 1 ]]; then
    printf '  %s$ %s%s\n' "$C_DIM" "$*" "$C_RESET"
    return 0
  fi
  "$@"
}

has() { command -v "$1" >/dev/null 2>&1; }

# Is a component enabled? Explicit --without wins, then --with, then the profile.
#   wants nvim          → on for every profile unless --without nvim
#   wants games full    → on for profile "full" or with --with games
wants() {
  local name="$1" min_profile="${2:-cli}"
  [[ ",$WITHOUT," == *",$name,"* ]] && return 1
  [[ ",$WITH," == *",$name,"* ]] && return 0
  case "$min_profile" in
    cli) return 0 ;;
    dev) [[ "$PROFILE" == dev || "$PROFILE" == full ]] ;;
    full) [[ "$PROFILE" == full ]] ;;
    never) return 1 ;;
  esac
}

# ── Platform ──────────────────────────────────────────────────────────
# Prints one of: macos arch debian rhel suse alpine linux unknown
detect_os() {
  case "$(uname -s)" in
    Darwin) echo macos && return ;;
    Linux) ;;
    *) echo unknown && return ;;
  esac
  [[ -r /etc/os-release ]] || { echo linux && return; }
  local id like word
  # shellcheck source=/dev/null
  id="$(. /etc/os-release && echo "${ID:-}")"
  # shellcheck source=/dev/null
  like="$(. /etc/os-release && echo "${ID_LIKE:-}")"
  for word in $id $like; do
    case "$word" in
      arch | manjaro | endeavouros | cachyos) echo arch && return ;;
      debian | ubuntu | linuxmint | pop) echo debian && return ;;
      fedora | rhel | centos | rocky | almalinux | ol | amzn) echo rhel && return ;;
      opensuse* | suse | sles) echo suse && return ;;
      alpine) echo alpine && return ;;
    esac
  done
  echo linux
}

OS="${OS:-$(detect_os)}"
export OS

is_wsl() { [[ -r /proc/version ]] && grep -qi microsoft /proc/version; }

# musl libc (Alpine): downloads built against glibc won't run here.
is_musl() {
  [[ "$OS" != macos ]] || return 1
  compgen -G "/lib/ld-musl-*.so.1" >/dev/null || ldd --version 2>&1 | grep -qi musl
}

# Sets SUDO to the prefix for privileged commands: "" as root, "sudo -n" when
# passwordless/cached sudo works. Returns 1 when neither (no system packages).
# Use it unquoted on purpose: `run $SUDO apt-get ...` (bash 3.2 safe).
# shellcheck disable=SC2034  # used by the step scripts
SUDO=""
detect_sudo() {
  if [[ "$NO_SUDO" == 1 ]]; then
    return 1
  elif [[ "$(id -u)" == 0 ]]; then
    SUDO=""
  elif has sudo && sudo -n true 2>/dev/null; then
    # shellcheck disable=SC2034  # used by the step scripts
    SUDO="sudo -n"
  else
    return 1
  fi
}

# Can we install system packages? (brew on macOS never needs sudo)
can_install_system() {
  [[ "$OS" == macos ]] && return 0
  detect_sudo
}

# ── Symlinks ──────────────────────────────────────────────────────────
# link SRC DST: symlink DST → SRC (through LINK_ROOT for a file in this repo). Already-correct
# links are left alone, and so is nothing else: a link into another version of a release install
# is ours and is replaced, anything else at DST is moved aside to DST.bak (DST.bak.<timestamp>
# if that exists).
link() {
  local src="$1" dst="$2" backup current
  [[ "$src" == "$DOTFILES"/* ]] && src="$LINK_ROOT/${src#"$DOTFILES"/}"
  current="$(readlink "$dst" 2>/dev/null || true)"
  if [[ "$current" == "$src" ]]; then
    info "${C_DIM}linked  $dst${C_RESET}"
    return 0
  fi
  run mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" && "$LINK_ROOT" != "$DOTFILES" && "$current" == "$(dirname "$LINK_ROOT")"/* ]]; then
    run rm "$dst"
  elif [[ -e "$dst" || -L "$dst" ]]; then
    backup="$dst.bak"
    [[ -e "$backup" || -L "$backup" ]] && backup="$dst.bak.$(date +%Y%m%d-%H%M%S)"
    warn "backing up $dst → $backup"
    run mv "$dst" "$backup"
  fi
  run ln -s "$src" "$dst"
  ok "linked  $dst → ${src#"$LINK_ROOT"/}"
}

# Copy a starting file into place once. Unlike link(), the copy is yours: apps that save their
# settings (Claude Code, Codex) write to it, and nothing they write comes back to this repo.
seed() {
  local src="$1" dst="$2"
  if [[ -L "$dst" && ("$(readlink "$dst")" == "$DOTFILES"/* || "$(readlink "$dst")" == "$LINK_ROOT"/*) ]]; then
    run rm "$dst" # an older install linked it into the repo: swap the link for a copy
  elif [[ -e "$dst" || -L "$dst" ]]; then
    info "${C_DIM}kept    $dst${C_RESET}"
    return 0
  fi
  run mkdir -p "$(dirname "$dst")"
  run cp "$src" "$dst"
  run chmod 600 "$dst"
  ok "copied  $dst ← ${src#"$DOTFILES"/}"
}

# Shallow-clone a repo, or fast-forward it if already present (offline-tolerant).
git_sync() {
  local url="$1" dir="$2"
  if [[ -d "$dir/.git" ]]; then
    run git -C "$dir" pull --ff-only --quiet || warn "could not update $dir (offline?)"
  else
    run git clone --depth 1 --quiet "$url" "$dir"
  fi
}

# Download URL to FILE with curl (or wget), following redirects.
fetch() {
  local url="$1" out="$2"
  if has curl; then
    run curl -fsSL --retry 3 -o "$out" "$url"
  elif has wget; then
    run wget -q -O "$out" "$url"
  else
    err "need curl or wget to download $url"
    return 1
  fi
}

# Steps that run nvim use this repo's config even while ~/.config/nvim points at another version
# (a release update runs the new version's installer before it flips `current`): exports an
# XDG_CONFIG_HOME that mirrors the real one with nvim/ swapped for this repo's.
use_repo_nvim_config() {
  local real="${XDG_CONFIG_HOME:-$HOME/.config}" shadow entry
  [[ "$(cd "$real/nvim" 2>/dev/null && pwd -P)" == "$(cd "$DOTFILES/nvim" && pwd -P)" ]] && return 0
  shadow="$(mktemp -d)"
  # shellcheck disable=SC2064 # expand now: the path is fixed
  trap "rm -rf '$shadow'" EXIT
  for entry in "$real"/*; do
    [[ -e "$entry" && "$(basename "$entry")" != nvim ]] && ln -s "$entry" "$shadow/"
  done
  ln -s "$DOTFILES/nvim" "$shadow/nvim"
  export XDG_CONFIG_HOME="$shadow"
}

# Compare dotted versions: version_ge 3.4 3.2 → true
version_ge() { [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" == "$2" ]]; }
