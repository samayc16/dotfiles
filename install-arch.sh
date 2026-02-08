#!/bin/bash
set -e

echo "Installing dotfiles for Arch Linux..."

# ── Packages ──────────────────────────────────────────────────────────
echo "Installing packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm \
  neovim zoxide zsh zsh-autosuggestions zsh-syntax-highlighting \
  fzf ripgrep fd bat eza git-delta lazygit \
  tmux htop jq openssh base-devel git unzip curl wget

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
link "$DOTFILES/gitconfig"      "$HOME/.gitconfig"
link "$DOTFILES/tmux.conf"      "$HOME/.tmux.conf"

mkdir -p "$HOME/.config/nvim"
link "$DOTFILES/nvim/init.lua"  "$HOME/.config/nvim/init.lua"
if [ -d "$DOTFILES/nvim/lua" ]; then
  link "$DOTFILES/nvim/lua" "$HOME/.config/nvim/lua"
fi

echo ""
echo "Done! Next steps:"
echo "  1. Log out and back in (or run 'zsh')"
echo "  2. Run 'p10k configure' to set up your prompt"
echo "  3. Open nvim to let lazy.nvim install plugins"
echo "  4. In tmux, plugins auto-install on first launch"
