#!/usr/bin/env bash
# HDL toolchain on Linux: Verilator ≥ 5 (simulate), Icarus Verilog, Surfer (waveforms).
# macOS gets all three from Homebrew (brew.sh). Order of preference on Linux:
#   distro package (system.sh, needs sudo) → source build into ~/.local → skip.
# Source builds take a while: Verilator ~10-20 min, Icarus ~3 min.
# Disable them with --without hdl-src.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

SURFER_URL="https://gitlab.com/api/v4/projects/42073614/packages/generic/surfer/v0.7.0/surfer_linux_v0.7.0.zip"
VERILATOR_MIN=5.0

verilator_ok() {
  has verilator || return 1
  version_ge "$(verilator --version | awk '{print $2}')" "$VERILATOR_MIN"
}

ensure_verilator() {
  if verilator_ok; then ok "verilator $(verilator --version | awk '{print $2}')"; return 0; fi
  wants hdl-src cli || { warn "verilator ≥ $VERILATOR_MIN missing and source builds disabled"; return 1; }
  run bash "$DOTFILES/install.d/verilator.sh"
}

ensure_iverilog() {
  if has iverilog; then ok "iverilog $(iverilog -V 2>&1 | head -n1 | awk '{print $4}')"; return 0; fi
  wants hdl-src cli || { warn "iverilog missing and source builds disabled"; return 1; }
  local src="$HOME/.local/src/iverilog" tool
  for tool in g++ make autoconf gperf flex bison; do has "$tool" || { warn "can't build iverilog: missing $tool"; return 1; }; done
  info "building Icarus Verilog → $LOCAL_PREFIX"
  run rm -rf "$src"
  run git clone --depth 1 --quiet https://github.com/steveicarus/iverilog.git "$src"
  (cd "$src" && run sh autoconf.sh && run ./configure --prefix="$LOCAL_PREFIX" && run make -j4 && run make install)
}

ensure_surfer() {
  if has surfer; then ok "surfer present"; return 0; fi
  has unzip || { warn "need unzip for surfer"; return 1; }
  local zip dir
  zip="$(mktemp)" dir="$(mktemp -d)"
  fetch "$SURFER_URL" "$zip"
  run unzip -q -o "$zip" -d "$dir"
  run mkdir -p "$LOCAL_PREFIX/bin"
  run install -m 0755 "$dir/surfer" "$LOCAL_PREFIX/bin/surfer"
  rm -rf "$zip" "$dir"
  ok "surfer → $LOCAL_PREFIX/bin (GUI: needs a display or X forwarding)"
}

main() {
  [[ "$OS" == macos ]] && skip "macOS gets Verilator/Icarus/Surfer from Homebrew"
  section "HDL toolchain"
  export PATH="$LOCAL_PREFIX/bin:$PATH"
  local failed=0
  ensure_verilator || failed=1
  ensure_iverilog || failed=1
  ensure_surfer || failed=1
  return "$failed"
}

main "$@"
