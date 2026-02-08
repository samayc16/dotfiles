#!/bin/bash
# Cached weather for tmux status bar - updates every 30 minutes
CACHE="$HOME/.cache/tmux-weather"
mkdir -p "$(dirname "$CACHE")"

# Refresh if cache is older than 30 minutes or doesn't exist
if [ ! -f "$CACHE" ] || [ "$(find "$CACHE" -mmin +30 2>/dev/null)" ]; then
  raw=$(curl -s --max-time 3 "wttr.in/?format=%C|%t" 2>/dev/null)
  if [ -n "$raw" ] && ! echo "$raw" | grep -q "Unknown"; then
    condition=$(echo "$raw" | cut -d'|' -f1 | tr '[:upper:]' '[:lower:]')
    temp=$(echo "$raw" | cut -d'|' -f2 | tr -d '+' | sed 's/^ *//')

    # Map condition to Nerd Font weather icon
    case "$condition" in
      *thunder*)  icon="" ;;
      *snow*|*blizzard*|*sleet*|*ice*)  icon="" ;;
      *heavy*rain*|*pour*)  icon="" ;;
      *rain*|*drizzle*|*shower*)  icon="" ;;
      *fog*|*mist*|*haze*)  icon="" ;;
      *overcast*)  icon="" ;;
      *cloud*|*partly*)  icon="" ;;
      *clear*|*sunny*)  icon="" ;;
      *)  icon="" ;;
    esac

    echo "$icon $temp" > "$CACHE"
  fi
fi

cat "$CACHE" 2>/dev/null || echo ""
