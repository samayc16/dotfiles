#!/usr/bin/env bash
# Pre-accept Claude Code's workspace-trust prompt for the folders these dotfiles manage.
# Claude Code has no global switch (and never persists trust for $HOME); trust covers
# subfolders except nested git repos, which get their own entry. Safe to re-run.
set -euo pipefail

config="$HOME/.claude.json"
[[ -f "$config" ]] || { echo "trust: $config not found yet (run claude once), skipping"; exit 0; }

dirs=("$HOME/dotfiles" "$HOME/learn" "$HOME/scratch")
for repo in "$HOME"/learn/projects/*/*/; do
  [[ -d "$repo.git" ]] && dirs+=("${repo%/}")
done

python="${DOTFILES_PYTHON:-$(command -v python3 || true)}"
[[ -x "$python" ]] || { echo "trust: no python3, skipping"; exit 0; }

"$python" - "$config" "${dirs[@]}" <<'PY'
import json, os, sys, tempfile

path, dirs = sys.argv[1], sys.argv[2:]
with open(path) as f:
    data = json.load(f)
projects = data.setdefault("projects", {})
new = [d for d in dirs if os.path.isdir(d) and not projects.get(d, {}).get("hasTrustDialogAccepted")]
for d in new:
    projects.setdefault(d, {})["hasTrustDialogAccepted"] = True
if new:
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path))
    with os.fdopen(fd, "w") as f:
        json.dump(data, f, indent=2)
    os.chmod(tmp, os.stat(path).st_mode & 0o777)
    os.replace(tmp, path)
print("trust: " + (", ".join(os.path.basename(d) for d in new) if new else "all managed folders already trusted"))
PY
