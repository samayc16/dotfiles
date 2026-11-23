#!/usr/bin/env bash
# Claude Code marketplaces + plugins. Idempotent; needs network, not a login.
set -euo pipefail

marketplaces=(
  anthropics/claude-plugins-official
  affaan-m/everything-claude-code
  nextlevelbuilder/ui-ux-pro-max-skill
)

# LSP plugins give Claude go-to-definition and diagnostics; each needs its server on PATH.
plugins=(
  clangd-lsp@claude-plugins-official  # clangd
  swift-lsp@claude-plugins-official   # sourcekit-lsp
  pyright-lsp@claude-plugins-official # pyright-langserver
  lua-lsp@claude-plugins-official     # lua-language-server
  rust-analyzer-lsp@claude-plugins-official # rust-analyzer
  ecc@ecc
  ui-ux-pro-max@ui-ux-pro-max-skill
)

command -v claude >/dev/null || { echo "claude is not installed" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

known="$(claude plugin marketplace list --json 2>/dev/null | jq -r '.[].repo // empty')"
for repo in "${marketplaces[@]}"; do
  if grep -qx "$repo" <<<"$known"; then
    echo "  marketplace $repo"
  else
    claude plugin marketplace add "$repo"
  fi
done

installed="$(claude plugin list --json 2>/dev/null | jq -r '.[].id')"
for plugin in "${plugins[@]}"; do
  if grep -qx "$plugin" <<<"$installed"; then
    echo "  plugin $plugin"
  else
    claude plugin install "$plugin" --scope user
  fi
done

echo "Plugins ready. Restart Claude Code to load new ones."
