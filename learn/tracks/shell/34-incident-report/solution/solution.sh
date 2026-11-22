#!/usr/bin/env bash
# Level 34 · Boss: incident report
# Task: README.md · run: bash solution.sh · check: learn check
# Inputs are in $DATA, e.g. "$DATA/app.log". Print the answer to stdout.
DATA=${LEARN_EXERCISE_DIR:-~/dotfiles/learn/tracks/shell/data}/../data
export LC_ALL=C

awk '{split($6, p, "="); split($7, s, "="); split($8, m, "=")}
  s[2] >= 500 {n[p[2]]++; t[p[2]] += m[2]}
  END {for (k in n) if (n[k] >= 3) printf "%s %d %.1f\n", k, n[k], t[k] / n[k]}' "$DATA/app.log" | sort -k2,2nr -k1,1
