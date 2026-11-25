#!/usr/bin/env bash
# Linux: base/system packages from the distro package manager (needs root or sudo).
# Fast-moving dev tools (neovim, ripgrep, …) come from mise instead — see mise.sh.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

[[ "$OS" == macos ]] && skip "macOS uses Homebrew (brew.sh)"
detect_sudo || skip "no root/sudo — system packages skipped; user-local tools only (mise)"

# Base packages per distro family; dev adds compilers/simulators used by the nvim setup.
base_packages() {
  case "$OS" in
    arch) echo base-devel git curl unzip tar xz zsh tmux python which file ;;
    debian) echo build-essential git curl ca-certificates unzip tar xz-utils zsh tmux python3 python3-venv file ;;
    rhel) echo git curl unzip tar xz make gcc gcc-c++ zsh tmux python3 which file findutils util-linux-user libatomic ;;
    suse) echo git curl unzip tar xz make gcc gcc-c++ zsh tmux python3 which file libatomic1 ;;
    alpine) echo bash git curl ca-certificates unzip tar xz build-base zsh tmux python3 file ncurses ;;
  esac
}
dev_packages() {
  # autoconf/flex/bison: Verilator source build when the distro package is unusable
  local common="clang cmake verilator iverilog z3 trash-cli htop autoconf flex bison"
  case "$OS" in
    debian) echo "$common libclang-rt-dev" ;; # clang's sanitizer runtimes
    arch | rhel | suse | alpine) echo "$common" ;;
  esac
}

# Already installed? Same-named command first (handles curl-minimal & friends),
# then the package database.
installed() {
  local pkg="$1"
  has "$pkg" && return 0
  case "$OS" in
    arch) pacman -Q "$pkg" >/dev/null 2>&1 ;;
    debian) dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed' ;;
    rhel | suse) rpm -q "$pkg" >/dev/null 2>&1 ;;
    alpine) apk info -e "$pkg" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}

pm_install() {
  # shellcheck disable=SC2086  # $SUDO and the package list are split on purpose
  case "$OS" in
    arch) run $SUDO pacman -Syu --needed --noconfirm "$@" ;;
    debian) run $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@" ;;
    rhel) run $SUDO dnf install -y "$@" ;;
    suse) run $SUDO zypper --non-interactive install --no-recommends "$@" ;;
    alpine) run $SUDO apk add --no-cache "$@" ;;
  esac
}

refresh_index() {
  # shellcheck disable=SC2086
  case "$OS" in
    debian) run $SUDO apt-get update -qq ;;
    alpine) run $SUDO apk update -q ;;
    rhel)
      # EPEL carries verilator/iverilog on RHEL clones (Fedora has them already)
      # shellcheck source=/dev/null
      if [[ "$(. /etc/os-release && echo "$ID")" != fedora ]]; then
        run $SUDO dnf install -y epel-release || warn "EPEL unavailable (verilator/iverilog may be missing)"
      fi
      ;;
  esac
  return 0
}

install_list() {
  local todo=() pkg failed=()
  for pkg in "$@"; do installed "$pkg" || todo+=("$pkg"); done
  if [[ ${#todo[@]} -eq 0 ]]; then
    ok "all present: $*"
    return 0
  fi
  info "installing: ${todo[*]}"
  pm_install "${todo[@]}" && return 0
  warn "batch install failed — retrying one by one"
  for pkg in "${todo[@]}"; do pm_install "$pkg" || failed+=("$pkg"); done
  [[ ${#failed[@]} -eq 0 ]] || warn "not available here: ${failed[*]}"
}

main() {
  case "$OS" in arch | debian | rhel | suse | alpine) ;; *) skip "unknown distro ($OS) — install git, curl, zsh, tmux, make, gcc yourself" ;; esac
  section "System packages ($OS, $PROFILE)"
  refresh_index
  # shellcheck disable=SC2046
  install_list $(base_packages)
  # shellcheck disable=SC2046
  if wants devtools dev; then install_list $(dev_packages); fi
}

main "$@"
