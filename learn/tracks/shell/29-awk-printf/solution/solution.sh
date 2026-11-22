#!/usr/bin/env bash
# Level 29 · A report your manager can read
# Task: README.md · run: bash solution.sh · check: learn check
# Inputs are in $DATA, e.g. "$DATA/app.log". Print the answer to stdout.
DATA=${LEARN_EXERCISE_DIR:-~/dotfiles/learn/tracks/shell/data}/../data
export LC_ALL=C

awk -F, 'NR > 1 {n[$4]++} END {
  printf "%-10s %5s\n", "TEAM", "USERS"
  for (t in n) printf "%-10s %5d\n", t, n[t] | "sort"
  close("sort")
  printf "%-10s %5d\n", "TOTAL", NR - 1
}' "$DATA/users.csv"
