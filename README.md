# dotfiles

Personal dotfiles for macOS and Arch Linux (WSL).

## What's included

- **zsh** - Powerlevel10k, fzf, zoxide, autosuggestions, syntax highlighting
- **neovim** - kickstart.nvim with Monokai Pro theme, vim-tmux-navigator
- **tmux** - Monokai Pro status bar, vim-tmux-navigator, resurrect/continuum
- **kitty** - Monokai Pro colors, MesloLGS Nerd Font
- **lazygit** - Monokai Pro theme, delta pager
- **git** - Delta side-by-side diffs, useful aliases

## Install

### macOS

```sh
git clone https://github.com/samayc16/dotfiles.git ~/dotfiles
cd ~/dotfiles && chmod +x install.sh && ./install.sh
```

### Arch Linux (WSL)

```sh
git clone https://github.com/samayc16/dotfiles.git ~/dotfiles
cd ~/dotfiles && chmod +x install-arch.sh && ./install-arch.sh
```

## Key bindings

### tmux (prefix: ctrl-a)

| Keys | Action |
|------|--------|
| `ctrl-hjkl` | Navigate panes (vim-aware) |
| `alt-h/l` | Previous/next window |
| `alt-j/k` | Previous/next session |
| `alt-[1-0]` | Select window 1-10 |
| `prefix \|` | Split horizontal |
| `prefix -` | Split vertical |
| `prefix [` | Vi copy mode |
| `prefix r` | Reload config |
| `prefix I` | Install plugins |

### zsh

| Keys | Action |
|------|--------|
| `shift-tab` | Accept autosuggestion |
| `alt-arrows` | Move by word |
| `ctrl-r` | Fuzzy history search |
| `ctrl-t` | Fuzzy file finder |
| `alt-c` | Fuzzy cd |
