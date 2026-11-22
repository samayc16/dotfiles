#!/usr/bin/env bash
# Level 24 · Hotfix the config
# Task: README.md · run: bash solution.sh · check: learn check
# Edit ./services.conf in place (the checker gives you a fresh copy).
DATA=${LEARN_EXERCISE_DIR:-~/dotfiles/learn/tracks/shell/data}/../data
export LC_ALL=C

sed -i.bak '/^\[web\]/,/^$/{s/^port = .*/port = 8080/;s/^debug = .*/debug = true/;}' services.conf && rm services.conf.bak
