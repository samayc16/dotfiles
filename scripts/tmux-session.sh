#!/usr/bin/env bash
# Session helpers for tmux popups (prefix C / prefix g).
#
#   tmux-session.sh new <name>   create the session (in the current pane's dir)
#                                unless it exists, then switch to it
#   tmux-session.sh goto         pick a session and switch to it
#
# Run from inside a popup: the client and directory are looked up from tmux
# (display-popup doesn't expand formats in its command). `goto` uses fzf when
# available, otherwise lists sessions and reads a name (prefixes match).

set -u

client=$(tmux display-message -p '#{client_name}')

new_session() {
  local name=$1 dir
  dir=$(tmux display-message -p '#{pane_current_path}')
  if ! tmux has-session -t "=$name" 2>/dev/null; then
    tmux new-session -d -s "$name" -c "$dir" || exit 1
  fi
  tmux switch-client -c "$client" -t "=$name"
}

goto_session() {
  local pick
  if command -v fzf >/dev/null 2>&1; then
    pick=$(tmux list-sessions -F '#{session_name}' |
      fzf --reverse --no-info --prompt='› ' --pointer='●' \
        --color='bg+:#403e41,fg+:#fcfcfa,hl:#ffd866,hl+:#ffd866,prompt:#ab9df2,pointer:#ff6188,gutter:-1') || exit 0
  else
    tmux list-sessions -F '  #{session_name}  (#{session_windows} windows)'
    printf '\n› '
    IFS= read -r pick || exit 0
  fi
  [ -n "$pick" ] && tmux switch-client -c "$client" -t "$pick"
}

case "${1:-}" in
  new)  [ -n "${2:-}" ] && new_session "$2" ;;
  goto) goto_session ;;
  *)    echo "usage: tmux-session.sh new <name> | goto" >&2; exit 2 ;;
esac
