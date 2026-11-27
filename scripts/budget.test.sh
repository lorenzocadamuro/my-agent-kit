#!/usr/bin/env bash
# Tests budget.sh: it reports the words of each kit file and of each skill (its SKILL.md plus the files
# its `reads` lists), and flags a skill over --max. It only reports: it exits 0 even when a skill is over.
# Usage: bash scripts/budget.test.sh
set -uo pipefail

script="$(cd "$(dirname "$0")" && pwd)/budget.sh"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
ok() { echo "ok: $1"; }
ko() { echo "FAIL: $1" >&2; fail=1; }
words() { local i; for ((i = 0; i < $1; i++)); do printf 'word '; done; echo; }

k="$tmp/kit"
mkdir -p "$k/rules" "$k/skills/plan/big" "$k/skills/plan/small"
words 300 > "$k/rules/core.md"
words 50 > "$k/rules/extra.md"
skill() { # <dir> <name> <reads> <body words>
  { printf -- '---\nname: %s\ndescription: "x"\ndisable-model-invocation: true\nwhen: "x"\nreads: [%s]\n---\n\n' "$2" "$3"
    words "$4"; } > "$k/$1/SKILL.md"
}
skill skills/plan/big big "rules/core.md, rules/extra.md" 200
skill skills/plan/small small "" 40

out="$(bash "$script" --root "$k" --max 500 2>&1)"; rc=$?
[[ $rc -eq 0 ]] && ok "exits 0 with a skill over the budget (report only)" || ko "exit code $rc"

# Per file: the words of each kit file.
grep -Eq '^ *300 +rules/core\.md$' <<<"$out" && ok "per-file words of a rule" || ko "no per-file line for rules/core.md: $out"
grep -Eq '^ *2[0-9][0-9] +skills/plan/big/SKILL\.md$' <<<"$out" && ok "per-file words of a SKILL.md" || ko "no per-file line for big's SKILL.md"

# Per skill: SKILL.md plus its reads, flagged over --max; a skill under it is not flagged.
line="$(grep -E '^ *[0-9]+ +big( |$)' <<<"$out")"
n="$(awk '{ print $1 }' <<<"$line")"
[[ -n "$n" && "$n" -gt 550 && "$n" -lt 600 ]] && ok "big counts SKILL.md plus its reads ($n)" || ko "big's total is '$n': $line"
grep -q 'over 500' <<<"$line" && ok "big is flagged over the budget" || ko "big not flagged: $line"
line="$(grep -E '^ *[0-9]+ +small( |$)' <<<"$out")"
[[ -n "$line" ]] && ok "small is listed" || ko "small missing"
if grep -q 'over' <<<"$line"; then ko "small flagged under the budget: $line"; else ok "a skill under the budget is not flagged"; fi

# A missing reads path is reported, not fatal.
skill skills/plan/small small "rules/gone.md" 40
out="$(bash "$script" --root "$k" --max 500 2>&1)"; rc=$?
[[ $rc -eq 0 ]] && grep -q 'rules/gone.md' <<<"$out" && ok "a missing reads path is reported" || ko "missing reads path: rc $rc, $out"

[[ $fail -eq 0 ]] && echo "budget.test.sh: OK" || { echo "budget.test.sh: FAILED" >&2; exit 1; }
