#!/usr/bin/env bash
# One-line input for tmux popups (rename window/session, move window, …).
#
#   tmux-prompt.sh <label> <initial> <command…>
#
# Shows "<label> › <initial>" with the initial text editable in place.
# <initial> and the command words may contain tmux formats ('#{window_name}',
# '#{window_id}', …): display-popup does not expand formats in its command, so
# they're expanded here, against the client/pane the popup was opened from.
#   Enter        runs  <command…> "<value>"   (errors are shown via tmux)
#   Esc / ^C     cancels; so does an empty value or an unchanged one
#
# Line editing, best available first:
#   zsh vared (macOS default shell; prefill + Esc-to-cancel) →
#   bash ≥ 4 `read -e -i` (prefill, ^C cancels) →
#   plain `read` (bash 3.2 without zsh: empty input keeps the old value).

set -u

PURPLE=$'\033[38;2;171;157;242m'
GRAY=$'\033[38;2;114;112;114m'
RESET=$'\033[0m'

read_zsh() {
  # Editing display goes to the tty; the result comes back on fd 3.
  # Colour codes are wrapped in %{ %} so zle counts them as zero-width.
  zsh -f -c '
    KEYTIMEOUT=1
    bindkey -e
    bindkey "^[" send-break
    v=$3
    vared -p "%{$1%}${2//\%/%%} %{$4%}›%{$5%} " v || exit 1
    print -r -- "$v" >&3
  ' zsh "$PURPLE" "$1" "$2" "$GRAY" "$RESET" 3>&1 1>/dev/tty
}

read_bash4() {
  local v
  # \001 … \002 tell readline the colour codes take no columns
  local o=$'\001' c=$'\002'
  read -e -r -i "$2" -p "$o$PURPLE$c$1 $o$GRAY$c›$o$RESET$c " v || return 1
  printf '%s\n' "$v"
}

read_plain() {
  local v
  [ -n "$2" ] && printf '%s(currently: %s — Enter keeps it)%s\n' "$GRAY" "$2" "$RESET" >/dev/tty
  printf '%s%s %s›%s ' "$PURPLE" "$1" "$GRAY" "$RESET" >/dev/tty
  IFS= read -r v || return 1
  printf '%s\n' "${v:-$2}"
}

read_line() {
  if command -v zsh >/dev/null 2>&1; then
    read_zsh "$@"
  elif [ "${BASH_VERSINFO[0]:-0}" -ge 4 ]; then
    read_bash4 "$@"
  else
    read_plain "$@"
  fi
}

# expand tmux formats in one word (only when it contains "#{")
expand() {
  case $1 in
    *'#{'*) tmux display-message -p -- "$1" ;;
    *)      printf '%s\n' "$1" ;;
  esac
}

main() {
  if [ "$#" -lt 3 ]; then
    echo "usage: tmux-prompt.sh <label> <initial> <command…>" >&2
    exit 2
  fi
  local label=$1 initial value out arg
  local -a cmd=()
  initial=$(expand "$2")
  shift 2
  for arg in "$@"; do cmd+=("$(expand "$arg")"); done

  trap 'exit 0' INT
  value=$(read_line "$label" "$initial") || exit 0
  [ -z "$value" ] && exit 0
  [ -n "$initial" ] && [ "$value" = "$initial" ] && exit 0

  if ! out=$("${cmd[@]}" "$value" 2>&1); then
    tmux display-message "${out:-command failed}" 2>/dev/null
  fi
}

main "$@"
