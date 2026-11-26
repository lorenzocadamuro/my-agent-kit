#!/usr/bin/env bash
# I9: no skill, rule or README line of the kit sets the language or the sentence form
# of text written for the user; the active output style does. Lines listed in no-form-rules.allow pass.
# Usage: bash scripts/no-form-rules.test.sh [kit folder]  (default: this script's kit)
set -uo pipefail

root="$(cd "${1:-$(dirname "$0")/..}" && pwd)"
allow="$root/scripts/no-form-rules.allow"
pattern="user's language|your language|their language|my language|in Italian|Italian:|plain words|plain line|plain phrase|plain explanation|translated and summarised|plainly|plain meaning"

cd "$root" || exit 1
paths=()
for p in skills rules README.md; do [[ -e "$p" ]] && paths+=("$p"); done
[[ ${#paths[@]} -gt 0 ]] || { echo "FAIL: no kit text under $root" >&2; exit 1; }

# The allowed lines, `<path>:<fixed text>`, comments and blank lines skipped.
entries=()
if [[ -f "$allow" ]]; then
  while IFS= read -r e; do
    [[ -z "${e// /}" || "$e" == \#* ]] && continue
    entries+=("$e")
  done < "$allow"
fi

allowed() { # <path> <line text>
  local e
  for e in ${entries[@]+"${entries[@]}"}; do
    [[ "$1" == "${e%%:*}" && "$2" == *"${e#*:}"* ]] && return 0
  done
  return 1
}

hits=0
while IFS= read -r hit; do
  [[ -z "$hit" ]] && continue
  file="${hit%%:*}"; rest="${hit#*:}"; text="${rest#*:}"
  allowed "$file" "$text" && continue
  echo "FAIL: $hit" >&2
  hits=$((hits + 1))
done < <(grep -rnIiE -- "$pattern" "${paths[@]}")

if [[ $hits -gt 0 ]]; then
  echo "no-form-rules: $hits line(s) set the language or form of text for the user (I9)" >&2
  exit 1
fi
echo "no-form-rules: OK"
