#!/bin/bash
set -e

# Install Claude Code plugins after authentication.
# Run this AFTER 'claude' has been authenticated on a fresh machine.

echo "Installing Claude Code plugins..."

# Official plugins
claude plugin install swift-lsp --marketplace claude-plugins-official
claude plugin install clangd-lsp --marketplace claude-plugins-official

# Community plugins
claude plugin install everything-claude-code --marketplace everything-claude-code
claude plugin install ui-ux-pro-max --marketplace ui-ux-pro-max-skill

echo ""
echo "Plugins installed. Restart Claude Code to activate."
