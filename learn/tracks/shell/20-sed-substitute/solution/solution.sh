#!/usr/bin/env bash
# Level 20 · Privacy, please
# Task: README.md · run: bash solution.sh · check: learn check
# Inputs are in $DATA, e.g. "$DATA/app.log". Print the answer to stdout.
DATA=${LEARN_EXERCISE_DIR:-~/dotfiles/learn/tracks/shell/data}/../data
export LC_ALL=C

sed 's/,[^,]*@/,***@/' "$DATA/users.csv"
