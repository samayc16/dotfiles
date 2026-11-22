#!/usr/bin/env bash
# Level 28 · Revenue by currency
# Task: README.md · run: bash solution.sh · check: learn check
# Inputs are in $DATA, e.g. "$DATA/app.log". Print the answer to stdout.
DATA=${LEARN_EXERCISE_DIR:-~/dotfiles/learn/tracks/shell/data}/../data
export LC_ALL=C

awk -F, '$5 == "paid" {s[$4] += $3} END {for (c in s) printf "%s %.2f\n", c, s[c]}' "$DATA/orders.csv" | sort
