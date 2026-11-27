#!/usr/bin/env bash
# Tests lane-merge.sh on a temp repository: disjoint lanes merge in lane order with --no-ff and keep
# every lane commit on HEAD; a conflict stops with the merge aborted and a clean tree; a second call
# after the fix skips the lanes already merged and resumes from the first unmerged one.
# Usage: bash scripts/lane-merge.test.sh
set -uo pipefail

script="$(cd "$(dirname "$0")" && pwd)/lane-merge.sh"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
expect() { if [[ "$2" == "$3" ]]; then echo "ok: $1"; else echo "FAIL: $1: expected '$3', got '$2'"; sed 's/^/  /' "$tmp/out" 2>/dev/null; fail=1; fi; }

# A repository of its own, unaffected by the user's git configuration and by a hook's GIT_DIR.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_COMMON_DIR GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

git init -q -b main "$tmp/repo"
cd "$tmp/repo" || exit 1
printf 'base\n' > shared.txt
git add . && git commit -q -m base
git checkout -q -b feature
# Each lane works in its own worktree, on <work branch>-lane-<id>, from the round's start.
lane() { # <id> <file> <text>
  git worktree add -q -b "feature-lane-$1" "$tmp/lane-$1" feature
  printf '%s\n' "$3" > "$tmp/lane-$1/$2"
  git -C "$tmp/lane-$1" add . && git -C "$tmp/lane-$1" commit -q -m "lane $1: $2"
  git -C "$tmp/lane-$1" rev-parse HEAD
}
sha_a="$(lane a a.txt one)"
sha_b="$(lane b b.txt two)"

bash "$script" feature a b > "$tmp/out" 2>&1
expect "disjoint lanes merge" "$?" "0"
expect "both lanes are reported merged" "$(grep -c '^merged: lane' "$tmp/out")" "2"
expect "lane a's commit is on HEAD" "$(git merge-base --is-ancestor "$sha_a" HEAD && echo yes)" "yes"
expect "lane b's commit is on HEAD" "$(git merge-base --is-ancestor "$sha_b" HEAD && echo yes)" "yes"
expect "each lane gets a merge commit" "$(git rev-list --merges --count HEAD)" "2"
expect "lanes merge in lane order" "$(git log --merges --format=%s --reverse | paste -sd, -)" "Merge lane a (feature-lane-a),Merge lane b (feature-lane-b)"
expect "both files are there" "$(cat a.txt b.txt | paste -sd, -)" "one,two"

# Two lanes that touch the same file: the second stops, aborted, with a clean tree.
git checkout -q -b feature2 main
lane2() { # <id> <text>
  git worktree add -q -b "feature2-lane-$1" "$tmp/l2-$1" feature2
  printf '%s\n' "$2" > "$tmp/l2-$1/shared.txt"
  git -C "$tmp/l2-$1" commit -q -am "lane $1"
}
lane2 a alpha; lane2 b beta; lane2 c gamma
before="$(git rev-parse HEAD)"
bash "$script" feature2 a b c > "$tmp/out" 2>&1
expect "a conflict stops the merge" "$?" "1"
expect "the conflict names its lane" "$(grep -c '^conflict: lane b' "$tmp/out")" "1"
expect "the conflict names its file" "$(grep -c 'shared.txt' "$tmp/out")" "1"
expect "the tree is clean after the stop" "$(git status --porcelain | wc -l | tr -d ' ')" "0"
expect "no merge is left in progress" "$(git rev-parse -q --verify MERGE_HEAD > /dev/null && echo yes || echo no)" "no"
expect "lane a stays merged" "$(git rev-list --merges --count "$before..HEAD")" "1"
expect "lane c is not tried after the stop" "$(grep -c 'lane c' "$tmp/out")" "0"

# The fix: lane b takes the work branch and resolves; lane c does the same. A second call resumes.
for id in b c; do
  git -C "$tmp/l2-$id" merge -q feature2 > /dev/null 2>&1
  printf 'alpha\n%s\n' "$id" > "$tmp/l2-$id/shared.txt"
  git -C "$tmp/l2-$id" commit -q -am "lane $id: resolve"
done
git -C "$tmp/l2-c" merge -q feature2-lane-b > /dev/null 2>&1
printf 'alpha\nb\nc\n' > "$tmp/l2-c/shared.txt"; git -C "$tmp/l2-c" commit -q -am "lane c: resolve with b"
bash "$script" feature2 a b c > "$tmp/out" 2>&1
expect "the second call succeeds" "$?" "0"
expect "the merged lane is skipped" "$(grep -c '^already merged: lane a' "$tmp/out")" "1"
expect "it resumes from the first unmerged lane" "$(grep '^merged: lane' "$tmp/out" | paste -sd, -)" "merged: lane b (feature2-lane-b),merged: lane c (feature2-lane-c)"

# Without lane ids, every <work branch>-lane-<id> branch merges, in id order.
git checkout -q -b feature3 main
git worktree add -q -b feature3-lane-b "$tmp/l3-b" feature3; printf 'x\n' > "$tmp/l3-b/x.txt"; git -C "$tmp/l3-b" add . && git -C "$tmp/l3-b" commit -q -m x
git worktree add -q -b feature3-lane-a "$tmp/l3-a" feature3; printf 'y\n' > "$tmp/l3-a/y.txt"; git -C "$tmp/l3-a" add . && git -C "$tmp/l3-a" commit -q -m y
bash "$script" feature3 > "$tmp/out" 2>&1
expect "without ids, the lane branches merge in id order" "$(grep '^merged:' "$tmp/out" | paste -sd, -)" "merged: lane a (feature3-lane-a),merged: lane b (feature3-lane-b)"

# Refusals: another branch checked out, a dirty tree, a missing lane branch.
expect "another branch is refused" "$(bash "$script" feature > /dev/null 2>&1; echo $?)" "2"
echo dirty >> y.txt
expect "a dirty tree is refused" "$(bash "$script" feature3 > /dev/null 2>&1; echo $?)" "2"
git checkout -q -- y.txt
expect "a missing lane branch is refused" "$(bash "$script" feature3 d > /dev/null 2>&1; echo $?)" "2"

exit "$fail"
