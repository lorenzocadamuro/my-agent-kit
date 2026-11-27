#!/usr/bin/env bash
# Reports the words of each kit file (skills/, rules/, CONSTITUTION.md) and of each skill: its SKILL.md
# plus the files its `reads` lists, which is what the skill loads before it starts.
# It only reports: a skill over --max is flagged, and the exit code stays 0 (C18).
# Usage: budget.sh [--root <kit>] [--max <words per skill>]
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"; max=10000
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) root="$(cd "$2" && pwd)"; shift 2 ;;
    --max) max="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done
cd "$root"
w() { wc -w < "$1" | tr -d ' '; }

echo "Words per file:"
{ find skills rules -type f -name '*.md' 2>/dev/null; if [[ -f CONSTITUTION.md ]]; then echo CONSTITUTION.md; fi; } | sort |
  while IFS= read -r f; do printf '%6d %s\n' "$(w "$f")" "$f"; done

echo
echo "Words per skill (SKILL.md plus its reads), budget $max:"
find skills -name SKILL.md 2>/dev/null | sort | while IFS= read -r f; do
  name="$(awk 'NR > 1 && $0 == "---" { exit } NR > 1 && /^name:/ { sub(/^name:[ \t]*/, ""); gsub(/"/, ""); print; exit }' "$f")"
  reads="$(awk 'NR > 1 && $0 == "---" { exit } NR > 1 && /^reads:/ { sub(/^reads:[ \t]*/, ""); print; exit }' "$f" |
    tr -d '[]' | tr ',' '\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v '^$' || true)"
  total="$(w "$f")"; n=0
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    if [[ -f "$p" ]]; then total=$((total + $(w "$p"))); n=$((n + 1)); else echo "  missing: $p (read by ${name:-$f})"; fi
  done <<<"$reads"
  flag=""; if [[ "$total" -gt "$max" ]]; then flag="  over $max"; fi
  printf '%6d %s (%s + %d reads)%s\n' "$total" "${name:-$f}" "$f" "$n" "$flag"
done
