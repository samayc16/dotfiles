#!/usr/bin/env bash
# Level 32 · The 15 minutes that mattered
# Task: README.md · run: bash solution.sh · check: learn check
# Inputs are in $DATA, e.g. "$DATA/app.log". Print the answer to stdout.
DATA=${LEARN_EXERCISE_DIR:-~/dotfiles/learn/tracks/shell/data}/../data
export LC_ALL=C

awk '$2 == "ERROR" && substr($1, 12, 5) >= "10:15" && substr($1, 12, 5) < "10:30" {
  split($6, p, "="); split($7, s, "="); print substr($1, 12, 8), p[2], s[2]
}' "$DATA/app.log"
