# cheatsheet

Everything wired up by this repo, grouped by tool. Inside tmux, `prefix + ?` shows the live popup version.

## install

| cmd | does |
|---|---|
| `./install.sh` | everything for this OS (macOS, Arch, Debian/Ubuntu, Fedora/RHEL); no root needed on Linux |
| `./install.sh --profile cli` | shell, tmux, nvim and CLI tools only (minimal boxes) |
| `./install.sh --list-steps` · `--only <step>` · `--skip <step>` | show steps · re-run one · skip one |
| `./install.sh --link-only` · `--dry-run` | just symlinks · print the plan |
| `~/dotfiles/learn/fetch.sh` | refresh exercises, projects and offline docs before a flight |

---

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
| `cmd \| copy` | stream output **and** copy it (OSC52 locally, over SSH and in tmux; plus pbcopy / wl-copy / xclip when local) |
| `copy -n` | same, keep trailing newline |
| `copy_cmd echo hi` | copy the text `echo hi` without running it |
| `test_colors.sh` | 16 / 256 / truecolor + style test |
| `test_text_styles.sh` | bold / italic / underline test |

### secrets & machine-local config
`~/.zshrc.local` is sourced at the end if it exists and is **not tracked**. Put API keys and machine-specific paths there.

---

## tmux

**prefix = `Ctrl-a`** (also `Ctrl-b`). `prefix + ?` for the popup.

### no prefix
| keys | does |
|---|---|
| `Ctrl-h/j/k/l` | navigate panes (vim-aware — passes through to nvim splits) |
| `Alt-h` / `Alt-l` | previous / next **window** |
| `Alt-j` / `Alt-k` | previous / next **session** |
| `Alt-1` … `Alt-0` | jump to window 1–10 |
| `Alt-H/J/K/L` (shift) | resize pane |
| `Alt-←/→` | passed through to the shell (word movement) |

### windows
| keys | does |
|---|---|
| `prefix c` | new window (inherits cwd) |
| `prefix ,` | rename window |
| `prefix .` | move window to index |
| `prefix <` / `>` | swap window left / right |
| `prefix Tab` | last window |
| `prefix X` | kill window (confirms) |

### panes
| keys | does |
|---|---|
| `prefix "` or `-` | split stacked (top/bottom) |
| `prefix %` or `_` | split side-by-side (left/right) |
| `prefix z` | zoom toggle |
| `prefix Space` | cycle layouts |
| `prefix =` / `\|` | balance horizontally / vertically |
| `prefix q` | show pane numbers |
| `prefix x` | kill pane (confirms) |

### sessions
| keys | does |
|---|---|
| `prefix s` | session picker |
| `prefix F` | fzf picker over sessions / windows / panes |
| `prefix C-c` | new session |
| `prefix C` | new session, prompt for name |
| `prefix g` | goto session (prompt with completion) |
| `prefix C-f` | find session by name |
| `prefix A` | alternate (last) session |
| `prefix $` | rename session |
| `prefix @` / `t` | promote pane to session / join pane from session |
| `prefix C-x` | kill session (confirms) |
| `prefix d` | detach |

### copy mode (vi)
| keys | does |
|---|---|
| `prefix [` | enter copy mode (mouse wheel also enters it) |
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

Status bar: session pill (green) · windows (active = pink pill; ● activity, 🔔 bell, 🔍 zoom) · right: PREFIX / COPY / SYNC, host (SSH only), weather (hidden offline), date + time pill. Active pane border: purple in copy mode, orange while synced.

Renames (`,` `$`), move (`.`), find (`C-f`) and new/goto session (`C` / `g`) open a small centred popup with the current name pre-filled: Enter applies, Esc cancels. Kills (`x` `X` `C-x`) ask in a Yes/No menu with Cancel pre-selected.

---

## neovim (leader = `Space`)

Press a leader prefix and pause: which-key lists everything under it. `<leader>?` shows buffer-local keys, `<leader>sk` searches every keymap.
Layout: `nvim/lua/config/` (options, keymaps) · `nvim/lua/plugins/` (one file per concern) · `nvim/lua/plugins/lang/` (one file per language).

### languages (all offline once installed)
| language | LSP | format | run `<leader>rr` | debug |
|---|---|---|---|---|
| Python | basedpyright + ruff | ruff (on save) | `.venv` python, else python3 | debugpy (`<leader>dm` test method) |
| C / C++ | clangd (Xcode's on macOS) | clang-format (on save if `.clang-format`) | clang -std=c23 / c++26 + ASan/UBSan | codelldb ("Debug current file") |
| Swift | sourcekit-lsp | swift-format / SwiftFormat | `swift run` (packages) or `swift file` | lldb-dap · Xcode apps: `<leader>X…` |
| SystemVerilog / Verilog | slang-server | Verible (`<leader>f`) | Verilator `--binary` (top = module named after file) | waves: `<leader>ro` → surfer |
| Haskell | haskell-language-server | fourmolu (on save) | runghc | |
| Lua / shell | lua_ls + lazydev / bashls + ShellCheck | stylua / shfmt (`<leader>f`) | `nvim -l` / bash | |

Standalone C++ files default to **C++26** and C files to **C23** (`clangd/config.yaml`); projects use their `compile_commands.json`.

### code (LSP)
| keys | does |
|---|---|
| `K` | hover docs |
| `grd` / `grr` / `gri` / `grt` / `grD` | definition / references / implementation / type / declaration |
| `grn` or `<leader>cr` | rename symbol |
| `gra` or `<leader>ca` | code action |
| `gO` / `gW` | document / workspace symbols |
| `]d` `[d` · `]r` `[r` | next/prev diagnostic · next/prev reference to symbol under cursor |
| `<leader>q` / `<leader>Q` | diagnostics list (buffer / workspace) |
| `<leader>cs` | symbols outline |
| `<leader>cl` | run code lens |
| `<leader>ch` | C/C++: switch source ↔ header |
| `<leader>cR` / `<leader>ci` | restart LSP / LSP info |
| `<leader>f` | format buffer |
| `<leader>th` · `<leader>td` · `<leader>tf` | toggle inlay hints · multi-line diagnostics · format on save |

### completion & snippets
| keys | does |
|---|---|
| `Ctrl-y` / `Tab` / `Enter` | accept suggestion (all three work; `Ctrl-e` closes the menu for a plain newline) |
| `Ctrl-n` / `Ctrl-p` | next / previous suggestion |
| `Ctrl-Space` | open menu / docs |
| `Tab` / `Shift-Tab` | jump between snippet placeholders |
| `Ctrl-k` | signature help |

SystemVerilog snippets: `mod` `modp` `aff` `affs` `acomb` `fsm` `intf` `pkg` `struct` `enum` `genfor` `tb` `assertp` `coverp` `cg` `class` `func` `task` `fork` · UVM: `uvm_item` `uvm_seq` `uvm_drv` `uvm_mon` `uvm_agent` `uvm_sb` `uvm_env` `uvm_test` `uvm_top` `uinfo` `uerr` `ufatal` `cfgset` `cfgget`.

### run & build (overseer)
| keys | does |
|---|---|
| `<leader>rr` / `<leader>rR` | run current file / with arguments |
| `<leader>ro` | pick a project task (make, cmake, swift build/test, pytest, verilator lint, iverilog, surfer…) |
| `<leader>rl` | re-run last task |
| `<leader>rt` | toggle task list (`o` open output, `dd` dispose) |
| `<leader>rs` | run a shell command as a task |

### debug (nvim-dap)
| keys | does |
|---|---|
| `<leader>db` / `<leader>dB` | toggle breakpoint / conditional breakpoint |
| `<leader>dc` or `F5` | start / continue |
| `<leader>do` `<leader>di` `<leader>dO` (`F10` `F11` `F12`) | step over / into / out |
| `<leader>dC` | run to cursor |
| `<leader>de` | evaluate expression / selection |
| `<leader>du` / `<leader>dr` | toggle debug UI / REPL |
| `<leader>dl` / `<leader>dt` | run last / terminate |

### Xcode projects (macOS)
Run `:XcodebuildSetup` once in the project root (writes `buildServer.json` so sourcekit-lsp understands the `.xcodeproj`).
| keys | does |
|---|---|
| `<leader>XX` | all Xcode actions |
| `<leader>Xr` / `<leader>Xb` / `<leader>Xd` | build & run on simulator / build / build & debug |
| `<leader>Xt` / `<leader>XT` / `<leader>Xe` | tests / test class / test explorer |
| `<leader>Xs` / `<leader>Xp` / `<leader>Xl` | select device / SwiftUI preview / logs |
| `<leader>Xo` | open in Xcode (previews, signing, asset catalogs) |

### SystemVerilog design (slang-server)
| keys | does |
|---|---|
| `<leader>vh` / `<leader>vs` / `<leader>va` | design hierarchy / search hierarchy / select active instance |
Per-project include dirs, file lists and UVM paths go in `.slang/server.json`.

### search (telescope)
| keys | does |
|---|---|
| `<leader>sf` / `<leader>sg` / `<leader>sw` | files / live grep / word under cursor |
| `<leader><leader>` / `<leader>s.` | open buffers / recent files |
| `<leader>/` / `<leader>s/` | fuzzy in buffer / grep open files |
| `<leader>sh` `sk` `sc` `sd` `sq` `st` | help / keymaps / commands / diagnostics / quickfix / TODOs |
| `<leader>sr` / `<leader>sn` / `<leader>sN` | resume / nvim config / notifications |

### editing
| keys | does |
|---|---|
| `saiw"` / `sd'` / `sr)'` | surround: add / delete / replace (mini.surround) |
| `ci(` `daf` `cia` `yiq` `vib` | text objects incl. function call `f`, argument `a`, quote `q`, bracket `b` (mini.ai) |
| `gcc` / `gc{motion}` | comment line / motion |
| `J` / `K` (visual) | move selection down / up |
| `Ctrl-s` | save |
| `Ctrl-d` / `Ctrl-u` / `n` / `N` | scroll / search, cursor stays centred |
| `za` `zc` `zo` `zR` `zM` | folds (treesitter) |
| `[x` · `<leader>tc` | jump to enclosing function/class · toggle sticky context header |

### files, git, buffers, windows
| keys | does |
|---|---|
| `-` | file browser (oil): edit the listing like a buffer, `:w` applies renames/moves/deletes |
| `Shift-h` / `Shift-l` · `<leader>1`…`9` | prev / next buffer · jump to buffer N |
| `<leader>x` · `<leader>bp` / `<leader>bo` | close buffer · pin / close others |
| `:q` | closes the buffer, or quits if it's the last one |
| `]c` `[c` · `<leader>hs` `hr` `hp` `hb` `hd` | next/prev git hunk · stage / reset / preview / blame / diff |
| `<leader>gg` / `<leader>gl` / `<leader>gB` | lazygit / file log / open on GitHub |
| `<leader>tb` | toggle inline git blame |
| `Ctrl-h/j/k/l` | move between splits and tmux panes |
| `<leader>tt` or `Ctrl-/` | toggle terminal |
| `<leader>ut` | undotree |
| `<leader>tm` · `<leader>tw` · `<leader>ts` · `<leader>tr` | toggle markdown render · wrap · spell · relative numbers |

### Claude Code
| keys | does |
|---|---|
| `<leader>ac` / `<leader>af` | toggle / focus Claude panel |
| `<leader>ab` · `<leader>as` (visual) | add current file · send selection |
| `<leader>aa` / `<leader>ad` | accept / deny Claude's diff |

### keeping it healthy
| command | does |
|---|---|
| `:Lazy` | plugins (`:Lazy sync` to update, then commit `nvim/lazy-lock.json`) |
| `:Mason` | language servers / formatters / debuggers |
| `:checkhealth` | diagnose anything |
| `nvim --headless -c 'luafile ~/.config/nvim/scripts/smoke.lua'` | end-to-end test of every language |

---

## learn & train (all offline)

Start here: `learn` for exercises, `:Dojo` for vim skills, `play` for everything else. Roadmap: [learn/ROADMAP.md](learn/ROADMAP.md).

### learn (exercises with tests, stars and XP)
| cmd / keys | does |
|---|---|
| `learn` | dashboard: level, XP, streak, next up |
| `learn list <track>` / `learn next [track]` | exercises with ★ / open the next one in nvim |
| `learn check` · `hint` · `solution` · `giveup` | run checks · next hint (caps ★) · reference after passing |
| `learn docs <lang>` | offline docs (cppreference, Python, Haskell, Swift book, Verilator) |
| `<leader>ll` / `<leader>ln` | pick exercise / next exercise (inside nvim) |
| `<leader>lc` / `<leader>lh` | check in bottom panel / hint float |
| `<leader>ls` `<leader>lr` `<leader>ld` `<leader>lD` | solution / README / dashboard / docs |
| `WAVES=1 learn check` | SystemVerilog: also dump `wave.vcd` → `surfer wave.vcd` |

Tracks: `shell` (35 grep/rg/sed/awk levels, golf par for ★★★) · `python-koans` `c-koans` `cpp-koans` `swift-koans` `haskell-koans` · `systemverilog` (22, gates → UVM-style) · Exercism `python` `c` `cpp` `swift`.

### :Dojo (vim golf for motions and this config)
| cmd | does |
|---|---|
| `:Dojo` / `:Dojo next` | belt menu (white → black) / next unsolved challenge |
| `:Dojo <id>` / `:Dojo stats` / `:Dojo quit` | play one (e.g. `g-03`) / XP + streak / leave |
Par = keystrokes: ★★★ ≤ par, ★★ ≤ 1.5× par. The black belt drills this config's keymaps.

### play (games and trainers menu)
| cmd | does |
|---|---|
| `play` · `play <name>` · `play --list` | fzf menu (Train: nvim → Train: terminal → Play) · launch one · list |
| `:Games` | the same, inside nvim |
| `:VimBeGood` · `:TrainWord` `:TrainUpDown` `:TrainTextObj` | motion drills |
| `:Typr` / `:Speedtyper` | typing practice |
| `:Hardtime toggle` / `:Hardtime report` | motion coach (on, hints only) / your worst habits |
| `play gameshell` · `play murder-mystery` · `play bashcrawl` | shell missions · grep detective · cd/ls dungeon |
| `play grep-exercises` `sed-exercises` `awk-exercises` | interactive text-processing puzzles |
| `play doom` · `play zork1` · `play nethack` · `play vitetris` … | DOOM in nvim, Zork I–III, roguelikes, arcade classics ([docs/games.md](docs/games.md)) |

---

## kitty

Monokai Pro palette, `MesloLGM Nerd Font`, OSC52 clipboard (so `copy` and nvim yank work over SSH). Shared settings in `kitty/kitty.conf`; OS-specific ones in `kitty/macos.conf` (Option sends Alt) and `kitty/linux.conf`.

| keys | does |
|---|---|
| `Cmd-t` / `Cmd-w` | new tab (cwd) / close tab |
| `Cmd-1` … `5`, `Cmd-←/→` | switch tabs |
| `Cmd-Shift-Enter` | new window (cwd) |
| `Cmd-=` / `Cmd--` / `Cmd-0` | font size |
| `Cmd-k` | clear scrollback |

On Linux: `Ctrl-Shift-t` / `Ctrl-Shift-Enter` new tab / window in cwd, `Ctrl-Alt-1…9` go to tab, `Ctrl-Shift-=` / `-` font size.

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
