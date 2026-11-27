# learn & train (all offline)

Start here: `learn` for exercises, `:Dojo` for vim skills, `play` for everything else. Roadmap: [learn/ROADMAP.md](../learn/ROADMAP.md).

## learn (exercises with tests, stars and XP)
| cmd / keys | does |
|---|---|
| `learn` | dashboard: level, XP, streak, next up |
| `learn <Tab>` | every course, plus the commands |
| `learn <track>` | open that course's next exercise in nvim (same as `learn next <track>`) |
| `learn prev [track]` | the exercise before the current one (`<leader>lp` in nvim) |
| `learn list <track>` / `learn next` | exercises with ★ / next exercise where you left off (inside one: the next open one after it) |
| `learn check` · `hint` · `solution` · `giveup` | run checks on the saved files · next hint (caps ★) · reference after passing |
| `learn docs <lang>` | offline docs (cppreference, Python, Haskell, Swift book, Verilator) |
| `<leader>ll` / `<leader>ln` / `<leader>lp` | pick exercise / next / previous exercise (inside nvim) |
| `<leader>lc` / `<leader>lh` | check in bottom panel / hint float |
| `<leader>ls` `<leader>lr` `<leader>ld` `<leader>lD` | solution / README / dashboard / docs |
| `WAVES=1 learn check` | SystemVerilog: also dump `wave.vcd` → `surfer wave.vcd` |

Tracks: `shell` (35 grep/rg/sed/awk levels, golf par for ★★★) · `python-koans` `c-koans` `cpp-koans` `swift-koans` `haskell-koans` · `systemverilog` (22, gates → UVM-style) · Exercism `python` `c` `cpp` `swift`.

## :Dojo (vim golf for motions and this config)
| cmd | does |
|---|---|
| `:Dojo` / `:Dojo next` | belt menu (white → black) / next unsolved challenge |
| `:Dojo <id>` / `:Dojo stats` / `:Dojo quit` | play one (e.g. `g-03`) / XP + streak / leave |
Par = keystrokes: ★★★ ≤ par, ★★ ≤ 1.5× par. The black belt drills this config's keymaps.

## play (games and trainers menu)
| cmd | does |
|---|---|
| `play` · `play <name>` · `play --list` | fzf menu (Train: nvim → Train: terminal → Play) · launch one · list |
| `:Games` | the same, inside nvim |
| `:VimBeGood` · `:TrainWord` `:TrainUpDown` `:TrainTextObj` | motion drills |
| `:Typr` / `:Speedtyper` | typing practice |
| `:Hardtime toggle` / `:Hardtime report` | motion coach (on, hints only) / your worst habits |
| `play gameshell` · `play murder-mystery` · `play bashcrawl` | shell missions · grep detective · cd/ls dungeon |
| `play grep-exercises` `sed-exercises` `awk-exercises` | interactive text-processing puzzles |
| `play doom` · `play zork1` · `play nethack` · `play vitetris` … | DOOM in nvim, Zork I–III, roguelikes, arcade classics ([docs/games.md](../docs/games.md)) |
