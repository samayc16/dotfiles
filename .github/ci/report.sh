#!/usr/bin/env bash
# The last job of a nightly or push run on main (install.yml `report`). A failed run opens an
# issue assigned to the repo's owner, so GitHub notifies them (email, GitHub Mobile), or comments
# on the one already open; a passing run closes it. Nightly updates and pushes each have their own
# issue: a push passing on the last good versions says nothing about tonight's new ones.
#
#   RESULTS="success failure skipped …"  the needs.*.result of every other job
#   EVENT=schedule|push  RUN_ID  RUN_URL  GITHUB_SHA  GITHUB_REPOSITORY_OWNER
#   ci-artifacts/changes.txt             what the run moved (absent when the pins job failed)
set -euo pipefail
: "${RESULTS:?}" "${EVENT:?}" "${RUN_ID:?}" "${RUN_URL:?}" "${GITHUB_SHA:?}" "${GITHUB_REPOSITORY_OWNER:?}"

if [[ "$EVENT" == schedule ]]; then
  title="Nightly update is failing"
  what="Tonight's update (everything at its newest version)"
else
  title="CI is failing on main"
  what="The push of $(git log -1 --format='%h "%s"' "$GITHUB_SHA" 2>/dev/null || echo "${GITHUB_SHA:0:7}")"
fi
issue="$(gh issue list --state open --limit 100 --json number,title --jq ".[] | select(.title == \"$title\") | .number" | head -n 1)"

if [[ " $RESULTS " != *" failure "* ]]; then
  if [[ -n "$issue" ]]; then
    gh issue close "$issue" --comment "Passing again: $RUN_URL"
  fi
  exit 0
fi

body="$(mktemp)"
trap 'rm -f "$body"' EXIT
{
  echo "$what failed, so nothing was released: \`dotfiles update\` stays on the last good versions."
  echo
  echo "Run: $RUN_URL"
  echo
  echo "Failed jobs:"
  gh run view "$RUN_ID" --json jobs --jq '.jobs[] | select(.conclusion == "failure") | "- " + .name'
  if [[ -s ci-artifacts/changes.txt ]]; then
    echo
    echo "What moved since the last release:"
    echo '```'
    cat ci-artifacts/changes.txt
    echo '```'
  fi
} >"$body"

if [[ -n "$issue" ]]; then
  gh issue comment "$issue" --body-file "$body"
else
  gh issue create --title "$title" --body-file "$body" --assignee "$GITHUB_REPOSITORY_OWNER"
fi
