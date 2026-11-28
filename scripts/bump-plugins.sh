#!/usr/bin/env bash
# Move every Neovim plugin in nvim/lazy-lock.json to its newest version, as `:Lazy update` does
# (a spec's `version = '1.*'` keeps it in that range; disabled and platform-only plugins keep
# their entries), without touching your own Neovim: lazy.nvim runs headless on this checkout's
# config with throwaway data, state and cache directories.
#
#   scripts/bump-plugins.sh [--changes FILE]   rewrite nvim/lazy-lock.json, print what moved
#
# Needs nvim and git. The nightly CI run calls it after scripts/bump-pins.py, so mason's build
# step already reads the bumped mason-registry pin. Bash 3.2 compatible.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOCK="$ROOT/nvim/lazy-lock.json"
changes=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --changes) changes="${2:?--changes needs a file}"; shift 2 ;;
    *) echo "usage: $0 [--changes FILE]" >&2; exit 2 ;;
  esac
done
command -v nvim >/dev/null || { echo "bump-plugins: nvim not found" >&2; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/config"
ln -s "$ROOT/nvim" "$tmp/config/nvim"
cp "$LOCK" "$tmp/old-lock.json"
# CLAUDE_CONFIG_DIR: claudecode.nvim writes its IDE lock file there while nvim runs.
XDG_CONFIG_HOME="$tmp/config" XDG_DATA_HOME="$tmp/data" XDG_STATE_HOME="$tmp/state" \
  XDG_CACHE_HOME="$tmp/cache" CLAUDE_CONFIG_DIR="$tmp/claude" \
  nvim --headless "+Lazy! update" +qa

report="$(python3 "$ROOT/scripts/bump-pins.py" lock-diff "$tmp/old-lock.json" "$LOCK")"
if [[ -n "$changes" ]]; then
  if [[ -n "$report" ]]; then printf '%s\n' "$report" >"$changes"; else : >"$changes"; fi
fi
echo "${report:-every plugin is already the newest}"
