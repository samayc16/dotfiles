# dotfiles (install & update)

| cmd | does |
|---|---|
| `./install.sh` | everything for this OS (macOS, Arch, Debian/Ubuntu, Fedora/RHEL); no root needed on Linux |
| `./install.sh --profile cli` | shell, tmux, nvim and CLI tools only (minimal boxes) |
| `./install.sh --list-steps` · `--only <step>` · `--skip <step>` | show steps · re-run one · skip one |
| `./install.sh --link-only` · `--dry-run` | just symlinks · print the plan |
| `$DOTFILES/learn/fetch.sh` | refresh exercises, projects and offline docs before a flight |
| `dotfiles status` · `dotfiles update` | what's installed and whether a newer release exists · update: a release install switches versions, a clone does `git pull --ff-only`; both re-run the installer with your flags |
| `dotfiles rollback` · `dotfiles list` | back to the previous release (again: forward) · the versions on disk (last 3 kept) |
| `DOTFILES_NO_UPDATE_CHECK=1` | in `~/.zshrc.local`: never ask `Update now? [y/N]` (asked once per release, checked daily in the background) |
