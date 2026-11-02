#!/usr/bin/env bash
# Checks the my-language mod's packs and manifest: every output style's front matter (I5), and that the
# mod validates and hooks only session.start and command.run (I4).
# Usage: bash mods/my-language/scripts/packs.test.sh [mod folder]  (default: this script's mod)
set -uo pipefail

mod="$(cd "${1:-$(dirname "$0")/..}" && pwd)"
fail=0
bad() { echo "FAIL: $*" >&2; fail=1; }

# The front matter of a markdown file: the lines between its first two `---` lines.
front() { awk 'NR == 1 && $0 != "---" { exit } NR > 1 && $0 == "---" { exit } NR > 1 { print }' "$1"; }
# The value of one front matter key, quotes and surrounding spaces removed.
field() { front "$1" | sed -n "s/^$2:[[:space:]]*//p" | head -1 | sed -e 's/[[:space:]]*$//' -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'\$/\1/"; }

styles=("$mod"/output-styles/*.md)
[[ -e "${styles[0]}" ]] || bad "no style in $mod/output-styles"

for f in "${styles[@]}"; do
  [[ -e "$f" ]] || continue
  stem="$(basename "$f" .md)"
  # A name that differs from the file stem would select the Default style silently.
  [[ "$(field "$f" name)" == "$stem" ]] || bad "$stem.md: front matter name is not \"$stem\""
  [[ -n "$(field "$f" description)" ]] || bad "$stem.md: no description"
  [[ "$(field "$f" keep-coding-instructions)" == "true" ]] || bad "$stem.md: keep-coding-instructions is not true"
  front "$f" | grep -q '^force-for-plugin:' && bad "$stem.md: sets force-for-plugin"
done

# I4: the mod validates, and its hooks are only session.start and command.run (no prompt event).
out="$(claude plugin validate "$mod" --strict 2>&1)" || bad "claude plugin validate --strict failed:"$'\n'"$out"
# One line per hooks module: "❯ ./register.ts hooks: session.start, command.run{command=language}".
hooks="$(sed -n 's/^[[:space:]]*❯ [^[:space:]]* hooks: //p' <<<"$out")"
if [[ -z "$hooks" ]]; then
  bad "validate printed no hooks line"
else
  events="$(sed 's/{[^}]*}//g' <<<"$hooks" | tr ',\n' '\n\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | sort -u)"
  others="$(grep -v -x -e session.start -e command.run <<<"$events")"
  [[ -z "$others" ]] || bad "the mod hooks more than session.start and command.run: $(paste -sd ' ' - <<<"$others")"
fi

[[ $fail -eq 0 ]] && echo "packs.test.sh: OK"
exit $fail
