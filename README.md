# dotfiles

Personal dotfiles for macOS and Arch Linux (WSL). Monokai Pro everywhere.

See [CHEATSHEET.md](./CHEATSHEET.md) for every alias, keybinding and command wired up here.

## What's included

- **zsh** - Powerlevel10k (Monokai truecolor), fzf, zoxide, autosuggestions, syntax highlighting, Monokai `LS_COLORS`/`EZA_COLORS`, OSC52 copy-command-line, `~/.zshrc.local` for untracked secrets
- **neovim** - kickstart.nvim + Monokai Pro, vim-tmux-navigator, bufferline, undotree, render-markdown, claudecode.nvim
- **tmux** - Monokai Pro status bar with weather + prefix/copy/sync indicator, vim-tmux-navigator, resurrect/continuum, tmux-fzf, `prefix + ?` help popup, sessionist
- **kitty** - Monokai Pro colors, MesloLGS Nerd Font, OSC52 clipboard for SSH
- **lazygit** - Monokai Pro theme, delta pager
- **git** - Delta side-by-side diffs, aliases, rebase-on-pull, `gh` credential helper, global ignore
- **bin/** - `copy` / `copy_cmd` (OSC52 clipboard over SSH/tmux), terminal color tests
- **claude code** - Settings, Monokai status line, project-skills SessionStart hook, rules (19 files), agents (34 files), plugin manifest
- **codex** - Agentic defaults + native status line
- **htop** - Linux-only layout (`install-arch.sh`)

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

### Re-link only

Already have the packages? Pass `--link-only` to either installer to skip installs and just (re)create symlinks. Existing files are moved to `<file>.bak`.

## Layout

```
dotfiles/
├── install.sh / install-arch.sh   # installers (mac / arch)
├── zshrc / zshrc-arch             # platform zsh (PATH, plugins, tool init)
├── zsh/common.zsh                 # shared zsh (keys, colors, helpers) — sourced by both
├── zsh/p10k.zsh                   # prompt
├── tmux.conf + scripts/           # tmux + help popup + weather
├── nvim/                          # kickstart + lua/custom/plugins/
├── kitty/  lazygit/  gitconfig  git/ignore
├── bin/                           # → ~/bin
├── claude/                        # → ~/.claude (settings, statusline, hook, rules, agents)
├── codex/                         # → ~/.codex/config.toml
└── htop/                          # → ~/.config/htop (Linux only)
```

## Claude Code

Config is symlinked from `claude/` to `~/.claude/`. After install:

1. Run `claude` to authenticate
2. Run `~/dotfiles/claude/install-plugins.sh` to install plugins

**Tracked:** `settings.json`, `statusline-command.sh`, `load-project-skills.sh`, `rules/`, `agents/`, `known_marketplaces.json`
**Excluded:** credentials, `settings.local.json`, plugin cache, project-specific config

## Secrets

Nothing tracked here should contain keys. Machine-specific exports go in `~/.zshrc.local`, which `zsh/common.zsh` sources if present.
