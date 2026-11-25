# tmux

**prefix = `Ctrl-a`** (also `Ctrl-b`). `prefix + ?` for the popup, `cheat tmux` for this page in a shell.

## no prefix
| keys | does |
|---|---|
| `Ctrl-h/j/k/l` | navigate panes (vim-aware — passes through to nvim splits) |
| `Alt-h` / `Alt-l` | previous / next **window** |
| `Alt-j` / `Alt-k` | previous / next **session** |
| `Alt-1` … `Alt-0` | jump to window 1–10 |
| `Alt-H/J/K/L` (shift) | resize pane |
| `Alt-←/→` | passed through to the shell (word movement) |

## windows
| keys | does |
|---|---|
| `prefix c` | new window (inherits cwd) |
| `prefix ,` | rename window |
| `prefix .` | move window to index |
| `prefix <` / `>` | swap window left / right |
| `prefix Tab` | last window |
| `prefix X` | kill window (confirms) |

## panes
| keys | does |
|---|---|
| `prefix "` or `-` | split stacked (top/bottom) |
| `prefix %` or `_` | split side-by-side (left/right) |
| `prefix z` | zoom toggle |
| `prefix Space` | cycle layouts |
| `prefix =` / `\|` | balance horizontally / vertically |
| `prefix q` | show pane numbers |
| `prefix x` | kill pane (confirms) |

## sessions
| keys | does |
|---|---|
| `prefix T` | **sesh**: fuzzy-pick a tmux session or a zoxide directory (with preview) and switch to it, creating the session if needed. In the picker: `^a` all · `^t` sessions · `^g` configured · `^x` zoxide dirs · `^f` find dirs · `^d` kill session |
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

## copy mode (vi)
| keys | does |
|---|---|
| `prefix [` | enter copy mode (mouse wheel also enters it) |
| `v` / `C-v` | begin selection / rectangle toggle |
| `y` | copy + exit |
| `Esc` | cancel |

## toggles & misc
| keys | does |
|---|---|
| `prefix m` | toggle mouse |
| `prefix S` | synchronize panes (type in all at once) |
| `prefix C-l` | clear screen + scrollback |
| `prefix r` | reload config |
| `prefix I` | install plugins (tpm; the installer already cloned them at the commits in `pins.txt`) |
| `prefix P` | **focus timer**: a 50-minute block counting down in the status bar (`◔ focus 32m`); again stops it early. When it's up: a message here and a desktop notification (macOS, or Linux with `notify-send`) |

Focus length: `set -g @focus-minutes 25` (in tmux.conf, or `tmux set -g @focus-minutes 25` for now), or `FOCUS_MINUTES=25` in the environment tmux starts with. The timer is `~/.tmux/scripts/focus.sh` (`start [min]`, `stop`, `toggle`, `status`); its state is one line in `~/.local/state/dotfiles/focus`.

Status bar: session pill (green) · windows (active = pink pill; ● activity, 🔔 bell, 🔍 zoom) · right: PREFIX / COPY / SYNC, focus timer (while one runs), host (SSH only), now playing, weather (hidden offline), date + time pill. Active pane border: purple in copy mode, orange while synced.

Renames (`,` `$`), move (`.`), find (`C-f`) and new/goto session (`C` / `g`) open a small centred popup with the current name pre-filled: Enter applies, Esc cancels. Kills (`x` `X` `C-x`) ask in a Yes/No menu with Cancel pre-selected.
