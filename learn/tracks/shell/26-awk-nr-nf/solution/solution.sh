#!/usr/bin/env bash
# Level 26 · Malformed metrics
# Task: README.md · run: bash solution.sh · check: learn check
# Inputs are in $DATA, e.g. "$DATA/app.log". Print the answer to stdout.
DATA=${LEARN_EXERCISE_DIR:-~/dotfiles/learn/tracks/shell/data}/../data
export LC_ALL=C

awk -F'\t' 'NF != 4 {print NR ": " $0}' "$DATA/metrics.tsv"
