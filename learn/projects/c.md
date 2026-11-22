# Reading quests: C

Real C, read with your LSP. Tick a box when you've done it. Projects live in
`~/learn/projects/c/` (fetched by `learn/fetch.sh`; `compile_flags.txt` is already
there so clangd understands them).

Keys you'll use: `gO` symbols in file · `grd` go to definition · `<C-o>` / `<C-i>` back / forward ·
`grr` references · `K` hover · `<leader>sg` grep · `[x` jump to enclosing function.

## kilo: a whole text editor in ~1,300 lines (`cd ~/learn/projects/c/kilo && nvim kilo.c`)

- [ ] **Map the territory.** `gO` and list the ~10 most important functions. Which one is the main loop?
- [ ] **Follow a keypress.** Start at `main` (`gO` → main). `grd` into `editorProcessKeypress`, then into
      `editorReadKey`. How does it turn the 3-byte escape sequence for an arrow key into `ARROW_UP`?
- [ ] **Raw mode.** `grd` into `enableRawMode`. `K` on each termios flag (`ICANON`, `ECHO`, `ISIG`).
      Why does an editor need to switch these off? What restores them on exit (`grr` on `disableRawMode`)?
- [ ] **One write per frame.** In `editorRefreshScreen`, find the `struct abuf`. `grr` on `abAppend`:
      why build the whole screen in a buffer and `write()` once instead of many small writes?
- [ ] **Syntax highlighting.** `editorUpdateSyntax` colours a row. Find how it knows it's inside a
      multi-line comment (hint: a field on the previous row).
- [ ] **Prove it.** Build it: `<leader>rr` won't do (it needs a terminal), so run `make && ./kilo kilo.c`
      in a terminal (`<leader>tt`). Add a new keybinding (e.g. Ctrl-D duplicates the current line) and use it.

## chibicc: a real C compiler you can read (`cd ~/learn/projects/c/chibicc && nvim main.c`)

- [ ] **The pipeline.** In `main.c`, find where source text becomes tokens, then an AST, then assembly.
      `grd` into `tokenize`, `parse`, and `codegen`. Write the three steps down.
- [ ] **Tokens.** In `tokenize.c`, `gO` → `tokenize`. How does it recognise a keyword vs an identifier?
- [ ] **Recursive descent.** In `parse.c`, `grr` on `expr`, then `grd` from `expr` down through `assign` →
      `equality` → `relational` … Each function is one precedence level: see why `*` binds tighter than `+`.
- [ ] **Types.** `K` on `Type` and `Node`. How does `add_type` (in `type.c`) decide the type of `a + b`?
- [ ] **Git archaeology.** The repo's commits build the compiler one feature at a time. In a terminal:
      `git log --reverse --oneline | head -30`: each commit is a lesson. (`<leader>gl` shows a file's log.)

> Want to debug either one? Build with `-g -O0`, then `<leader>db` on a line and `<leader>dc` →
> pick the binary. Step with `<leader>di` (into) / `<leader>do` (over).
