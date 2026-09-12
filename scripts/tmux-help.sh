#!/usr/bin/env bash
# tmux cheatsheet displayed in a floating popup (two-column layout)

readonly BLD=$'\033[1m'
readonly DIM=$'\033[2m'
readonly RST=$'\033[0m'
readonly GRN=$'\033[38;2;169;220;118m'  # #a9dc76
readonly PNK=$'\033[38;2;255;97;136m'   # #ff6188
readonly YLW=$'\033[38;2;255;216;102m'  # #ffd866
readonly CYN=$'\033[38;2;120;220;232m'  # #78dce8
readonly VLT=$'\033[38;2;171;157;242m'  # #ab9df2
readonly ORG=$'\033[38;2;252;152;103m'  # #fc9867
readonly WHT=$'\033[38;2;252;252;250m'  # #fcfcfa
readonly GRY=$'\033[38;2;114;112;114m'  # #727072

readonly C2=49  # absolute column where the right side starts

header2() {
    printf "  ${1}${BLD}%s${RST}" "$2"
    printf "\033[${C2}G  ${3}${BLD}%s${RST}\n" "$4"
}

sep2() {
    local s
    s=$(printf '%.0s─' {1..40})
    printf "  ${GRY}%s${RST}" "$s"
    printf "\033[${C2}G  ${GRY}%s${RST}\n" "$s"
}

row2() {
    if [[ -n "$1" ]]; then
        printf "  ${YLW}%-22s${RST}${GRY}│${RST} ${WHT}%s${RST}" "$1" "$2"
    fi
    if [[ -n "$3" ]]; then
        printf "\033[${C2}G  ${YLW}%-18s${RST}${GRY}│${RST} ${WHT}%s${RST}" "$3" "$4"
    fi
    printf "\n"
}

clear
printf "\n"
printf "  ${GRN}${BLD}  tmux cheatsheet${RST}   ${DIM}${GRY}(prefix = C-a)${RST}\n"
printf "  ${GRY}%s${RST}\n" "$(printf '%.0s━' {1..86})"

printf "\n"
header2 "$PNK" " No prefix"            "$CYN" " Windows"
sep2
row2 "C-h / C-j / C-k / C-l" "Pane ← ↓ ↑ →"       "prefix c" "New window (cwd)"
row2 "M-h / M-l" "Prev / next window"                 "prefix ," "Rename window"
row2 "M-j / M-k" "Next / prev session"                "prefix ." "Move window to index"
row2 "M-1 … M-0" "Window 1–10"                        "prefix < / >" "Swap left / right"
row2 "M-H/J/K/L" "Resize pane"                        "prefix Tab" "Last window"
row2 "" ""                                             "prefix X" "Kill window"

printf "\n"
header2 "$GRN" " Panes"               "$VLT" " Sessions"
sep2
row2 "prefix |" "Split side-by-side"                   "prefix s" "Session picker"
row2 "prefix -" "Split stacked"                        "prefix F" "fzf sessions/windows"
row2 "prefix z" "Zoom toggle"                          "prefix C-c" "New session"
row2 "prefix H/J/K/L" "Resize (repeatable)"            "prefix C-f" "Find session by name"
row2 "prefix Space" "Cycle layouts"                    "prefix \$" "Rename session"
row2 "prefix = / +" "Balance layouts"   "prefix C-x" "Kill session"
row2 "prefix x" "Kill pane"                            "prefix d" "Detach"

printf "\n"
header2 "$ORG" " Copy mode  (vi)"     "$YLW" " Toggles & misc"
sep2
row2 "prefix [" "Enter copy mode"                      "prefix m" "Toggle mouse"
row2 "v / C-v" "Select / rectangle"                    "prefix S" "Sync panes"
row2 "y" "Yank selection"                               "prefix C-l" "Clear screen + history"
row2 "Escape" "Cancel"                                  "prefix r" "Reload config"
row2 "" ""                                              "prefix ?" "This help"

printf "\n  ${DIM}${GRY}Press any key to close${RST}\n\n"

read -rsn1 _
