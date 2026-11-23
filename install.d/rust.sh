#!/usr/bin/env bash
# Rust via rustup: the stable toolchain plus rust-analyzer, clippy, rustfmt and rust-src
# (go-to-definition into std). rust-analyzer comes from rustup, not mason, so it always
# matches the compiler.
#   macOS → Homebrew's rustup (keg-only: /opt/homebrew/opt/rustup/bin, on PATH via zshrc)
#   Linux → the official rustup-init binary, checksum-verified; user-local in ~/.cargo, ~/.rustup
set -euo pipefail
source "$(dirname "$0")/lib.sh"

COMPONENTS=(rust-analyzer clippy rustfmt rust-src)

linux_triple() {
  local arch libc=gnu
  case "$(uname -m)" in
    x86_64 | amd64) arch=x86_64 ;;
    aarch64 | arm64) arch=aarch64 ;;
    *) return 1 ;;
  esac
  if ldd --version 2>&1 | grep -qi musl; then libc=musl; fi
  echo "$arch-unknown-linux-$libc"
}

sha256_of() {
  if has sha256sum; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

install_rustup_linux() {
  local triple dir url
  triple="$(linux_triple)" || { err "no rustup build for $(uname -m)"; return 1; }
  dir="$(mktemp -d)"
  url="https://static.rust-lang.org/rustup/dist/$triple/rustup-init"
  fetch "$url" "$dir/rustup-init"
  fetch "$url.sha256" "$dir/rustup-init.sha256"
  if [[ "$DRY_RUN" != 1 && "$(sha256_of "$dir/rustup-init")" != "$(cut -d' ' -f1 "$dir/rustup-init.sha256")" ]]; then
    err "rustup-init checksum mismatch; not running it"
    rm -rf "$dir"
    return 1
  fi
  run chmod +x "$dir/rustup-init"
  run "$dir/rustup-init" -y --no-modify-path --profile minimal --default-toolchain none
  rm -rf "$dir"
}

main() {
  section "Rust"
  if [[ "$OS" == macos ]]; then
    brew list --formula rustup >/dev/null 2>&1 || run brew install rustup
    PATH="$(brew --prefix)/opt/rustup/bin:$PATH"
  else
    export PATH="$HOME/.cargo/bin:$PATH"
    has rustup || install_rustup_linux
  fi
  if [[ "$DRY_RUN" == 1 ]]; then
    run rustup toolchain install stable --profile minimal --component "$(IFS=,; echo "${COMPONENTS[*]}")"
    return 0
  fi
  has rustup || { err "rustup isn't on PATH"; return 1; }

  # Keep a toolchain the user picked (nightly, a pinned version); otherwise default to stable.
  run rustup toolchain install stable --profile minimal --component "$(IFS=,; echo "${COMPONENTS[*]}")"
  rustup default >/dev/null 2>&1 || run rustup default stable
  run rustup component add "${COMPONENTS[@]}"
  ok "$(rustc --version) · $(rust-analyzer --version 2>/dev/null | cut -d' ' -f1-2)"
}

main "$@"
