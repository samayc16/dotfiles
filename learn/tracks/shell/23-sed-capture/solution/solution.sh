#!/usr/bin/env bash
# Level 23 · Dates for the Berlin office
# Task: README.md · run: bash solution.sh · check: learn check
# Inputs are in $DATA, e.g. "$DATA/app.log". Print the answer to stdout.
DATA=${LEARN_EXERCISE_DIR:-~/dotfiles/learn/tracks/shell/data}/../data
export LC_ALL=C

sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})/\3.\2.\1/' "$DATA/orders.csv"
