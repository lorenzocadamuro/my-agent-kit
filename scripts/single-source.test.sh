#!/usr/bin/env bash
# Tests single-source.sh: it reports each sentence or line, at least --min words long, that two or more
# kit files repeat, with the files that hold it. It only reports: it exits 0 when it finds repeats.
# Usage: bash scripts/single-source.test.sh
set -uo pipefail

script="$(cd "$(dirname "$0")" && pwd)/single-source.sh"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
ok() { echo "ok: $1"; }
ko() { echo "FAIL: $1" >&2; fail=1; }

k="$tmp/kit"
mkdir -p "$k/rules" "$k/skills/plan/scope" "$k/skills/pr/review"
long="Every claim is checked against the code or the data before it shapes a decision."
short="Stop and report."
cat > "$k/rules/core.md" <<EOF
# Core

- **Verify.** $long Then go on.
- $short
EOF
cat > "$k/skills/plan/scope/SKILL.md" <<EOF
# Scope

Some own text here. ${long/Every/every}
$short
EOF
cat > "$k/skills/pr/review/SKILL.md" <<EOF
# Review

A sentence only this file has, and it is long enough to count as one.
EOF

out="$(bash "$script" --root "$k" --min 8 2>&1)"; rc=$?
[[ $rc -eq 0 ]] && ok "exits 0 with repeats (report only)" || ko "exit code $rc"
grep -qi 'every claim is checked against the code or the data' <<<"$out" && ok "a repeated sentence is reported" || ko "repeat missing: $out"
block="$(grep -i -A3 'every claim is checked' <<<"$out")"
grep -q 'rules/core.md' <<<"$block" && grep -q 'skills/plan/scope/SKILL.md' <<<"$block" && ok "the repeat names both files" || ko "files missing: $block"
if grep -q 'Stop and report' <<<"$out"; then ko "a repeat shorter than --min is reported"; else ok "a repeat shorter than --min is not reported"; fi
if grep -q 'only this file has' <<<"$out"; then ko "a sentence in one file is reported"; else ok "a sentence in one file is not reported"; fi

# The same sentence twice in one file is not a repeat across files.
printf '%s\n%s\n' "$long" "$long" > "$k/skills/pr/review/SKILL.md"
rm "$k/skills/plan/scope/SKILL.md" "$k/rules/core.md"
out="$(bash "$script" --root "$k" --min 8 2>&1)"
if grep -qi 'every claim' <<<"$out"; then ko "a repeat inside one file is reported"; else ok "a repeat inside one file is not reported"; fi

[[ $fail -eq 0 ]] && echo "single-source.test.sh: OK" || { echo "single-source.test.sh: FAILED" >&2; exit 1; }
