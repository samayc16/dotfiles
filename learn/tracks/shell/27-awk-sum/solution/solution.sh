#!/usr/bin/env bash
# Level 27 · Revenue check
# Task: README.md · run: bash solution.sh · check: learn check
# Inputs are in $DATA, e.g. "$DATA/app.log". Print the answer to stdout.
DATA=${LEARN_EXERCISE_DIR:-~/dotfiles/learn/tracks/shell/data}/../data
export LC_ALL=C

awk -F, '$5 == "paid" && $4 == "USD" {s += $3} END {printf "%.2f\n", s}' "$DATA/orders.csv"
