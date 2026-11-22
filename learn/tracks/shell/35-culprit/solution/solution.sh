#!/usr/bin/env bash
# Level 35 · Final boss: find the culprit
# Task: README.md · run: bash solution.sh · check: learn check
# Inputs are in $DATA, e.g. "$DATA/app.log". Print the answer to stdout.
DATA=${LEARN_EXERCISE_DIR:-~/dotfiles/learn/tracks/shell/data}/../data
export LC_ALL=C

id=$(grep ERROR "$DATA/app.log" | grep -o 'user=u[0-9]*' | sort | uniq -c | sort -rn | head -1 | cut -d= -f2)
grep "^$id," "$DATA/users.csv" | cut -d, -f2,3
