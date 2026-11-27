#!/usr/bin/env bash
# Tests skill-overlap.sh: given a candidate skill's text, it ranks the kit's skills by the trigger words
# they share in `description` and `when`, highest first, and leaves out skills that share none.
# Usage: bash scripts/skill-overlap.test.sh
set -uo pipefail

script="$(cd "$(dirname "$0")" && pwd)/skill-overlap.sh"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
ok() { echo "ok: $1"; }
ko() { echo "FAIL: $1" >&2; fail=1; }

k="$tmp/kit"
skill() { # <dir> <name> <description> <when> [body]
  mkdir -p "$k/$1"
  printf -- '---\nname: %s\ndescription: "%s"\ndisable-model-invocation: true\nwhen: "%s"\nreads: []\n---\n\n%s\n' "$2" "$3" "$4" "${5:-}" > "$k/$1/SKILL.md"
}
skill skills/pr/sync sync "Bring the branch up to date with main safely: conflict preview, merges and pushes." "merge main, update the branch with main"
skill skills/pr/review review "Review a pull request the way a senior colleague would." "review this PR"
skill skills/improve/log log "Show the history of kit notes." "the history of kit notes" "Conflict merge branch main rebase, only in the body."

cand="$tmp/candidate.md"
printf -- '---\nname: rebase-helper\ndescription: "Update a branch with main: preview each conflict, then merge."\nwhen: "update my branch, merge main"\n---\n\nSteps.\n' > "$cand"

out="$(bash "$script" --root "$k" "$cand" 2>&1)"; rc=$?
[[ $rc -eq 0 ]] && ok "exits 0" || ko "exit code $rc: $out"
first="$(grep -m1 -E '^ *[0-9]+ ' <<<"$out")"
grep -q ' sync ' <<<"$first" && ok "the skill with the same job ranks first" || ko "first line: $first (all: $out)"
grep -q 'skills/pr/sync/SKILL.md' <<<"$first" && grep -q 'merge' <<<"$first" && ok "the line names the file and the shared words" || ko "line: $first"
if grep -qE '^ *[0-9]+ +review ' <<<"$out"; then ko "a skill with no shared trigger word is listed: $out"; else ok "a skill with no shared trigger word is left out"; fi
if grep -qE '^ *[0-9]+ +log ' <<<"$out"; then ko "words only in a skill's body counted: $out"; else ok "only description and when count, not the body"; fi

# Stdin, and a candidate with no frontmatter: its whole text counts.
out="$(printf 'A tool to review a pull request like a senior colleague.\n' | bash "$script" --root "$k" - 2>&1)"
grep -m1 -E '^ *[0-9]+ ' <<<"$out" | grep -q ' review ' && ok "stdin, no frontmatter: the whole text counts" || ko "stdin: $out"

# No overlap: says so.
out="$(printf 'Bake bread with sourdough.\n' | bash "$script" --root "$k" - 2>&1)"
grep -qi 'no overlap' <<<"$out" && ok "no shared word: 'no overlap'" || ko "no-overlap output: $out"

[[ $fail -eq 0 ]] && echo "skill-overlap.test.sh: OK" || { echo "skill-overlap.test.sh: FAILED" >&2; exit 1; }
