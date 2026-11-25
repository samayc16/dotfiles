#!/usr/bin/env bash
# Symlink every config in the repo into place (same on every OS, paths differ).
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# Identity stays out of the public repo: gitconfig includes ~/.gitconfig.local.
local_git_identity() {
  local file="$HOME/.gitconfig.local"
  [[ -e "$file" ]] && return 0
  if [[ "$DRY_RUN" == 1 ]]; then info "would create $file"; return 0; fi
  printf '[user]\n\t# name = Your Name\n\t# email = you@users.noreply.github.com\n' >"$file"
  warn "set your git identity in $file"
}

link_shell() {
  section "Shell, git, atuin, tmux"
  link "$DOTFILES/zshrc" "$HOME/.zshrc"
  link "$DOTFILES/zsh/p10k.zsh" "$HOME/.p10k.zsh"
  link "$DOTFILES/gitconfig" "$HOME/.gitconfig"
  local_git_identity
  link "$DOTFILES/git/ignore" "$HOME/.config/git/ignore"
  # atuin reads ~/.atuin/config.toml first (~/.config/atuin is only a fallback for older installs)
  link "$DOTFILES/atuin/config.toml" "$HOME/.atuin/config.toml"
  link "$DOTFILES/tmux.conf" "$HOME/.tmux.conf"
  link "$DOTFILES/scripts" "$HOME/.tmux/scripts" # tmux.conf's popups, clipboard, weather
  local script
  for script in "$DOTFILES"/bin/*; do
    [[ -f "$script" ]] && link "$script" "$HOME/bin/$(basename "$script")"
  done
}

link_editors() {
  section "Neovim, clangd, mise, lazygit, kitty"
  link "$DOTFILES/nvim" "$HOME/.config/nvim"
  link "$DOTFILES/mise/global.toml" "$HOME/.config/mise/config.toml"
  link "$DOTFILES/kitty" "$HOME/.config/kitty" # whole dir: kitty resolves `include` next to the link
  if [[ "$OS" == macos ]]; then
    link "$DOTFILES/clangd/config.yaml" "$HOME/Library/Preferences/clangd/config.yaml"
    link "$DOTFILES/lazygit/config.yml" "$HOME/Library/Application Support/lazygit/config.yml"
  else
    link "$DOTFILES/clangd/config.yaml" "$HOME/.config/clangd/config.yaml"
    link "$DOTFILES/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
    link "$DOTFILES/htop/htoprc" "$HOME/.config/htop/htoprc" # meter names differ on macOS
  fi
}

link_agents() {
  section "Claude Code, Codex"
  # Copied, not linked: both apps write their settings back, and this repo is public.
  seed "$DOTFILES/codex/config.toml" "$HOME/.codex/config.toml"
  seed "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
  link "$DOTFILES/claude/rules" "$HOME/.claude/rules"
  link "$DOTFILES/claude/agents" "$HOME/.claude/agents"
  link "$DOTFILES/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
  link "$DOTFILES/claude/load-project-skills.sh" "$HOME/.claude/load-project-skills.sh"
  link "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  link "$DOTFILES/claude/output-styles" "$HOME/.claude/output-styles"
  # Skills one by one: ~/.claude/skills also holds Claude-managed dirs (synced/, learned/).
  local skill
  for skill in "$DOTFILES"/claude/skills/*/; do
    link "${skill%/}" "$HOME/.claude/skills/$(basename "$skill")"
  done
  # ~/learn sessions default to the Tutor output style.
  link "$DOTFILES/claude/learn/CLAUDE.md" "$HOME/learn/CLAUDE.md"
  link "$DOTFILES/claude/learn/settings.json" "$HOME/learn/.claude/settings.json"
}

main() {
  link_shell
  link_editors
  link_agents
}

main "$@"
