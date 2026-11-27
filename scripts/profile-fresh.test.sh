#!/usr/bin/env bash
# Tests profile-fresh.sh: it compares the git blob hash each source in a profile's Sources section
# recorded with the source's blob on the repository's default branch (origin/<default>, never the
# branch's own HEAD), and prints the changed ones; a profile with no Sources section gets one recorded
# from the files that exist, with one line; --record rewrites the hashes to the current ones; without
# git it hashes the files in the folder the same way (the blob form, as `git hash-object` does); a
# removed source keeps its old hash through --record; with git but no default-branch ref it stops.
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

# A source removed on the default branch: reported as removed, and --record keeps its old hash, so the
# next run reports it again until the user updates the profile.
h_ci_now="$(git -C "$r" rev-parse origin/main:.github/workflows/ci.yml)"
p3="$tmp/p3.md"; cp "$p" "$p3"
g -C "$r" rm -q .github/workflows/ci.yml && g -C "$r" commit -qm "drop ci" && g -C "$r" push -q origin HEAD:main 2>/dev/null && g -C "$r" fetch -q origin
out="$(bash "$script" "$p3" "$r" 2>&1)"
grep -qx 'removed: \.github/workflows/ci\.yml' <<<"$out" && ok "a removed source is reported" || ko "removed source: $out"
bash "$script" --record "$p3" "$r" > /dev/null 2>&1
grep -qF "\`.github/workflows/ci.yml\`: \`$h_ci_now\`" "$p3" && ok "--record keeps a removed source's old hash" || ko "--record on a removed source: $(cat "$p3")"
out="$(bash "$script" "$p3" "$r" 2>&1)"
grep -qx 'removed: \.github/workflows/ci\.yml' <<<"$out" && ok "after --record the removed source is reported again" || ko "removed source after --record: $out"

# A new profile written from the template: --record drops the template's example line and fills a
# placeholder hash and a path-only line with the current hashes.
p4="$tmp/new-profile.md"
printf '# Project profile: acme/shop\n\n## Sources\n\nThe files this profile was built from:\n\n- `<path>`: `<git blob hash>`\n- `CLAUDE.md`: `<git blob hash>`\n' > "$p4"
bash "$script" --record "$p4" "$r" > /dev/null 2>&1
grep -qF "\`CLAUDE.md\`: \`$h_claude\`" "$p4" && ok "--record fills a placeholder hash" || ko "--record placeholder: $(cat "$p4")"
if grep -qF '<path>' "$p4"; then ko "--record keeps the template's example line: $(cat "$p4")"; else ok "--record drops the template's example line"; fi
out="$(bash "$script" "$p4" "$r" 2>&1)"
[[ -z "$out" ]] && ok "after --record a new profile reports nothing" || ko "new profile after --record: $out"
p5="$tmp/path-only.md"
printf '# Project profile: acme/shop\n\n## Sources\n\n- `CLAUDE.md`\n' > "$p5"
bash "$script" --record "$p5" "$r" > /dev/null 2>&1
grep -qxF -- "- \`CLAUDE.md\`: \`$h_claude\`" "$p5" && ok "--record fills a path-only line" || ko "--record path-only: $(cat "$p5")"
# A new profile without the section: --record writes it, without the line for a profile older than marks.
p6="$tmp/new-no-section.md"
printf '# Project profile: acme/shop\n\n## Commands\n\n- Tests: `npm test`\n' > "$p6"
bash "$script" --record "$p6" "$r" > /dev/null 2>&1
grep -q '^## Sources' "$p6" && grep -qF "\`CLAUDE.md\`: \`$h_claude\`" "$p6" && ok "--record without a section writes it" || ko "--record without a section: $(cat "$p6")"
if grep -q 'without marks' "$p6"; then ko "--record on a new profile says it is older than marks: $(cat "$p6")"; else ok "--record on a new profile has no without-marks line"; fi
grep -q 'without marks' "$p2" && ok "a plain check of an old profile writes the without-marks line" || ko "old profile without the marks line: $(cat "$p2")"

# Git but no default-branch ref (a clone whose origin refs are gone): one line on stderr, exit 2, and
# nothing compared or written.
norefs="$tmp/norefs"; g clone -q "$tmp/origin.git" "$norefs" 2>/dev/null
for ref in $(git -C "$norefs" for-each-ref --format='%(refname)' refs/remotes); do git -C "$norefs" update-ref -d "$ref"; done
printf '# Rules\nUse yarn.\n' > "$norefs/CLAUDE.md"  # differs from the recorded hash
cp "$p3" "$tmp/before.md"
err="$(bash "$script" "$p3" "$norefs" 2>&1 >/dev/null)"; rc=$?
[[ $rc -eq 2 ]] && ok "no default-branch ref: exit 2" || ko "no default-branch ref: exit $rc"
grep -q '^no default-branch ref: ' <<<"$err" && [[ "$(grep -c . <<<"$err")" -eq 1 ]] && ok "no default-branch ref: one line on stderr" || ko "no default-branch ref stderr: $err"
outn="$(bash "$script" "$p3" "$norefs" 2>/dev/null)"
[[ -z "$outn" ]] && ok "no default-branch ref: nothing compared" || ko "no default-branch ref stdout: $outn"
bash "$script" --record "$p3" "$norefs" > /dev/null 2>&1
cmp -s "$p3" "$tmp/before.md" && ok "no default-branch ref: --record writes nothing" || ko "no default-branch ref: --record changed the profile"

# Without git (a plain folder, as in an eval sandbox): the files are hashed in the blob form.
plain="$tmp/plain"; mkdir -p "$plain/.github/workflows"
printf '# Rules\nUse pnpm.\n' > "$plain/CLAUDE.md"
printf 'jobs:\n  test:\n    run: yarn test\n' > "$plain/.github/workflows/ci.yml"
out="$(bash "$script" "$p" "$plain" 2>&1)"
grep -q '^changed: \.github/workflows/ci\.yml' <<<"$out" && ok "no git: a changed file is reported" || ko "no-git changed: $out"
if grep -q '^changed: CLAUDE.md' <<<"$out"; then ko "no git: the blob form differs from git's"; else ok "no git: the blob form matches git's hash"; fi

[[ $fail -eq 0 ]] && echo "profile-fresh.test.sh: OK" || { echo "profile-fresh.test.sh: FAILED" >&2; exit 1; }
