#!/usr/bin/env bash
# tmux status segment: "<icon> <temp>  " from wttr.in, cached.
#
# Offline-safe by design (planes, trains, captive portals):
#   - fetches at most once per REFRESH_MIN, whether the fetch succeeded or not
#   - only accepts a well-formed "<condition>|<temp>" reply (rejects portal HTML / errors)
#   - prints nothing once the last good reading is older than STALE_MIN
#   - never prints errors, never blocks for more than a few seconds (tmux runs it async)
#
# Icons are Nerd Font weather glyphs written as UTF-8 byte escapes so they
# survive editors/tools that strip private-use characters (bash 3.2-safe).
# Portable: POSIX find/date/tr/grep -E only (GNU and BSD userlands).

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE="$CACHE_DIR/tmux-weather"
STAMP="$CACHE_DIR/tmux-weather.attempt"
REFRESH_MIN=30
STALE_MIN=180
URL='https://wttr.in/?format=%C|%t'

command -v curl >/dev/null 2>&1 || exit 0
mkdir -p "$CACHE_DIR" 2>/dev/null || exit 0

# true if $1 is missing or older than $2 minutes
older_than() {
  [ ! -f "$1" ] || [ -n "$(find "$1" -mmin +"$2" 2>/dev/null)" ]
}

is_night() {
  local hour
  hour=$(date +%H)
  hour=${hour#0}
  [ "${hour:-0}" -ge 19 ] || [ "${hour:-0}" -lt 6 ]
}

icon_for() {
  local cond
  cond=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  case "$cond" in
    *thunder*)                        printf '\xee\x8c\x9d' ;;  # U+E31D thunderstorm
    *snow*|*blizzard*|*sleet*|*ice*)  printf '\xee\x8c\x9a' ;;  # U+E31A snow
    *heavy*rain*|*torrential*)        printf '\xee\x8c\x98' ;;  # U+E318 rain
    *rain*|*drizzle*|*shower*)        printf '\xee\x8c\x99' ;;  # U+E319 showers
    *fog*|*mist*|*haze*)              printf '\xee\x8c\x93' ;;  # U+E313 fog
    *overcast*)                       printf '\xee\x8c\x92' ;;  # U+E312 cloudy
    *cloud*|*partly*)
      if is_night; then printf '\xee\x8d\xbe'; else printf '\xee\x8c\x82'; fi ;;  # U+E37E / U+E302
    *clear*|*sunny*)
      if is_night; then printf '\xee\x8c\xab'; else printf '\xee\x8c\x8d'; fi ;;  # U+E32B / U+E30D
    *)                                printf '\xee\x8d\x90' ;;  # U+E350 thermometer
  esac
}

fetch() {
  local raw cond temp
  raw=$(curl -fsS --connect-timeout 2 --max-time 4 "$URL" 2>/dev/null) || return 1
  printf '%s' "$raw" | grep -Eq '^[A-Za-z ,/()-]{1,48}\|[+-]?[0-9]{1,3}°[CF]$' || return 1
  cond=${raw%%|*}
  temp=${raw#*|}
  temp=${temp#+}
  printf '%s %s\n' "$(icon_for "$cond")" "$temp" > "$CACHE.tmp" && mv -f "$CACHE.tmp" "$CACHE"
}

if older_than "$STAMP" "$REFRESH_MIN" && older_than "$CACHE" "$REFRESH_MIN"; then
  touch "$STAMP" 2>/dev/null
  fetch
fi

older_than "$CACHE" "$STALE_MIN" && exit 0
printf '%s  ' "$(cat "$CACHE" 2>/dev/null)"
