# learn

A gamified, offline trainer: koans, Exercism tracks, shell puzzles and HDL exercises with
stars, XP, levels and streaks, driven from the terminal (`learn`) or nvim (`<leader>l`).
**Start with [ROADMAP.md](./ROADMAP.md).**

```
learn/
├── fetch.sh            downloads Exercism tracks, example projects, offline docs → ~/learn
├── ROADMAP.md          where to start, per language
├── learnlib/           the CLI (Python 3 stdlib only); bin/learn is the entry point
├── tests/              unit + end-to-end tests (CLI on the shell track, learn.lua in headless nvim):
│                       python3 -m unittest discover -s learn/tests -t learn
├── tracks/<track>/     custom tracks in the shared format (below)
│   └── _tools/         genkoans.py + defs/: koans are generated from one source per language
└── projects/<lang>.md  reading quests for the example projects
```

Data lives outside the repo in `~/learn` (override with `LEARN_HOME`): `vendor/` (Exercism),
`projects/`, `docs/`, `workspace/<track>/<slug>/` (your solutions), `progress.json`, `.venv/`.

## Track format

```
tracks/<track>/track.json        {"name", "slug", "language", "description", "order": ["01-x", ...]}
tracks/<track>/<NN-slug>/
  exercise.json                  {"title", "difficulty": 1-5, "xp", "concepts": [...],
                                  "files": [learner-editable files], "open": "<main file>",
                                  "check": "check.sh", "par": <optional golf chars>, "hints": [...],
                                  "support": [optional read-only files, e.g. Cargo.toml + tests]}
  README.md                      the task
  check.sh                       cwd = workspace; env LEARN_EXERCISE_DIR, LEARN_WORKSPACE, LEARN_HOME,
                                 NO_COLOR when learn's own output is plain; exit 0 = pass,
                                 127 = a tool it needs is missing (reported, not counted as an attempt)
  data/                          optional read-only inputs ($LEARN_EXERCISE_DIR/data)
  solution/                      optional reference, shown only after a pass or `learn giveup`
```

Directories starting with `_` (shared checker libraries, tooling) are ignored by the loader.
Koans: edit `tracks/_tools/defs/<lang>_koans.py`, then
`python3 tracks/_tools/genkoans.py tracks/_tools/defs/<lang>_koans.py tracks/<lang>-koans`.
Every starter must fail its check and every `solution/` must pass it. `tracks/_tools/verify.py <track>`
proves that for any track through the real CLI (`learn start`, `learn check`, the recorded score) in a
throwaway LEARN_HOME; CI runs it for the tracks whose toolchain installs cheaply. Some tracks add their
own `_verify.sh` with stricter, track-specific rules (clippy-clean Rust, lint-free SystemVerilog, golf par).

`learn check` reads the files on disk. It warns when Vim/Neovim holds unsaved edits to them (from the
swap file) and doesn't count a check of unsaved or untouched starter files as an attempt.

`support` files are refreshed into the workspace on every `learn start`/`learn check` (written only when
they changed) but never opened for editing: project files a language server needs, or tests the learner
may read and run. Checkers should still use the pristine copies in `$LEARN_EXERCISE_DIR`.
