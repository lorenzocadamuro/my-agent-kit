#!/usr/bin/env bash
# Checks a round summary against git: every triage item has a state, listed commits exist on HEAD, the tree is clean.
# Usage: verify-round.sh <plans-dir> <round>   (run inside the change's worktree)
set -euo pipefail

plans="${1:?usage: verify-round.sh <plans-dir> <round>}"
round="${2:?usage: verify-round.sh <plans-dir> <round>}"
triage="$plans/round-$round.md"
summary="$plans/round-$round-summary.md"
fail=0

[[ -f "$triage" ]] || { echo "missing $triage" >&2; exit 2; }
[[ -f "$summary" ]] || { echo "missing $summary" >&2; exit 2; }

items="$(grep -E '^### [0-9]+\.' "$triage" | sed -E 's/^### ([0-9]+)\..*/\1/' | sort -n | uniq)"
[[ -n "$items" ]] || { echo "no items found in $triage (expected '### <k>. ...' headings)" >&2; exit 2; }

for k in $items; do
  row="$(grep -E "^\| *$k *\|" "$summary" | head -n 1 || true)"
  if [[ -z "$row" ]]; then
    echo "item $k: no row in summary" >&2; fail=1; continue
  fi
  state="$(echo "$row" | awk -F'|' '{gsub(/^ +| +$/,"",$3); print tolower($3)}')"
  case "$state" in
    done|incomplete|skipped|stopped) ;;
    *) echo "item $k: invalid state '$state'" >&2; fail=1 ;;
  esac
  for sha in $(echo "$row" | awk -F'|' '{print $4}' | grep -oE '\b[0-9a-f]{7,40}\b' || true); do
    if ! git cat-file -e "$sha^{commit}" 2>/dev/null; then
      echo "item $k: commit $sha does not exist" >&2; fail=1
    elif ! git merge-base --is-ancestor "$sha" HEAD; then
      echo "item $k: commit $sha is not on HEAD" >&2; fail=1
    fi
  done
  if [[ "$state" == "done" ]] && ! echo "$row" | awk -F'|' '{print $4}' | grep -qE '[0-9a-f]{7,40}'; then
    echo "item $k: done but no commit listed" >&2; fail=1
  fi
done

if [[ -n "$(git status --porcelain)" ]]; then
  echo "working tree is not clean:" >&2; git status --short >&2; fail=1
fi

head_sha="$(git rev-parse --short HEAD)"
upstream="$(git rev-parse --short '@{u}' 2>/dev/null || echo none)"
echo "HEAD $head_sha · upstream $upstream · items: $(echo $items | wc -w | tr -d ' ')"

if [[ "$fail" -ne 0 ]]; then
  echo "verify-round: FAILED" >&2; exit 1
fi
echo "verify-round: OK"
