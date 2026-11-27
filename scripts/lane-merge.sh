#!/usr/bin/env bash
# Merges a round's lane branches into the work branch once every lane has finished (rules/parallel.md):
# in lane order, each with `git merge --no-ff` (never a rebase, so every lane commit stays on HEAD for
# verify-round.sh). A lane already merged is skipped, so a second call resumes from the first unmerged
# lane. At the first conflict it runs `git merge --abort`, leaves a clean tree, prints
# "conflict: lane <id>" with its files, and exits 1. A merge that fails without unmerged paths (a hook
# refused it, a locked index) prints "merge failed: lane <id>", aborted when MERGE_HEAD exists, exit 1.
# Usage: lane-merge.sh <work branch> [<lane id>...]   (run in the work branch's worktree; without ids,
#        every local branch <work branch>-lane-<id>, in id order)
set -euo pipefail

work="${1:?usage: lane-merge.sh <work branch> [<lane id>...]}"
shift
if [[ "$(git branch --show-current)" != "$work" ]]; then
  echo "lane-merge.sh: the checked-out branch is not $work" >&2; exit 2
fi
if [[ -n "$(git status --porcelain)" ]]; then
  echo "lane-merge.sh: the tree is not clean" >&2; git status --short >&2; exit 2
fi
ids=("$@")
if [[ ${#ids[@]} -eq 0 ]]; then
  while IFS= read -r b; do ids+=("${b#"$work"-lane-}"); done < <(git for-each-ref --format='%(refname:short)' "refs/heads/$work-lane-*" | sort)
fi
for id in "${ids[@]}"; do
  git rev-parse -q --verify "refs/heads/$work-lane-$id" > /dev/null || { echo "lane-merge.sh: no branch $work-lane-$id" >&2; exit 2; }
done

for id in "${ids[@]}"; do
  branch="$work-lane-$id"
  if git merge-base --is-ancestor "$branch" HEAD; then
    echo "already merged: lane $id ($branch)"; continue
  fi
  if git merge --no-ff --no-edit -m "Merge lane $id ($branch)" "$branch" > /dev/null 2>&1; then
    echo "merged: lane $id ($branch)"
  else
    files="$(git diff --name-only --diff-filter=U | paste -sd, -)"
    aborted=""
    if git rev-parse -q --verify MERGE_HEAD > /dev/null; then git merge --abort; aborted="; merge aborted"; fi
    if [[ -n "$files" ]]; then
      echo "conflict: lane $id ($branch) in $files; merge aborted, tree clean"
    else
      echo "merge failed: lane $id ($branch), with no conflict$aborted"
    fi
    exit 1
  fi
done
