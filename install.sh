#!/bin/bash
set -e

echo "Installing dotfiles..."

# ── Homebrew ──────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── Packages ──────────────────────────────────────────────────────────
echo "Installing packages..."
brew install neovim zoxide zsh-autosuggestions zsh-syntax-highlighting \
  powerlevel10k fzf ripgrep fd bat eza git-delta lazygit gh \
  tldr jq htop trash mise tmux

# ── Font ──────────────────────────────────────────────────────────────
echo "Installing MesloLGS Nerd Font..."
brew install --cask font-meslo-lg-nerd-font raycast 2>/dev/null || true

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
link "$DOTFILES/zshrc"          "$HOME/.zshrc"
link "$DOTFILES/gitconfig"      "$HOME/.gitconfig"
link "$DOTFILES/tmux.conf"      "$HOME/.tmux.conf"

mkdir -p "$HOME/.config/kitty"
link "$DOTFILES/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

mkdir -p "$HOME/.config/nvim"
link "$DOTFILES/nvim/init.lua"  "$HOME/.config/nvim/init.lua"
# Link the lua directory (kickstart plugins, custom plugins)
if [ -d "$DOTFILES/nvim/lua" ]; then
  link "$DOTFILES/nvim/lua" "$HOME/.config/nvim/lua"
fi

echo ""
echo "Done! Next steps:"
echo "  1. Restart your terminal"
echo "  2. Run 'p10k configure' to set up your prompt"
echo "  3. Open nvim to let lazy.nvim install plugins"
