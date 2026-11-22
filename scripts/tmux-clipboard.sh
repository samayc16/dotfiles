#!/bin/sh
# Copy stdin to the *local* system clipboard, whatever the OS. Used by
# tmux-yank (@override_copy_command) for `y` / mouse selections in copy mode.
#
# tmux already sends every copy to the outer terminal via OSC52
# (`set -s set-clipboard on`), which works over SSH. This adds the native
# clipboard where one exists, and silently does nothing where none does
# (headless boxes, SSH sessions without X/Wayland) — no error popups.
#
# Picks, in order: pbcopy (macOS) · wl-copy (Wayland) · xclip / xsel (X11)
# · clip.exe (WSL). xclip/xsel/wl-copy fork to serve the selection, so their
# output is detached or tmux's copy-pipe would wait on them.

have() { command -v "$1" >/dev/null 2>&1; }

if have pbcopy; then
  exec pbcopy
elif [ -n "${WAYLAND_DISPLAY:-}" ] && have wl-copy; then
  exec wl-copy >/dev/null 2>&1
elif [ -n "${DISPLAY:-}" ] && have xclip; then
  exec xclip -selection clipboard -in >/dev/null 2>&1
elif [ -n "${DISPLAY:-}" ] && have xsel; then
  exec xsel --clipboard --input >/dev/null 2>&1
elif have clip.exe; then
  exec clip.exe
fi

# Nothing local: drain stdin so the writer never sees EPIPE. OSC52 covers it.
cat >/dev/null
