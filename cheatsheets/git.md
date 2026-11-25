# git

| cmd | does |
|---|---|
| `git lg` | graph log, all branches |
| `git st` | short status |
| `git co` / `br` / `cm` | checkout / branch / commit -m |
| `git amend` | amend without editing message |
| `git undo` | soft-reset last commit |
| `git stash-all` | stash including untracked |

Defaults: `pull.rebase`, `push.default=current`, `init.defaultBranch=main`, delta side-by-side pager, `gh` as credential helper. Global ignore at `~/.config/git/ignore` (`.claude/settings.local.json`, `.DS_Store`).
