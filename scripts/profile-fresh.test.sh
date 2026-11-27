#!/usr/bin/env bash
# Tests profile-fresh.sh: it compares the git blob hash each source in a profile's Sources section
# recorded with the source's blob on the repository's default branch (origin/<default>, never the
# branch's own HEAD), and prints the changed ones; a profile with no Sources section gets one recorded
# from the files that exist, with one line; --record rewrites the hashes to the current ones; without
# git it hashes the files in the folder the same way (the blob form, as `git hash-object` does).
# Usage: bash scripts/profile-fresh.test.sh
set -uo pipefail

script="$(cd "$(dirname "$0")" && pwd)/profile-fresh.sh"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
ok() { echo "ok: $1"; }
ko() { echo "FAIL: $1" >&2; fail=1; }
g() { git -c user.email=t@t -c user.name=t -c init.defaultBranch=main "$@"; }

# An origin with CLAUDE.md and a CI file, and a clone of it on a feature branch.
g init -q --bare "$tmp/origin.git"
g clone -q "$tmp/origin.git" "$tmp/seed" 2>/dev/null
mkdir -p "$tmp/seed/.github/workflows"
printf '# Rules\nUse pnpm.\n' > "$tmp/seed/CLAUDE.md"
printf 'jobs:\n  test:\n    run: npm test\n' > "$tmp/seed/.github/workflows/ci.yml"
g -C "$tmp/seed" add -A && g -C "$tmp/seed" commit -qm base && g -C "$tmp/seed" push -q origin HEAD:main 2>/dev/null
g clone -q "$tmp/origin.git" "$tmp/repo" 2>/dev/null
g -C "$tmp/repo" checkout -q -b feature
r="$tmp/repo"
h_claude="$(git -C "$r" rev-parse origin/main:CLAUDE.md)"
h_ci="$(git -C "$r" rev-parse origin/main:.github/workflows/ci.yml)"

p="$tmp/profile.md"
cat > "$p" <<EOF
# Project profile: acme/shop

## Commands

| Purpose        | Command    |
| -------------- | ---------- |
| Targeted tests | \`npm test\` |

## Sources

- \`CLAUDE.md\`: \`$h_claude\`
- \`.github/workflows/ci.yml\`: \`$h_ci\`
EOF

out="$(bash "$script" "$p" "$r" 2>&1)"; rc=$?
[[ $rc -eq 0 ]] && ok "exits 0" || ko "exit code $rc: $out"
if grep -q '^changed:' <<<"$out"; then ko "unchanged sources reported: $out"; else ok "unchanged sources are not reported"; fi

# A change on the feature branch only: the default branch is the yardstick, not the PR head.
printf 'jobs:\n  test:\n    run: pnpm vitest run\n' > "$r/.github/workflows/ci.yml"
g -C "$r" commit -qam "feature ci"
out="$(bash "$script" "$p" "$r" 2>&1)"
if grep -q 'ci.yml' <<<"$out"; then ko "a change on the branch head is reported: $out"; else ok "a change only on the PR head is not reported"; fi

# The same change on origin/main: reported, and only that source.
g -C "$r" push -q origin feature:main 2>/dev/null && g -C "$r" fetch -q origin
out="$(bash "$script" "$p" "$r" 2>&1)"
grep -q '^changed: \.github/workflows/ci\.yml' <<<"$out" && ok "a changed source hash is reported" || ko "changed source missing: $out"
if grep -q '^changed: CLAUDE.md' <<<"$out"; then ko "an unchanged source is reported with a changed one"; else ok "only the changed source is reported"; fi

# --record writes the current hashes; then nothing is reported.
bash "$script" --record "$p" "$r" > /dev/null 2>&1
grep -qF "$(git -C "$r" rev-parse origin/main:.github/workflows/ci.yml)" "$p" && ok "--record writes the new hash" || ko "--record: $(cat "$p")"
out="$(bash "$script" "$p" "$r" 2>&1)"
if grep -q '^changed:' <<<"$out"; then ko "changes reported after --record: $out"; else ok "after --record nothing is reported"; fi
grep -q 'Targeted tests' "$p" && ok "--record keeps the profile's facts" || ko "facts lost"

# A profile with no Sources section: they are recorded, with one line, and marked as older than the marks.
p2="$tmp/old-profile.md"
printf '# Project profile: acme/shop\n\n## Commands\n\n- Tests: `npm test`\n' > "$p2"
out="$(bash "$script" "$p2" "$r" 2>&1)"
[[ "$(grep -c . <<<"$out")" -eq 1 ]] && grep -qi 'recorded' <<<"$out" && ok "no Sources: one line saying they were recorded" || ko "no-Sources output: $out"
grep -q '^## Sources' "$p2" && grep -qF "\`CLAUDE.md\`: \`$h_claude\`" "$p2" && grep -q 'ci.yml' "$p2" && ok "no Sources: the section is written with each existing source" || ko "Sources not written: $(cat "$p2")"
grep -qi "yes" <(sed -n '/^## Sources/,$p' "$p2") && ok "the recorded section says unmarked facts change only with a yes" || ko "no note on unmarked facts"

# Without git (a plain folder, as in an eval sandbox): the files are hashed in the blob form.
plain="$tmp/plain"; mkdir -p "$plain/.github/workflows"
printf '# Rules\nUse pnpm.\n' > "$plain/CLAUDE.md"
printf 'jobs:\n  test:\n    run: yarn test\n' > "$plain/.github/workflows/ci.yml"
out="$(bash "$script" "$p" "$plain" 2>&1)"
grep -q '^changed: \.github/workflows/ci\.yml' <<<"$out" && ok "no git: a changed file is reported" || ko "no-git changed: $out"
if grep -q '^changed: CLAUDE.md' <<<"$out"; then ko "no git: the blob form differs from git's"; else ok "no git: the blob form matches git's hash"; fi

[[ $fail -eq 0 ]] && echo "profile-fresh.test.sh: OK" || { echo "profile-fresh.test.sh: FAILED" >&2; exit 1; }
