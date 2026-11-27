#!/usr/bin/env bash
# Tests verify-round.sh on a temp repository: a summary with a state and a real commit for every item
# passes; a missing row, an unknown state, a fake sha, a checked item without its note and a dirty tree
# fail; a round summary written from two lane summaries, with the lane commits merged by lane-merge.sh,
# passes. VERIFY_ROUND names another script to test (a stub, to see each row fail).
# Usage: bash scripts/verify-round.test.sh
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
script="${VERIFY_ROUND:-$here/verify-round.sh}"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
expect() { if [[ "$2" == "$3" ]]; then echo "ok: $1"; else echo "FAIL: $1: expected '$3', got '$2'"; sed 's/^/  /' "$tmp/out" 2>/dev/null; fail=1; fi; }
verify() { bash "$script" .plans 3 > "$tmp/out" 2>&1; echo $?; }

# A repository of its own, unaffected by the user's git configuration and by a hook's GIT_DIR.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_COMMON_DIR GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

git init -q -b main "$tmp/repo"
cd "$tmp/repo" || exit 1
echo '.plans/' >> .git/info/exclude  # as in a worktree, where .plans/ is git-ignored
printf 'base\n' > a.txt && git add . && git commit -q -m base
git checkout -q -b feature
mkdir .plans
printf '# Round 3\n\n## Items\n\n### 1. Parse dates\n\n### 2. Add docs\n\n### 3. Check the suite\n' > .plans/round-3.md
printf 'one\n' > a.txt && git commit -q -am "Round 3 item 1"; c1="$(git rev-parse --short HEAD)"
printf 'docs\n' > b.txt && git add b.txt && git commit -q -m "Round 3 item 2"; c2="$(git rev-parse --short HEAD)"
summary() { # rows of the Items table
  { printf '# Round 3 summary\n\n## Items\n\n| Item | State | Commit | Note |\n| ---- | ----- | ------ | ---- |\n'; printf '%s\n' "$@"; } > .plans/round-3-summary.md
}
good=("| 1 | done | $c1 | parser |" "| 2 | done | $c2 | docs |" "| 3 | checked | | suite 12/12 passed |")

summary "${good[@]}"
expect "a summary with every item and real commits passes" "$(verify)" "0"

summary "${good[0]}" "${good[2]}"
expect "an item without a row fails" "$(verify)" "1"

summary "${good[0]}" "| 2 | finished | $c2 | docs |" "${good[2]}"
expect "an item with an unknown state fails" "$(verify)" "1"

summary "${good[0]}" "| 2 | done | deadbeef | docs |" "${good[2]}"
expect "a fake sha fails" "$(verify)" "1"

summary "${good[0]}" "${good[1]}" "| 3 | checked | | |"
expect "a checked item without its note fails" "$(verify)" "1"

summary "${good[@]}"
echo dirty >> a.txt
expect "a dirty tree fails" "$(verify)" "1"
git checkout -q -- a.txt

# Two lanes: each lane's executor commits in its own worktree; lane-merge.sh merges them; the
# coordinator writes one summary from the two lane summaries, one row per item.
git checkout -q -b lanes main
printf '# Round 3\n\n## Items\n\n### 1. Parse dates\n\n### 2. Add docs\n' > .plans/round-3.md
git worktree add -q -b lanes-lane-a "$tmp/lane-a" lanes
printf 'dates\n' > "$tmp/lane-a/dates.txt"; git -C "$tmp/lane-a" add . && git -C "$tmp/lane-a" commit -q -m "Round 3 item 1"
la="$(git -C "$tmp/lane-a" rev-parse --short HEAD)"
git worktree add -q -b lanes-lane-b "$tmp/lane-b" lanes
printf 'docs\n' > "$tmp/lane-b/docs.txt"; git -C "$tmp/lane-b" add . && git -C "$tmp/lane-b" commit -q -m "Round 3 item 2"
lb="$(git -C "$tmp/lane-b" rev-parse --short HEAD)"
bash "$here/lane-merge.sh" lanes a b > /dev/null 2>&1
summary "| 1 | done | $la | lane a |" "| 2 | done | $lb | lane b |"
expect "a summary from two lane summaries, lanes merged, passes" "$(verify)" "0"

summary "| 1 | done | $la | lane a |" "| 2 | done | $lb | lane b |"
git reset -q --hard HEAD~1  # lane b's merge undone: its commit is not on HEAD
expect "a lane commit left unmerged fails" "$(verify)" "1"

exit "$fail"
