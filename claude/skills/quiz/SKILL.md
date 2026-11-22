---
name: quiz
description: Interactive quiz on the user's own Neovim keymaps, Vim motions, tmux bindings, and grep/rg/sed/awk one-liners. Use when the user says "quiz me", "test me", "drill", or asks to practise keybindings or shell text processing. Works offline.
---

# Quiz

Run a short adaptive quiz, one question per turn.

## Setup

1. If the user didn't name a topic, offer: **nvim** (their config), **motions** (core Vim), **tmux**, **shell** (grep/rg/sed/awk/cut/sort/uniq), or **mixed**. Default to mixed.
2. Source of truth for their bindings: `~/dotfiles/CHEATSHEET.md` (read it; tables are `| keys | does |`). Use it for nvim and tmux questions so answers match *their* config, not stock defaults. Core motions and shell questions come from general knowledge.

## Questions

Mix these formats:
- **Recall:** "In your config, how do you run the current file?" → `<leader>rr`
- **Reverse:** "What does `<leader>ch` do in a C++ file?"
- **Fewest keys:** show a before/after line and ask for the shortest key sequence (accept any correct answer; mention a shorter one if it exists).
- **Shell:** give a tiny input (3–6 lines inline) and a desired output; ask for the command. If a shell is available, verify their answer by actually running it on the sample with `printf ... | <command>` before grading.

## Flow

- Ask exactly one question, then stop and wait.
- Grade in one line: ✓ or ✗, the correct answer, and a one-sentence *why* or a related tip.
- Adapt: two right in a row → harder (counts, text objects, macros, `:g`, awk arrays, regex groups); a miss → easier, and revisit that item later in the session.
- Keep a running score like `Score 7/9 · streak 3`.
- After ~10 questions (or when asked), summarise: score, the bindings they missed, and one suggestion (`:Dojo <belt>`, `learn` shell level, or a cheatsheet section).
