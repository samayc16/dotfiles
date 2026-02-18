#!/usr/bin/env bash
# tmux cheatsheet displayed in a floating popup (two-column layout)

readonly BLD=$'\033[1m'
readonly DIM=$'\033[2m'
readonly RST=$'\033[0m'
readonly GRN=$'\033[38;2;169;220;118m'  # #a9dc76
readonly PNK=$'\033[38;2;255;97;136m'   # #ff6188
readonly YLW=$'\033[38;2;255;216;102m'  # #ffd866
readonly CYN=$'\033[38;2;120;220;232m'  # #78dce8
readonly WHT=$'\033[38;2;252;252;250m'  # #fcfcfa
readonly GRY=$'\033[38;2;114;112;114m'  # #727072

C2=49  # absolute column where the right side starts

header2() {
    printf "  ${PNK}${BLD}%s${RST}" "$1"
    printf "\033[${C2}G  ${PNK}${BLD}%s${RST}\n" "$2"
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
header2 " Navigation" " Windows & Panes"
sep2
row2 "C-h / C-j / C-k / C-l" "Pane ← ↓ ↑ →"       "prefix |" "Split horizontal"
row2 "M-h / M-l" "Prev / next window"                 "prefix -" "Split vertical"
row2 "M-j / M-k" "Next / prev session"                "prefix c" "New window"
row2 "M-1 … M-0" "Window 1–10"                        "prefix x" "Kill pane"
row2 "" ""                                             "prefix X" "Kill window"
row2 "" ""                                             "prefix H/J/K/L" "Resize pane"

printf "\n"
header2 " Copy Mode  (vi)" " Session & Config"
sep2
row2 "prefix [" "Enter copy mode"                      "prefix d" "Detach"
row2 "v" "Begin selection"                              "prefix s" "Session picker"
row2 "y" "Yank selection"                               "prefix r" "Reload config"
row2 "Escape" "Cancel"                                  "prefix ?" "This help"

printf "\n  ${DIM}${GRY}Press q or Escape to close${RST}\n\n"

read -rsn1 _
