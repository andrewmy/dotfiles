#!/usr/bin/env bash
# Claude Code status line script

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "unknown"')
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
session_name=$(echo "$input" | jq -r '.session_name // empty')

# Rate-limit usage from statusline input (Claude.ai subscribers only; absent on enterprise/usage-billed accounts)
usage_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
usage_wk=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Shorten home directory to ~
home="$HOME"
short_cwd="${cwd/#$home/\~}"

# Color picker for usage percentages
usage_color() {
  local val_int=${1%.*}
  if [ "$val_int" -ge 80 ] 2>/dev/null; then
    echo '\033[31m'
  elif [ "$val_int" -ge 50 ] 2>/dev/null; then
    echo '\033[33m'
  else
    echo '\033[32m'
  fi
}

# Build the status line segments
parts=()

# Directory
parts+=("$(printf '\033[34m%s\033[0m' "$short_cwd")")

# Session name (if set)
if [ -n "$session_name" ]; then
  parts+=("$(printf '\033[35m[%s]\033[0m' "$session_name")")
fi

# Model name
parts+=("$(printf '\033[36m%s\033[0m' "$model")")

# Context window usage
if [ -n "$used_pct" ]; then
  color=$(usage_color "$used_pct")
  parts+=("$(printf "${color}ctx:%s%%\033[0m" "${used_pct%.*}")")
fi

# 5-hour rolling quota
if [ -n "$usage_5h" ]; then
  color=$(usage_color "$usage_5h")
  parts+=("$(printf "${color}5h:%s%%\033[0m" "${usage_5h%.*}")")
fi

# Weekly quota
if [ -n "$usage_wk" ]; then
  color=$(usage_color "$usage_wk")
  parts+=("$(printf "${color}wk:%s%%\033[0m" "${usage_wk%.*}")")
fi

# Session cost
if [ -n "$cost_usd" ]; then
  cost_formatted=$(printf '%.2f' "$cost_usd")
  parts+=("$(printf '\033[33m$%s\033[0m' "$cost_formatted")")
fi

# Vim mode
if [ -n "$vim_mode" ]; then
  parts+=("$(printf '\033[33m[%s]\033[0m' "$vim_mode")")
fi

# Join with separator
result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="$result $(printf '\033[2m|\033[0m') $part"
  fi
done

printf '%s\n' "$result"
