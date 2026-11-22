# dotfiles

A portable terminal development environment for macOS and Linux: a Neovim IDE for Python, C/C++, Swift, SystemVerilog and Haskell, tmux, zsh, kitty and Claude Code, plus offline trainers for getting better at all of it. Monokai Pro everywhere.

## Install

```sh
git clone https://github.com/samayc16/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

One command on macOS, Arch, Debian/Ubuntu, Fedora/RHEL or openSUSE, including SSH boxes without root. It installs everything, then smoke-tests every language in Neovim.

| profile | for |
|---|---|
| `./install.sh` (full) | your own machine: everything below |
| `./install.sh --profile dev` | no games or learning tracks |
| `./install.sh --profile cli` | minimal servers: shell, tmux, Neovim, CLI tools |

`./install.sh --list-steps` shows the plan; `--only <step>` re-runs one. Per-OS details, flags and no-root behaviour: [docs/install.md](docs/install.md).

## What you get

| area | highlights | guide |
|---|---|---|
| **Neovim** | LSP, completion, snippets, formatting, run (`Space rr`), debug and tests for 8 languages; Xcode build/run; SystemVerilog hierarchy + Verilator; Claude panel | [docs/neovim.md](docs/neovim.md) |
| **Learning** | `learn`: koans and Exercism exercises with tests, stars and XP · `:Dojo`: vim golf for motions and these keymaps · offline docs | [docs/learning.md](docs/learning.md) |
| **Games** | `play`: vim trainers, GameShell, a grep murder mystery, DOOM in Neovim, Zork, roguelikes | [docs/games.md](docs/games.md) |
| **Terminal** | zsh + Powerlevel10k, tmux with popups and a clean status bar, kitty, fzf/zoxide/eza/bat, lazygit + delta | [CHEATSHEET.md](CHEATSHEET.md) |
| **Claude Code** | Remote Control in every session, Claude inside Neovim (`Space ac`), a Tutor style for learning, `quiz` and `learn-coach` skills | [below](#claude-code) |

Every keybinding is in [CHEATSHEET.md](CHEATSHEET.md). In tmux press `prefix ?`; in Neovim press `Space` and wait.

## First steps

1. Open a new kitty window (font) and run `tmux`.
2. `nvim .` → `-` to browse, `Space sf` to find a file, `Space rr` to run it.
3. `learn` → pick a track → `Space lc` checks your answer.
4. `:Dojo` for five minutes of vim practice.
5. `Space ac` to ask Claude about the code you're looking at.

## Claude Code

`claude/` is linked into `~/.claude/`.

- **Work vs learning:** task requests just get done; "how do I / teach me / why" gets taught. Inside `~/learn` the Tutor style is on: you answer first, hints come in levels, you write the key lines.
- **In Neovim:** `Space ac` opens Claude beside your code with your selection as context; edits arrive as diffs (`Space aa` accept, `Space ad` deny). `claude` in another tmux pane can attach with `/ide`.
- **Skills:** say "quiz me" for keymap / tmux / sed quizzes; ask for help on a `learn` exercise and get hints without spoilers.
- **Plugins:** language-server plugins for C/C++, Swift, Python and Lua (`claude/install-plugins.sh`, safe to re-run).

Tracked: `settings.json`, `CLAUDE.md`, `output-styles/`, `skills/`, `rules/`, `agents/`, the status line and hooks. Credentials and `settings.local.json` are never tracked.

## Layout

```
install.sh · install.py · installer/ · install.d/   one installer, one script per step
nvim/        → ~/.config/nvim   lua/config, lua/plugins, lua/plugins/lang, scripts/{bootstrap,smoke}.lua
learn/       learn CLI tracks, roadmap, reading quests     games/  offline games installer
zshrc · zsh/ · tmux.conf · scripts/ · kitty/ · gitconfig · git/ · lazygit/ · clangd/ · mise/
bin/         → ~/bin (learn, play, copy)                    claude/ → ~/.claude    codex/ → ~/.codex
docs/        guides                                         .github/workflows/  installer CI
```

## Privacy

This repo is public and holds no secrets or personal details. Git identity lives in `~/.gitconfig.local` and machine-specific settings in `~/.zshrc.local`; neither is tracked.
