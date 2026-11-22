#!/usr/bin/env bash
# Claude Code status line — Monokai Pro truecolor, single line.
#
#   Opus 4.7 │ effort high │ ~/repo/src │  main │ ctx 32% │ 5h 3% · in 4h 34m │ 7d 22% │ $26.58 │ +142 -37
#
# Segments auto-hide when their data is absent. All JSON fields are pulled in
# one jq pass (the status line re-runs on every turn, so subprocess count matters).

# Portable across macOS/Linux: only bash, jq, git, date +%s. Numbers are
# formatted with printf, so pin the decimal separator (de_DE etc. use ",").
# (LC_ALL would override it, so fold LC_ALL into LC_CTYPE first.)
if [ -n "${LC_ALL:-}" ]; then export LC_CTYPE="$LC_ALL"; unset LC_ALL; fi
export LC_NUMERIC=C
command -v jq >/dev/null 2>&1 || exit 0   # no jq (minimal box): show nothing

input=$(cat)

{
  IFS= read -r model_raw
  IFS= read -r effort
  IFS= read -r cwd
  IFS= read -r used_pct
  IFS= read -r five_h_pct
  IFS= read -r five_h_reset
  IFS= read -r seven_d_pct
  IFS= read -r total_cost
  IFS= read -r lines_added
  IFS= read -r lines_removed
} < <(printf '%s' "$input" | jq -r '
  (.model.display_name // ""),
  (.effort.level // ""),
  (.workspace.current_dir // .cwd // ""),
  (.context_window.used_percentage // ""),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  (.cost.total_cost_usd // ""),
  (.cost.total_lines_added // 0),
  (.cost.total_lines_removed // 0)
')

# ── Monokai Pro palette ─────────────────────────────────────────────
readonly RESET=$'\033[0m'
readonly BOLD=$'\033[1m'
readonly PINK=$'\033[38;2;255;97;136m'     # #ff6188
readonly BLUE=$'\033[38;2;120;220;232m'    # #78dce8
readonly YELLOW=$'\033[38;2;255;216;102m'  # #ffd866
readonly GREEN=$'\033[38;2;169;220;118m'   # #a9dc76
readonly ORANGE=$'\033[38;2;252;152;103m'  # #fc9867
readonly PURPLE=$'\033[38;2;171;157;242m'  # #ab9df2
readonly GREY=$'\033[2;38;2;114;112;114m'  # #727072 dim

readonly SEP="${GREY} │ ${RESET}"

parts=()
add() { parts+=("$1"); }

# Seconds-until → "Xd Yh" / "Xh Ym" / "Ym" / "now"
fmt_relative() {
  local target=$1
  [[ -z "$target" || "$target" == "null" ]] && return 1
  local now delta d h m
  now=$(date +%s)
  delta=$(( target - now ))
  if (( delta <= 0 )); then printf 'now'; return 0; fi
  if (( delta >= 86400 )); then
    d=$(( delta / 86400 )); h=$(( (delta % 86400) / 3600 ))
    printf '%dd %dh' "$d" "$h"
  elif (( delta >= 3600 )); then
    h=$(( delta / 3600 )); m=$(( (delta % 3600) / 60 ))
    printf '%dh %dm' "$h" "$m"
  else
    m=$(( (delta + 59) / 60 ))
    printf '%dm' "$m"
  fi
}

# 1. Model — strip leading "Claude "
if [[ -n "$model_raw" ]]; then
  add "${BOLD}${PINK}${model_raw#Claude }${RESET}"
fi

# 2. Reasoning effort — color by level
if [[ -n "$effort" ]]; then
  case "$effort" in
    low)    effort_color="$YELLOW" ;;
    medium) effort_color="$ORANGE" ;;
    high)   effort_color="$GREEN"  ;;
    xhigh)  effort_color="$PINK"   ;;
    max)    effort_color="$BLUE"   ;;
    *)      effort_color="$GREY"   ;;
  esac
  add "${effort_color}effort ${effort}${RESET}"
fi

# 3. Directory — ~-relative, bold leaf (mirrors p10k anchor bold)
if [[ -n "$cwd" ]]; then
  home="${HOME%/}"
  dir="$cwd"
  [[ "$cwd" == "$home" || "$cwd" == "$home/"* ]] && dir="~${cwd#"$home"}"
  if [[ "$dir" == */* ]]; then
    add "${BLUE}${dir%/*}/${BOLD}${dir##*/}${RESET}"
  else
    add "${BOLD}${BLUE}${dir}${RESET}"
  fi
fi

# 4. Git branch — Nerd Font  (U+E0A0)
if [[ -n "$cwd" ]]; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  [[ -n "$branch" ]] && add "${YELLOW} ${branch}${RESET}"
fi

# 5. Context % — green → yellow → orange → pink
if [[ -n "$used_pct" ]]; then
  pct_int=$(printf '%.0f' "$used_pct")
  if   (( pct_int >= 95 )); then ctx_color="$PINK"
  elif (( pct_int >= 80 )); then ctx_color="$ORANGE"
  elif (( pct_int >= 50 )); then ctx_color="$YELLOW"
  else                            ctx_color="$GREEN"
  fi
  add "${ctx_color}ctx ${pct_int}%${RESET}"
fi

# 6. 5-hour rate limit + reset countdown
if [[ -n "$five_h_pct" ]]; then
  fh_int=$(printf '%.0f' "$five_h_pct")
  if fh_rel=$(fmt_relative "$five_h_reset"); then
    add "${PURPLE}5h ${fh_int}% · in ${fh_rel}${RESET}"
  else
    add "${PURPLE}5h ${fh_int}%${RESET}"
  fi
fi

# 7. 7-day rate limit
if [[ -n "$seven_d_pct" ]]; then
  add "${PINK}7d $(printf '%.0f' "$seven_d_pct")%${RESET}"
fi

# 8. Session cost — hidden until non-zero
if [[ -n "$total_cost" ]]; then
  cost_fmt=$(printf '%.2f' "$total_cost" 2>/dev/null)
  [[ -n "$cost_fmt" && "$cost_fmt" != "0.00" ]] && add "${BOLD}${ORANGE}\$${cost_fmt}${RESET}"
fi

# 9. Diff stats — hidden when both zero
if [[ "${lines_added:-0}" != "0" || "${lines_removed:-0}" != "0" ]]; then
  add "${GREEN}+${lines_added}${RESET} ${PINK}-${lines_removed}${RESET}"
fi

# ── Join and print ──────────────────────────────────────────────────
(( ${#parts[@]} == 0 )) && exit 0

out="${parts[0]}"
for (( i=1; i<${#parts[@]}; i++ )); do
  out+="${SEP}${parts[$i]}"
done
printf '%b' "$out"
