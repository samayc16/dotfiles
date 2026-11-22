#!/usr/bin/env bash
# Level 30 · Which team spends the most?
# Task: README.md · run: bash solution.sh · check: learn check
# Inputs are in $DATA, e.g. "$DATA/app.log". Print the answer to stdout.
DATA=${LEARN_EXERCISE_DIR:-~/dotfiles/learn/tracks/shell/data}/../data
export LC_ALL=C

awk -F, 'NR == FNR {team[$1] = $4; next} $5 == "paid" && $4 == "USD" {s[team[$2]] += $3}
  END {for (t in s) printf "%s %.2f\n", t, s[t]}' "$DATA/users.csv" "$DATA/orders.csv" | sort -k2,2nr
