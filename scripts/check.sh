#!/usr/bin/env bash
# Validates the plugin and blocks employer- or person-specific words.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
deny_file="${MY_AGENT_KIT_DENY:-$HOME/.claude/my/deny-words.txt}"

claude plugin validate "$root"

if [[ -f "$deny_file" ]]; then
  pattern="$(grep -v -e '^#' -e '^[[:space:]]*$' "$deny_file" | paste -sd '|' -)"
  if [[ -n "$pattern" ]]; then
    hits="$(git -C "$root" grep -n -i -I -E "$pattern" -- . ':!scripts/check.sh' || true)"
    if [[ -n "$hits" ]]; then
      echo "Privacy check failed: these lines contain words from $deny_file" >&2
      echo "$hits" >&2
      exit 1
    fi
  fi
else
  echo "Privacy check skipped: $deny_file not found" >&2
fi

echo "check.sh: OK"
