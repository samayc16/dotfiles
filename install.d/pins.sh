#!/usr/bin/env bash
# Read pins.txt and keep git clones at pinned commits. Sourced (by learn/fetch.sh and the
# install.d steps), never executed. Functions only report through their exit status, so each
# caller prints in its own style. Bash 3.2 compatible.

PINS_FILE="${PINS_FILE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/pins.txt}"

# pin_lookup NAME → prints "SOURCE VERSION"; fails when NAME isn't pinned.
pin_lookup() {
  local name _kind source version
  while read -r name _kind source version _; do
    [[ "$name" == "$1" ]] && { printf '%s %s\n' "$source" "$version"; return 0; }
  done < <(pins_all)
  return 1
}

# pins_with_prefix PREFIX → prints "NAME SOURCE VERSION" for each pin whose name starts with PREFIX.
pins_with_prefix() {
  local name _kind source version
  while read -r name _kind source version _; do
    [[ "$name" == "$1"* ]] && printf '%s %s %s\n' "$name" "$source" "$version"
  done < <(pins_all)
}

pins_all() {
  [[ -r "$PINS_FILE" ]] || { echo "pins: cannot read $PINS_FILE" >&2; return 1; }
  grep -v -e '^[[:space:]]*#' -e '^[[:space:]]*$' "$PINS_FILE"
}

# pin_sync URL DIR REV [SPARSE_PATH...] → clone DIR at REV (sparse when paths follow), or move
# an existing clone to REV. A clone you've changed is never touched. Status, for the caller:
#   0 cloned   10 already at REV   11 moved to REV   12 kept: it has your changes
#   1 failed (network, or REV doesn't exist)
pin_sync() {
  local url="$1" dir="$2" rev="$3"
  shift 3
  if [[ -d "$dir/.git" ]]; then
    [[ "$(git -C "$dir" rev-parse -q --verify HEAD)" == "$rev" ]] && return 10
    git_pristine "$dir" || return 12
    git_checkout_pin "$dir" "$rev" && return 11
    return 1
  fi
  mkdir -p "$(dirname "$dir")" || return 1
  if (($# > 0)); then
    git clone -q --depth 1 --filter=blob:none --sparse "$url" "$dir" && git -C "$dir" sparse-checkout set "$@"
  else
    git clone -q --depth 1 "$url" "$dir"
  fi && git_checkout_pin "$dir" "$rev" || return 1
}

# Safe to move: no edits to tracked files, and HEAD is upstream's commit (a shallow root this
# fetched, or reachable from a remote branch), so nothing of yours is left behind.
git_pristine() {
  local head
  [[ -z "$(git -C "$1" status --porcelain --untracked-files=no 2>/dev/null)" ]] || return 1
  head="$(git -C "$1" rev-parse -q --verify HEAD)" || return 1
  grep -qxF "$head" "$(git -C "$1" rev-parse --absolute-git-dir)/shallow" 2>/dev/null && return 0
  [[ -z "$(git -C "$1" rev-list -n 1 HEAD --not --remotes 2>/dev/null)" ]]
}

git_checkout_pin() {
  [[ "$(git -C "$1" rev-parse -q --verify HEAD)" == "$2" ]] && return 0
  git -C "$1" fetch -q --depth 1 origin "$2" && git -C "$1" checkout -q --detach FETCH_HEAD
}
