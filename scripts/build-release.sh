#!/usr/bin/env bash
# Build the all-in-one release tarball:   scripts/build-release.sh VERSION OUT.tar.gz
#
#   dotfiles/               a git archive of HEAD, with the working tree's pins.txt,
#                           mise/global.toml and nvim/lazy-lock.json (the release job commits them
#                           first; test jobs build with freshly bumped versions)
#   dotfiles/dist/          the pinned plexamp-tui wheel, from its GitHub release
#   dotfiles/VERSION        VERSION, e.g. 2026.11.24
#   dotfiles/VERSIONS.txt   every pinned item and its version
#
# Needs git, curl, python3; GITHUB_TOKEN avoids API rate limits. `bin/dotfiles install --from
# OUT.tar.gz` installs the result.
set -euo pipefail
export COPYFILE_DISABLE=1 # macOS tar: no ._ AppleDouble files

VERSION="${1:-}"
OUT="${2:-}"
[[ -n "$VERSION" && -n "$OUT" ]] || { echo "usage: $0 VERSION OUT.tar.gz" >&2; exit 2; }
[[ "$VERSION" =~ ^[0-9][0-9A-Za-z.-]*$ ]] || { echo "bad version: $VERSION" >&2; exit 2; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
case "$OUT" in /*) ;; *) OUT="$PWD/$OUT" ;; esac
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
PKG="$STAGE/dotfiles"

mkdir -p "$PKG/dist"
git -C "$ROOT" archive --format=tar HEAD | tar -xf - -C "$PKG"
for maintained in pins.txt mise/global.toml nvim/lazy-lock.json; do cp "$ROOT/$maintained" "$PKG/$maintained"; done
printf '%s\n' "$VERSION" >"$PKG/VERSION"

if [[ "$(awk '$1 == "plexamp-tui" { print $4 }' "$PKG/pins.txt")" == - ]]; then
  echo "warning: no plexamp-tui release pinned yet: nothing bundled in dist/" >&2
else
  wheel_url="$(python3 "$ROOT/scripts/bump-pins.py" asset --pins "$PKG/pins.txt" plexamp-tui '*.whl')"
  curl -fsSL --retry 6 --retry-delay 20 -o "$PKG/dist/${wheel_url##*/}" "$wheel_url" # GitHub 503s at times
fi

{
  printf 'dotfiles %s (commit %s)\n\n' "$VERSION" "$(git -C "$ROOT" rev-parse HEAD)"
  python3 "$ROOT/scripts/bump-pins.py" table --pins "$PKG/pins.txt"
  printf '\nNeovim plugins are pinned by nvim/lazy-lock.json, language servers and formatters by\n'
  printf 'mason-registry. On macOS the CLI tools come from Homebrew at its current versions\n'
  printf "(Homebrew can't pin); the mise/* pins are for Linux.\n"
} >"$PKG/VERSIONS.txt"

tar -czf "$OUT" -C "$STAGE" dotfiles
echo "built $OUT ($VERSION, $(du -h "$OUT" | cut -f1 | tr -d ' '))"
