#!/usr/bin/env bash
# Refresh /tmp/claude-monthly-cost.json using ccusage. Called in background from statusline.
set -u

command -v ccusage >/dev/null 2>&1 || exit 0

out="/tmp/claude-monthly-cost.json"
lock_dir="/tmp/claude-monthly-cost.lock"

# Single-writer lock via atomic mkdir (portable; macOS has no flock).
# Losing the race is fine — someone else is refreshing.
mkdir "$lock_dir" 2>/dev/null || exit 0
trap 'rmdir "$lock_dir" 2>/dev/null' EXIT

month=$(date +%Y-%m)
cost=$(ccusage monthly --json --offline 2>/dev/null \
  | jq -r --arg m "$month" '.monthly[] | select(.month == $m) | .totalCost' 2>/dev/null)
[ -z "$cost" ] && cost=0

printf '{"cost_usd":%s,"month":"%s","updated_at":%s}\n' "$cost" "$month" "$(date +%s)" > "${out}.tmp"
mv "${out}.tmp" "$out"
