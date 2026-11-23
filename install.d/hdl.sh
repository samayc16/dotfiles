#!/usr/bin/env bash
# HDL toolchain on Linux: Verilator ≥ 5 and Icarus Verilog (simulate), Surfer (waveforms).
# macOS gets all three from Homebrew (brew.sh). Each simulator comes from the first source
# that works:
#   distro package (system.sh, root) → conda-forge build via mise (prebuilt, user-local,
#   glibc ≥ 2.17; recorded in ~/.config/mise/conf.d/hdl.toml) → source build into ~/.local.
# Source builds only matter where conda-forge has no build (Icarus on ARM); they are slow
# (Verilator ~10-20 min) and can be disabled with --without hdl-src.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

SURFER_URL="https://gitlab.com/api/v4/projects/42073614/packages/generic/surfer/v0.7.0/surfer_linux_v0.7.0.zip"
VERILATOR_MIN=5.0
MISE_HDL_CONFIG="$HOME/.config/mise/conf.d/hdl.toml"
# shellcheck disable=SC2016  # Verilog, not shell
TEST_DESIGN='module t; initial begin $display("ok"); $finish; end endmodule'

# works <cmd…>: run in a scratch dir holding t.sv. A simulator only counts if it handles a
# real design: some packages are broken (EPEL 9's Verilator lacks verilated_std.sv).
works() {
  local dir status=0
  dir="$(mktemp -d)"
  printf '%s\n' "$TEST_DESIGN" >"$dir/t.sv"
  (cd "$dir" && "$@") >/dev/null 2>&1 || status=1
  rm -rf "$dir"
  return "$status"
}

verilator_ok() {
  has verilator && version_ge "$(verilator --version | awk '{print $2}')" "$VERILATOR_MIN" &&
    works verilator --lint-only t.sv
}
iverilog_ok() { has iverilog && works sh -c 'iverilog -g2012 -o t.vvp t.sv && vvp t.vvp | grep -q ok'; }
verilator_version() { verilator --version | cut -d' ' -f2; }
iverilog_version() { iverilog -V 2>&1 | head -n1 | cut -d' ' -f4; }

# conda_tool <package>: prebuilt build from conda-forge, user-local via mise.
conda_tool() {
  has mise || return 1
  info "$1 from conda-forge (mise)…"
  run mise use --path "$MISE_HDL_CONFIG" "conda:$1@latest" >/dev/null || return 1
  run mise reshim
  hash -r
}

ensure_verilator() {
  if verilator_ok; then ok "verilator $(verilator_version)"; return 0; fi
  if conda_tool verilator && verilator_ok; then ok "verilator $(verilator_version) (conda-forge)"; return 0; fi
  wants hdl-src cli || { warn "no working verilator ≥ $VERILATOR_MIN and source builds disabled"; return 1; }
  run bash "$DOTFILES/install.d/verilator.sh" && hash -r && verilator_ok
}

ensure_iverilog() {
  if iverilog_ok; then ok "iverilog $(iverilog_version)"; return 0; fi
  if conda_tool iverilog && iverilog_ok; then ok "iverilog $(iverilog_version) (conda-forge)"; return 0; fi
  wants hdl-src cli || { warn "no working iverilog and source builds disabled"; return 1; }
  local src="$HOME/.local/src/iverilog" tool
  for tool in g++ make autoconf gperf flex bison; do has "$tool" || { warn "can't build iverilog: missing $tool"; return 1; }; done
  info "building Icarus Verilog → $LOCAL_PREFIX"
  run rm -rf "$src"
  run git clone --depth 1 --quiet https://github.com/steveicarus/iverilog.git "$src"
  (cd "$src" && run sh autoconf.sh && run ./configure --prefix="$LOCAL_PREFIX" && run make -j4 && run make install)
  hash -r && iverilog_ok
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
