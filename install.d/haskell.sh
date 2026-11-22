#!/usr/bin/env bash
# Haskell (part of --profile full, or --with haskell). ~3 GB.
#   macOS → Homebrew (ghc, cabal, haskell-language-server, fourmolu, hlint)
#   Linux → ghcup, user-local in ~/.ghcup (ghc + cabal + matching HLS)
set -euo pipefail
source "$(dirname "$0")/lib.sh"

install_mac() {
  local formulae=(ghc cabal-install haskell-language-server fourmolu hlint) todo=() f
  for f in "${formulae[@]}"; do brew list --formula "$f" >/dev/null 2>&1 || todo+=("$f"); done
  if [[ ${#todo[@]} -eq 0 ]]; then
    ok "Haskell toolchain present"
    return 0
  fi
  run brew install "${todo[@]}"
}

install_linux() {
  if [[ -x "$HOME/.ghcup/bin/ghcup" ]]; then
    ok "ghcup present — upgrading recommended toolchain"
    run "$HOME/.ghcup/bin/ghcup" install ghc recommended --set
    run "$HOME/.ghcup/bin/ghcup" install hls recommended --set
    return 0
  fi
  local script
  script="$(mktemp)"
  fetch https://get-ghcup.haskell.org "$script"
  run env BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_INSTALL_HLS=1 \
    BOOTSTRAP_HASKELL_ADJUST_BASHRC=0 sh "$script"
  rm -f "$script"
  info "fourmolu/hlint aren't in ghcup: \`cabal install fourmolu hlint\` if you want them"
}

main() {
  section "Haskell"
  local free_kb
  free_kb="$(df -Pk "$HOME" | awk 'NR==2 {print $4}')"
  if [[ "${free_kb:-0}" -lt 5000000 ]]; then
    warn "less than ~5 GB free in \$HOME — Haskell needs ~3 GB"
  fi
  if [[ "$OS" == macos ]]; then install_mac; else install_linux; fi
}

main "$@"
