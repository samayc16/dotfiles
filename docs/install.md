# Install details

`./install.sh` is a small POSIX shim: it finds Python 3.8+ (or fetches one) and runs `install.py`, which runs the steps in `install.d/` and prints a summary. Every step is idempotent and fail-soft; a log lands in `~/.cache/dotfiles/`.

The last step opens a sample file per language (and per installed compiler or simulator) in headless Neovim and checks highlighting, the language server, diagnostics, completion and `Space rr`:

![./install.sh --only smoke -v: every language passes](img/install-smoke.png)

## Flags

```sh
./install.sh --list-steps            # what would run on this machine, and why not
./install.sh --profile cli           # minimal box: shell, tmux, nvim, CLI tools
./install.sh --no-sudo               # never touch root; everything user-local in ~/.local
./install.sh --only nvim,smoke       # re-run some steps
./install.sh --skip games,learn      # everything except
./install.sh --with haskell          # add a step beyond the profile
./install.sh --without hdl-src       # never build Verilator/Icarus from source (last resort)
./install.sh --link-only             # just (re)create symlinks; existing files move to <file>.bak
./install.sh --dry-run -v            # print every command instead of running it
```

| profile | adds |
|---|---|
| `cli` | font, zsh + prompt, tmux, Neovim + plugins, CLI tools, Claude Code |
| `dev` | language servers, formatters, debuggers, parsers, HDL toolchain, smoke test |
| `full` (default) | Swift (Linux), Haskell, games, learning tracks |

## Where tools come from

| platform | source |
|---|---|
| macOS | Homebrew for everything |
| Linux with root/sudo | distro packages for the basics (compilers, zsh, tmux, Python, Verilator, Icarus, z3) |
| Linux, always | [mise](https://mise.jdx.dev) installs fast-moving tools user-locally: Neovim ≥ 0.12, tree-sitter, ripgrep, fd, fzf, bat, eza, delta, lazygit, zoxide, jq, gh, tmux, Node, uv (`mise/global.toml`) |
| Linux without root | zsh plugins cloned to `~/.local/share/zsh-plugins`; zsh built from source if missing; Swift via swiftly; Haskell via ghcup |
| Linux simulators | Verilator and Icarus Verilog from the distro if they work, else prebuilt conda-forge builds via mise (user-local, any glibc ≥ 2.17, recorded in `~/.config/mise/conf.d/hdl.toml`), else a source build. Each must simulate a test design to count. |
| no Python 3.8+ (RHEL 8, minimal containers) | the shim installs one, or fetches a standalone build with uv |

Fonts: Meslo Nerd Font (Homebrew cask on macOS, Nerd Fonts release + `fc-cache` on Linux; skipped on headless boxes, since the font matters where the terminal runs).

On corporate networks set `GITHUB_TOKEN` to avoid API rate limits; `HTTPS_PROXY` is honoured.

## Per-machine files (never tracked)

| file | holds |
|---|---|
| `~/.gitconfig.local` | git identity (created as a template on first install) |
| `~/.zshrc.local` | secrets, work-specific paths and aliases |
| `~/.claude/settings.local.json` | machine-specific Claude Code overrides |

## CI

`.github/workflows/install.yml` installs on Ubuntu 24.04, Debian 12, Fedora, Rocky 9 and Arch, both as root (`--profile dev`, then the per-language smoke test) and as a user without sudo (`--profile cli --with hdl`), plus a macOS link-only run. Every job checks tool versions, symlinks, a clean zsh start, `Lazy! restore`, and a simulation in both Verilator and Icarus. Failed jobs upload Neovim's logs as an artifact.
