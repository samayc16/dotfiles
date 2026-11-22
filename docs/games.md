# Games and trainers

`play` opens a menu of everything installed, grouped by what it trains. `:Games` does the same inside nvim.
Install or refresh with `games/install.sh` (also part of `./install.sh`); data lives in `~/games`.

## Train: Neovim

| launch | what it trains |
|---|---|
| `:Dojo` | vim golf: motions → text objects → macros → this config's keys |
| `:VimBeGood` | relative jumps, `ci{`, word deletes, whack-a-mole |
| `:TrainWord` · `:TrainUpDown` · `:TrainTextObj` | shows where motions land in the current buffer |
| `:Typr` · `:Speedtyper` | typing speed and accuracy (`:TyprStats` for history) |
| `:Hardtime report` | your most repeated inefficient keys (Hardtime hints while you edit; `:Hardtime toggle`) |
| `:Tutor` | Neovim's built-in tutorial |

## Train: terminal

| launch | what it trains |
|---|---|
| `learn` → `shell` | 35 grep/rg/sed/awk levels with golf par |
| `play grep-exercises` · `sed-exercises` · `awk-exercises` · `cli-exercises` | interactive text-processing puzzles |
| `play gameshell` | shell missions; progress saves on `gsh exit` |
| `play murder-mystery` | solve a murder with grep, head and awk |
| `play bashcrawl` | a dungeon you explore with cd, ls and cat |

## Play

| launch | game |
|---|---|
| `play doom` (`:Doom` in nvim) | DOOM: arrows move, `x` fires, space opens, `Ctrl-\ Ctrl-n` back to nvim |
| `play zork1` · `zork2` · `zork3` | Infocom's Zork trilogy |
| `play nethack` · `angband` · `curseofwar` | roguelikes and strategy |
| `play vitetris` · `ninvaders` · `nsnake` · `moon-buggy` · `myman` · `2048` · `solitaire` | arcade classics |
| `play sedtris` · `awkaster` | Tetris written in sed, a shooter written in awk |
| `play playtime` · `sudoku` · `minesweeper` · `nvim-tetris` · `killersheep` · `blackjack` | games inside nvim |
