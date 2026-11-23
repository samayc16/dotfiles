#!/usr/bin/env bash
# Verilator 5 from source into ~/.local. Run by hdl.sh when there's no usable distro
# package (disable with --without hdl-src). Slow: ~10-20 min.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

REPO=https://github.com/verilator/verilator.git
SRC="$HOME/.local/src/verilator"

main() {
  section "Verilator (source build)"
  export PATH="$LOCAL_PREFIX/bin:$PATH"
  if [[ "$OS" == macos ]]; then skip "macOS uses Homebrew's verilator"; fi
  local missing=() tool
  for tool in g++ make autoconf flex bison perl python3; do has "$tool" || missing+=("$tool"); done
  if [[ ${#missing[@]} -gt 0 ]]; then
    err "missing build tools: ${missing[*]}"
    exit 1
  fi
  local tag
  tag="$(git ls-remote --tags --refs "$REPO" 'v5.*' | awk -F/ '{print $NF}' | sort -V | tail -n1)"
  info "building $tag → $LOCAL_PREFIX"
  run rm -rf "$SRC"
  run git clone --depth 1 --branch "$tag" --quiet "$REPO" "$SRC"
  (
    cd "$SRC"
    run autoconf
    run ./configure --prefix="$LOCAL_PREFIX"
    # Skip the man pages: they need help2man, which minimal boxes lack (`verilator --help` works).
    run make -j"$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)" VL_INST_MAN_FILES=
    run make install VL_INST_MAN_FILES=
  )
  ok "verilator $tag installed"
}

main "$@"
