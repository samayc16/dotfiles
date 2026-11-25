#!/usr/bin/env bash
# tmux plugins: TPM and every plugin tmux.conf lists, cloned into ~/.tmux/plugins at the commits
# pinned in pins.txt, so TPM's first run finds them all instead of cloning whatever is newest.
# A plugin dir you've changed (edited files, or commits of your own) is left alone.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
# shellcheck source=pins.sh
source "$(dirname "$0")/pins.sh"

PLUGIN_DIR="$HOME/.tmux/plugins"

sync_plugin() {
  local name="$1" url="$2" rev="$3" status=0
  if [[ "$DRY_RUN" == 1 ]]; then
    info "would sync $name at ${rev:0:12}"
    return 0
  fi
  pin_sync "$url" "$PLUGIN_DIR/$name" "$rev" || status=$?
  case $status in
    0) ok "cloned  $name" ;;
    10) info "${C_DIM}have    $name${C_RESET}" ;;
    11) ok "updated $name" ;;
    12) warn "kept $name at your version: it has your changes" ;;
    *) err "could not sync $name ($url at ${rev:0:12})"; return 1 ;;
  esac
}

main() {
  section "tmux plugins"
  has git || skip "git not installed"
  [[ -r "$PINS_FILE" ]] || { err "missing $PINS_FILE"; return 1; }
  local pin url rev failed=0
  while read -r pin url rev; do
    sync_plugin "${pin#tmux/}" "$url" "$rev" || failed=1
  done < <(pins_with_prefix tmux/)
  [[ "$failed" == 0 ]] && ok "plugins in $PLUGIN_DIR"
  return "$failed"
}

main "$@"
