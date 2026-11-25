#!/bin/sh
# Focus timer for the tmux status bar (prefix + P toggles it).
#
#   focus.sh toggle [MINUTES]   start a block, or stop the running one early
#   focus.sh start [MINUTES]    start (or restart) a block
#   focus.sh stop               stop early
#   focus.sh status             the status-right segment, e.g. "◔ focus 32m"; ends a block that's up
#
# MINUTES: the argument (tmux.conf passes the @focus-minutes option), else $FOCUS_MINUTES, else 50.
# When a block ends: a tmux message on every client, plus a desktop notification (osascript on
# macOS, notify-send on Linux) where one is available, silently nothing otherwise.
#
# State is one line, "END_EPOCH MINUTES", in $XDG_STATE_HOME/dotfiles/focus. `status` runs every
# status-interval, so with no block running it is a single file test; while one runs, it reads the
# file and the clock (one `date`). FOCUS_NOW (epoch seconds) stands in for the clock in tests.
set -u

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/focus"
DEFAULT_MINUTES=50
MAX_MINUTES=1440

now() {
  if [ -n "${FOCUS_NOW:-}" ]; then echo "$FOCUS_NOW"; else date +%s; fi
}

is_count() {
  case "$1" in '' | *[!0-9]*) return 1 ;; esac
  [ "$1" -ge 1 ] && [ "$1" -le "$MAX_MINUTES" ]
}

# Tell every attached client; outside tmux there is no one to tell.
say() {
  [ -n "${TMUX:-}" ] || return 0
  tmux list-clients -F '#{client_name}' 2>/dev/null | while IFS= read -r client; do
    tmux display-message -c "$client" -d "$1" "$2" 2>/dev/null
  done
  return 0
}

desktop_notify() {
  if command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"$2\" with title \"$1\" sound name \"Glass\"" >/dev/null 2>&1
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "$1" "$2" >/dev/null 2>&1
  fi
  return 0
}

redraw() {
  [ -n "${TMUX:-}" ] && tmux refresh-client -S 2>/dev/null
  return 0
}

# Sets END and MINUTES from the state file; fails when there is no valid block.
load() {
  [ -f "$STATE" ] || return 1
  read -r END MINUTES _ <"$STATE" || [ -n "${END:-}" ] || return 1
  case "$END" in '' | *[!0-9]*) return 1 ;; esac
  is_count "$MINUTES"
}

# Several clients' status lines can notice the end at once: only the one whose mv wins announces it.
finish() {
  mv "$STATE" "$STATE.$$" 2>/dev/null || return 0
  rm -f "$STATE.$$"
  say 0 "Focus done: ${MINUTES}m. Take a break."
  desktop_notify "Focus done" "${MINUTES} minutes are up. Take a break."
}

start() {
  minutes="${1:-${FOCUS_MINUTES:-$DEFAULT_MINUTES}}"
  if ! is_count "$minutes"; then
    echo "focus: minutes must be a whole number from 1 to $MAX_MINUTES, not '$minutes'" >&2
    say 3000 "focus: minutes must be 1-$MAX_MINUTES, not '$minutes'"
    return 2
  fi
  mkdir -p "${STATE%/*}" || return 1
  echo "$(($(now) + minutes * 60)) $minutes" >"$STATE.$$" && mv -f "$STATE.$$" "$STATE" || return 1
  say 2000 "Focus: ${minutes}m. prefix + P again to stop."
  redraw
}

stop() {
  load || { rm -f "$STATE"; return 0; }
  rm -f "$STATE"
  elapsed=$(((MINUTES * 60 - (END - $(now))) / 60))
  [ "$elapsed" -ge 0 ] || elapsed=0
  say 2000 "Focus stopped after ${elapsed}m."
  redraw
}

toggle() {
  if load && [ "$END" -gt "$(now)" ]; then
    stop
  else
    rm -f "$STATE"
    start "$@"
  fi
}

status() {
  [ -f "$STATE" ] || return 0
  if ! load; then
    rm -f "$STATE"
    return 0
  fi
  left=$((END - $(now)))
  if [ "$left" -le 0 ]; then
    finish
    return 0
  fi
  total=$((MINUTES * 60))
  case $(((total - left) * 4 / total)) in
    0) glyph='○' ;;
    1) glyph='◔' ;;
    2) glyph='◑' ;;
    *) glyph='◕' ;;
  esac
  printf '%s focus %dm  ' "$glyph" $(((left + 59) / 60))
}

case "${1:-}" in
  toggle | start)
    cmd="$1"
    shift
    # tmux passes an unset @focus-minutes as an empty argument: that means "the default"
    if [ -n "${1:-}" ]; then "$cmd" "$1"; else "$cmd"; fi
    ;;
  stop | status) "$1" ;;
  *)
    sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//' >&2
    exit 2
    ;;
esac
