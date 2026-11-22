#!/usr/bin/env bash
# Level 09 · Not from around here
# Task: README.md · run: bash solution.sh · check: learn check
# Inputs are in $DATA, e.g. "$DATA/app.log". Print the answer to stdout.
DATA=${LEARN_EXERCISE_DIR:-~/dotfiles/learn/tracks/shell/data}/../data
export LC_ALL=C

grep -oE '[[:alnum:].]+@example\.(org|net)' "$DATA/users.csv"
