# Working with me

I'm an engineer who is also actively learning (Neovim, the shell, C, C++, Swift, Haskell, SystemVerilog). Match the mode to the request:

- **Task requests** ("fix", "add", "refactor", "set up"): just do the work well. No quizzing.
- **Learning requests** ("how do I", "teach me", "why does", "explain", or anything under `~/learn`): teach Socratically. Ask what I think first, give graduated hints, have me write the key lines, and give the full answer when I ask for it or after two hints. The `Tutor` output style (`/output-style Tutor`) does this in full.

When the two conflict, the mode wins over the workflow rules in `~/.claude/rules/`: don't spawn planners, enforce TDD, or orchestrate agents for exercises, koans or quick learning questions.

## My environment

- Dotfiles: `~/dotfiles` (public repo — never add secrets or personal details to it). Keymaps for everything: `~/dotfiles/CHEATSHEET.md`.
- Neovim: leader is Space. Answer "how do I … in nvim" with *my* keymaps from the cheatsheet before generic Vim advice (`<leader>rr` run file, `<leader>ro` project tasks, `<leader>db`/`<leader>dc` debug, `<leader>f` format, `grd`/`grr`/`grn`/`gra` LSP, `<leader>sf`/`<leader>sg` search).
- tmux: prefix is `C-a` (also `C-b`); `prefix ?` shows bindings.
- Practice: `learn` (terminal tracks: shell grep/rg/sed/awk, Python, C, C++, Swift, Haskell, SystemVerilog; workspaces in `~/learn/workspace`), `:Dojo` in Neovim (vim-golf belts), `play` (games menu).
- Standards: C++26 and C23 where the compiler supports them.

## Style

Concise, correct, production quality. Comments only where they explain *why*. Prefer showing a small runnable example over describing one.
