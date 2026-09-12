# cheatsheet

Everything wired up by this repo, grouped by tool. Inside tmux, `prefix + ?` shows the live popup version.

## shell (zsh)

### navigation
| keys | does |
|---|---|
| `z <partial>` / `zi` | zoxide jump to most-frecent matching dir / interactive picker |
| `1` … `5` | `cd ..`, `cd ../..`, … up N levels |
| `mkcd <dir>` | mkdir + cd |
| `Ctrl-T` | fzf **file picker** — insert path at cursor |
| `Ctrl-R` | fzf **history search** |
| `Alt-C` | fzf **cd** into a subdirectory |
| `Alt-Y` | copy current command line to clipboard via OSC52 (no execute; works over SSH/tmux) |
| `Shift-Tab` | accept autosuggestion |
| `Alt-←/→` or `Shift-←/→` | word back / forward (stops at `/` and `.`) |
| `Alt-Backspace` / `Alt-Delete` / `Shift-Backspace` | delete previous word |
| `Home` / `End` / `Delete` | work in every mode (normal, app, legacy sequences) |
| ` cmd` (leading space) | run without saving to history |

### listing (eza)
| cmd | does |
|---|---|
| `ls` | icons, dirs first |
| `ll` | long listing |
| `lrt` | long listing, newest last |
| `lt` | tree, 2 levels |

### aliases & functions
| cmd | does |
|---|---|
| `cat` | `bat --paging=never` |
| `vim` / `vi` | `nvim` |
| `lg` | lazygit |
| `rm` | `trash` (macOS) / `trash-put` (Linux) |
| `img <file>` | show image inline (kitty icat) |
| `c` | clear |
| `mux` | attach or create tmux session `main` |

### scripts (`bin/` → `~/bin`)
| cmd | does |
|---|---|
| `cmd \| copy` | stream output to terminal **and** copy it to clipboard (OSC52, works over SSH) |
| `copy -n` | same, keep trailing newline |
| `copy_cmd echo hi` | copy the text `echo hi` without running it |
| `test_colors.sh` | 16 / 256 / truecolor + style test |
| `test_text_styles.sh` | bold / italic / underline test |

### secrets & machine-local config
`~/.zshrc.local` is sourced at the end if it exists and is **not tracked**. Put API keys and machine-specific paths there.

---

## tmux

**prefix = `Ctrl-a`**. `prefix + ?` for the popup.

### no prefix
| keys | does |
|---|---|
| `Ctrl-h/j/k/l` | navigate panes (vim-aware — passes through to nvim splits) |
| `Alt-h` / `Alt-l` | previous / next **window** |
| `Alt-j` / `Alt-k` | next / previous **session** |
| `Alt-1` … `Alt-0` | jump to window 1–10 |
| `Alt-H/J/K/L` (shift) | resize pane |

### windows
| keys | does |
|---|---|
| `prefix c` | new window (inherits cwd) |
| `prefix ,` | rename window |
| `prefix .` | move window to index |
| `prefix <` / `>` | swap window left / right |
| `prefix Tab` | last window |
| `prefix X` | kill window |

### panes
| keys | does |
|---|---|
| `prefix \|` | split side-by-side |
| `prefix -` | split stacked |
| `prefix z` | zoom toggle |
| `prefix H/J/K/L` | resize (repeatable) |
| `prefix Space` | cycle layouts |
| `prefix =` / `+` | balance side-by-side / stacked |
| `prefix q` | show pane numbers |
| `prefix x` | kill pane |

### sessions
| keys | does |
|---|---|
| `prefix s` | session picker |
| `prefix F` | fzf picker over sessions / windows / panes |
| `prefix C-c` | new session |
| `prefix C-f` | find session by name |
| `prefix $` | rename session |
| `prefix C-x` | kill session (confirms) |
| `prefix d` | detach |

### copy mode (vi)
| keys | does |
|---|---|
| `prefix [` | enter copy mode |
| `v` / `C-v` | begin selection / rectangle toggle |
| `y` | copy + exit |
| `Esc` | cancel |

### toggles & misc
| keys | does |
|---|---|
| `prefix m` | toggle mouse |
| `prefix S` | synchronize panes (type in all at once) |
| `prefix C-l` | clear screen + scrollback |
| `prefix r` | reload config |
| `prefix I` | install plugins (tpm) |
| `prefix t` | clock |

Status bar shows `PREFIX` / `COPY` / `SYNC` indicators on the right when active. Windows with background activity turn yellow.

---

## neovim (kickstart, leader = `Space`)

### telescope
| keys | does |
|---|---|
| `<leader>sf` | search files |
| `<leader>sg` | live grep |
| `<leader>sw` | search current word |
| `<leader>s.` | recent files |
| `<leader><leader>` | open buffers |
| `<leader>sh` / `sk` / `sc` | help tags / keymaps / commands |
| `<leader>sd` | diagnostics |
| `<leader>sr` | resume last picker |
| `<leader>sn` | search nvim config |

### lsp
| keys | does |
|---|---|
| `grd` / `grr` / `gri` / `grt` | goto definition / references / implementation / type |
| `grn` | rename |
| `gra` | code action |
| `gO` / `gW` | document / workspace symbols |
| `K` | hover docs |
| `<leader>th` | toggle inlay hints |
| `<leader>f` | format buffer |
| `<leader>q` | diagnostics → location list |

### buffers (bufferline)
| keys | does |
|---|---|
| `Shift-h` / `Shift-l` | prev / next buffer |
| `<leader>1` … `9` | jump to buffer N |
| `<leader>x` | close buffer |
| `<leader>bp` / `bo` | pin / close others |
| `:q` | closes the buffer, or quits if it's the last one |

### windows & misc
| keys | does |
|---|---|
| `Ctrl-h/j/k/l` | navigate splits (and out into tmux panes) |
| `<Esc>` | clear search highlight |
| `<Esc><Esc>` (terminal) | back to normal mode |
| `<leader>ut` | toggle undotree |
| `<leader>tm` | toggle markdown rendering |
| `<leader>ac` / `af` | toggle / focus Claude Code panel |
| `<leader>as` (visual) | send selection to Claude |
| `<leader>aa` / `ad` | accept / deny Claude diff |

Type a leader prefix and pause — which-key shows the rest.

---

## kitty

Monokai Pro palette, `MesloLGS Nerd Font` 14pt, Option sends Alt (so `Alt-*` bindings work), OSC52 clipboard writes allowed (so `copy` / nvim yank work over SSH).

| keys | does |
|---|---|
| `Cmd-t` / `Cmd-w` | new tab (cwd) / close tab |
| `Cmd-1` … `5`, `Cmd-←/→` | switch tabs |
| `Cmd-Shift-Enter` | new window (cwd) |
| `Cmd-=` / `Cmd--` / `Cmd-0` | font size |
| `Cmd-k` | clear scrollback |

---

## git

| cmd | does |
|---|---|
| `git lg` | graph log, all branches |
| `git st` | short status |
| `git co` / `br` / `cm` | checkout / branch / commit -m |
| `git amend` | amend without editing message |
| `git undo` | soft-reset last commit |
| `git stash-all` | stash including untracked |

Defaults: `pull.rebase`, `push.default=current`, `init.defaultBranch=main`, delta side-by-side pager, `gh` as credential helper. Global ignore at `~/.config/git/ignore` (`.claude/settings.local.json`, `.DS_Store`).

---

## Claude Code

Status line (Monokai):

```
Opus 5 │ effort high │ ~/repo/src │  main │ ctx 32% │ 5h 3% · in 4h 34m │ 7d 22% │ $26.58 │ +142 -37
```

model · effort · directory (bold leaf) · branch · context % (green → yellow → orange → pink) · 5h limit + reset countdown · 7d limit · session cost · diff stats. Segments hide when their data is absent.

**SessionStart hook:** if `.claude/SKILLS.md` exists in the cwd or any parent, its contents are injected into context at session start — a per-project always-on prompt without a global rule.

| cmd | does |
|---|---|
| `/help` | full list |
| `/rename <name>` | name the session |
| `/clear` | clear context |
| `/model` | switch model |
| `/fast` | toggle fast mode |
| `/loop <interval> <cmd>` | recurring prompts |

## Codex

`codex/config.toml` → `~/.codex/config.toml`: xhigh reasoning, multi-agent on, native status line with the same segments as Claude's. **Note:** it sets `approval_policy = "never"` and `sandbox_mode = "danger-full-access"` — Codex runs commands without asking.
