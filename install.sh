#!/bin/sh
# Dotfiles installer entry point (POSIX sh, so it runs before anything else exists).
#
# Finds Python ≥ 3.8 and hands over to install.py. Without one (minimal containers,
# RHEL 8's 3.6, …) it installs python3 with the package manager when root/sudo works,
# otherwise fetches a standalone Python with uv into ~/.local — no root needed.
#
#   ./install.sh --help        all options
#   ./install.sh               install everything (profile full)
set -eu

DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

usable() {
  command -v "$1" >/dev/null 2>&1 && "$1" -c 'import sys; sys.exit(sys.version_info < (3, 8))' 2>/dev/null
}

find_python() {
  for py in python3 python3.13 python3.12 python3.11 python3.10 python3.9 python3.8 python; do
    if usable "$py"; then command -v "$py"; return 0; fi
  done
  return 1
}

privileged() {
  case " $* " in *" --no-sudo "*) return 1 ;; esac
  [ "$(id -u)" = 0 ] && return 0
  command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null
}

as_root() { if [ "$(id -u)" = 0 ]; then "$@"; else sudo -n "$@"; fi; }

system_python() {
  if command -v apt-get >/dev/null 2>&1; then as_root apt-get update -qq && as_root apt-get install -y -qq python3
  elif command -v dnf >/dev/null 2>&1; then as_root dnf install -y -q python3
  elif command -v pacman >/dev/null 2>&1; then as_root pacman -Sy --needed --noconfirm python
  elif command -v zypper >/dev/null 2>&1; then as_root zypper --non-interactive install python3
  else return 1
  fi
}

uv_python() {
  PATH="$HOME/.local/bin:$PATH"
  export PATH
  if ! command -v uv >/dev/null 2>&1; then
    echo "Fetching uv (user-local) to get a standalone Python…" >&2
    if command -v curl >/dev/null 2>&1; then
      curl -LsSf https://astral.sh/uv/install.sh | UV_NO_MODIFY_PATH=1 sh >&2
    else
      wget -qO- https://astral.sh/uv/install.sh | UV_NO_MODIFY_PATH=1 sh >&2
    fi
  fi
  uv python find 3.12 2>/dev/null || { uv python install 3.12 >&2 && uv python find 3.12; }
}

PY=$(find_python) || PY=""
if [ -z "$PY" ] && privileged "$@"; then
  echo "No Python ≥ 3.8 — installing python3 with the system package manager…" >&2
  system_python >&2 && PY=$(find_python) || PY=""
fi
if [ -z "$PY" ]; then
  PY=$(uv_python) || { echo "Could not find or fetch Python ≥ 3.8 (need curl or wget)." >&2; exit 1; }
fi

exec "$PY" "$DIR/install.py" "$@"
