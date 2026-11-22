# learn

A gamified, offline trainer: koans, Exercism tracks, shell puzzles and HDL exercises with
stars, XP, levels and streaks, driven from the terminal (`learn`) or nvim (`<leader>l`).
**Start with [ROADMAP.md](./ROADMAP.md).**

```
learn/
├── fetch.sh            downloads Exercism tracks, example projects, offline docs → ~/learn
├── ROADMAP.md          where to start, per language
├── learnlib/           the CLI (Python 3 stdlib only); bin/learn is the entry point
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
                                  "check": "check.sh", "par": <optional golf chars>, "hints": [...]}
  README.md                      the task
  check.sh                       cwd = workspace; env LEARN_EXERCISE_DIR, LEARN_WORKSPACE; exit 0 = pass
  data/                          optional read-only inputs ($LEARN_EXERCISE_DIR/data)
  solution/                      optional reference, shown only after a pass or `learn giveup`
```

Directories starting with `_` (shared checker libraries, tooling) are ignored by the loader.
Koans: edit `tracks/_tools/defs/<lang>_koans.py`, then
`python3 tracks/_tools/genkoans.py tracks/_tools/defs/<lang>_koans.py tracks/<lang>-koans`.
Every starter must fail its check and every `solution/` must pass it.
