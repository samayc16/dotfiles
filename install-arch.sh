#!/bin/bash
# Usage: ./install-arch.sh [--link-only]
#   --link-only  skip pacman/package installs, just (re)create symlinks
set -e

LINK_ONLY=false
[[ "${1:-}" == "--link-only" ]] && LINK_ONLY=true

echo "Installing dotfiles for Arch Linux..."

if ! $LINK_ONLY; then

# ── Packages ──────────────────────────────────────────────────────────
echo "Installing packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm \
  neovim zoxide zsh zsh-autosuggestions zsh-syntax-highlighting \
  fzf ripgrep fd bat eza git-delta lazygit \
  tmux htop jq openssh base-devel git git-lfs unzip curl wget

# ── Mise (runtime version manager) ───────────────────────────────────
if ! command -v mise &>/dev/null; then
  echo "Installing mise..."
  curl https://mise.run | sh
fi

# ── Claude Code ───────────────────────────────────────────────────────
if ! command -v claude &>/dev/null; then
  echo "Installing Claude Code..."
  # Install Node via mise if not present
  if ! command -v node &>/dev/null; then
    ~/.local/bin/mise use -g node@lts
    eval "$(~/.local/bin/mise activate bash)"
  fi
  npm install -g @anthropic-ai/claude-code
fi

# ── Powerlevel10k ─────────────────────────────────────────────────────
P10K_DIR="${HOME}/.local/share/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# ── Change shell to zsh ──────────────────────────────────────────────
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Changing default shell to zsh..."
  chsh -s "$(which zsh)"
fi

fi # !LINK_ONLY

# ── Symlinks ──────────────────────────────────────────────────────────
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "  Backing up existing $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sf "$src" "$dst"
  echo "  Linked $src -> $dst"
}

echo "Creating symlinks..."
link "$DOTFILES/zshrc-arch"     "$HOME/.zshrc"
link "$DOTFILES/zsh/p10k.zsh"   "$HOME/.p10k.zsh"
link "$DOTFILES/gitconfig"      "$HOME/.gitconfig"
link "$DOTFILES/tmux.conf"      "$HOME/.tmux.conf"

mkdir -p "$HOME/.config/git"
link "$DOTFILES/git/ignore"     "$HOME/.config/git/ignore"

# Linux-only: htop layout (meter names differ on macOS)
mkdir -p "$HOME/.config/htop"
link "$DOTFILES/htop/htoprc"    "$HOME/.config/htop/htoprc"

# Personal scripts → ~/bin (on PATH via zsh/common.zsh)
mkdir -p "$HOME/bin"
for script in "$DOTFILES"/bin/*; do
  link "$script" "$HOME/bin/$(basename "$script")"
done

mkdir -p "$HOME/.codex"
link "$DOTFILES/codex/config.toml" "$HOME/.codex/config.toml"

mkdir -p "$HOME/.config/lazygit"
link "$DOTFILES/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"

mkdir -p "$HOME/.config/nvim"
link "$DOTFILES/nvim/init.lua"  "$HOME/.config/nvim/init.lua"
if [ -d "$DOTFILES/nvim/lua" ]; then
  link "$DOTFILES/nvim/lua" "$HOME/.config/nvim/lua"
fi

# ── Claude Code config ──────────────────────────────────────────────
echo "Linking Claude Code config..."
mkdir -p "$HOME/.claude" "$HOME/.claude/plugins"
link "$DOTFILES/claude/settings.json"           "$HOME/.claude/settings.json"
link "$DOTFILES/claude/rules"                    "$HOME/.claude/rules"
link "$DOTFILES/claude/agents"                   "$HOME/.claude/agents"
link "$DOTFILES/claude/known_marketplaces.json"  "$HOME/.claude/plugins/known_marketplaces.json"
link "$DOTFILES/claude/statusline-command.sh"    "$HOME/.claude/statusline-command.sh"
link "$DOTFILES/claude/load-project-skills.sh"   "$HOME/.claude/load-project-skills.sh"

echo ""
echo "Done! Next steps:"
echo "  1. Log out and back in (or run 'zsh')"
echo "  2. Put machine-specific secrets/paths in ~/.zshrc.local (untracked)"
echo "  3. Open nvim to let lazy.nvim install plugins"
echo "  4. In tmux, plugins auto-install on first launch"
echo "  5. Run 'claude' and authenticate, then run ~/dotfiles/claude/install-plugins.sh"
