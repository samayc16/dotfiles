#!/usr/bin/env bash
# tmux cheatsheet shown in a floating popup (prefix + ?)
#
# Must fit the popup's 36 inner rows (display-popup -h 38): keep it at 35 lines.
# Padding is done by character count, not printf's byte count, so keys like
# "M-←/→" stay aligned.

# ${#var} must count characters, not bytes
case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
    *UTF-8*|*utf8*|*UTF8*) ;;
    *)  # C.UTF-8 exists on modern Linux; macOS ships en_US.UTF-8
        if [ "$(uname -s)" = Darwin ]; then export LC_CTYPE=en_US.UTF-8
        else export LC_CTYPE=C.UTF-8; fi 2>/dev/null ;;
esac

# Monokai Pro palette
G=$'\033[38;2;169;220;118m'   # green
P=$'\033[38;2;255;97;136m'    # pink
Y=$'\033[38;2;255;216;102m'   # yellow
B=$'\033[38;2;120;220;232m'   # blue
V=$'\033[38;2;171;157;242m'   # violet
O=$'\033[38;2;252;152;103m'   # orange
A=$'\033[38;2;114;112;114m'   # gray
D=$'\033[38;2;91;89;92m'      # dim rule
W=$'\033[38;2;252;252;250m'   # white
BOLD=$'\033[1m'
R=$'\033[0m'

WIDTH=70        # content width inside the 3-col margin
LCOL=38         # left column width (key + desc)
LKEY=6          # left key cell
RKEY=10         # right key cell

# pad <text> <width>: text followed by spaces up to width (counts characters)
pad() {
    local n=$(( $2 - ${#1} ))
    (( n < 0 )) && n=0
    printf '%s%*s' "$1" "$n" ''
}

# rule <width>: a dim horizontal line
rule() {
    local s="" i
    for ((i = 0; i < $1; i++)); do s+="─"; done
    printf '%s' "$s"
}

# row  lcolor lkey ldesc  rcolor rkey rdesc
row() {
    printf '   %s%s%s%s' "$1" "$(pad "$2" "$LKEY")" "$R" "$(pad "$3" $((LCOL - LKEY)))"
    printf '%s%s%s%s\n' "$4" "$(pad "$5" "$RKEY")" "$R" "$6"
}

# section  lcolor ltitle  rcolor rtitle  →  "TITLE ────────   TITLE ────────"
section() {
    local lt="$2" rt="$4"
    printf '   %s%s%s %s%s%s' "$1" "$BOLD" "$lt" "$D" "$(rule $((LCOL - ${#lt} - 3)))" "$R"
    printf '  %s%s%s %s%s%s\n' "$3" "$BOLD" "$rt" "$D" "$(rule $((WIDTH - LCOL - ${#rt} - 3)))" "$R"
}

clear
printf '   %s%s%s%s%sprefix %s%sC-a%s %s·%s %sC-b%s\n' \
    "$BOLD" "$W" "TMUX · KEYBINDINGS" "$R" "$(pad '' $((WIDTH - 18 - 16)))" "$R" "$Y" "$R" "$A" "$R" "$Y" "$R"
printf '   %s%s%s\n' "$A" "$(rule "$WIDTH")" "$R"
echo ""

section "$P" "PREFIX"                          "$B" "NO PREFIX"
row "$Y" "?"    "help"                         "$O" "C-hjkl"    "navigate panes"
row "$Y" "r"    "reload config"                "$O" "M-hl"      "prev / next window"
row "$Y" "d"    "detach"                       "$O" "M-jk"      "prev / next session"
row "$Y" "m"    "toggle mouse"                 "$O" "M-1..0"    "select window"
row "$Y" "S"    "sync panes"                   "$O" "M-←/→"     "word back / fwd"
row "$Y" "C-l"  "clear history"                "$O" "M-HJKL"    "resize pane"
row "$Y" "P"    "focus timer start / stop"     "$O" "M-p  M-n"  "music play / next"
echo ""

section "$Y" "WINDOWS"                         "$G" "PANES"
row "$Y" "c"    "new window"                   "$G" "\" -"      "split stacked"
row "$Y" ","    "rename"                       "$G" "% _"       "split side-by-side"
row "$Y" "."    "move"                         "$G" "x  X"      "kill pane / window"
row "$Y" "> <"  "swap right / left"            "$G" "z"         "zoom toggle"
row "$Y" "Tab"  "last window"                  "$G" "Space"     "cycle layouts"
row "$Y" "q"    "show pane numbers"            "$G" "C-o/M-o"   "rotate fwd / back"
row ""   ""     ""                             "$G" "=  |"      "balance h / v"
echo ""

section "$V" "SESSIONS"                        "$O" "COPY MODE"
row "$Y" "T"    "sesh: pick project / session" "$V" "["         "enter copy mode"
row "$Y" "s"    "list"                         "$V" "v"         "begin selection"
row "$Y" "F"    "fzf sessions/windows/panes"   "$V" "C-v"       "rectangle toggle"
row "$Y" "\$"   "rename"                       "$V" "y"         "copy & exit"
row "$Y" "( )"  "prev / next"                  "$V" "Esc"       "cancel"
row "$Y" "A"    "alternate (last) session"     ""   ""          ""
row "$Y" "C-c"  "new session"                  ""   ""          ""
row "$Y" "C-f"  "find session"                 ""   ""          ""
row "$Y" "g"    "goto session (prompt)"        ""   ""          ""
row "$Y" "C-x"  "kill session"                 ""   ""          ""
echo ""

printf '   %s%s%s\n' "$A" "$(rule "$WIDTH")" "$R"
printf '   %s%s%s' "$A" "$(pad '' 23)press any key to close" "$R"
