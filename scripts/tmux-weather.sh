#!/bin/bash
# Cached weather for tmux status bar - updates every 30 minutes
CACHE="$HOME/.cache/tmux-weather"
mkdir -p "$(dirname "$CACHE")"

# Refresh if cache is older than 30 minutes or doesn't exist
if [ ! -f "$CACHE" ] || [ "$(find "$CACHE" -mmin +30 2>/dev/null)" ]; then
  weather=$(curl -s --max-time 3 "wttr.in/?format=%c+%t" 2>/dev/null | tr -d '+')
  if [ -n "$weather" ] && ! echo "$weather" | grep -q "Unknown"; then
    echo "$weather" > "$CACHE"
  fi
fi

cat "$CACHE" 2>/dev/null || echo ""
