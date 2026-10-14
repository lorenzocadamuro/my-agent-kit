#!/usr/bin/env bash
# Reports how far a change has drifted: size versus budget, distance from origin/main, and a conflict preview.
# Usage: drift.sh [--lines N] [--files N] [--base REF] [-- <pathspec excludes, e.g. ':!**/generated/**'>]
set -euo pipefail

budget_lines=""; budget_files=""; base_ref="origin/main"; excludes=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --lines) budget_lines="$2"; shift 2 ;;
    --files) budget_files="$2"; shift 2 ;;
    --base) base_ref="$2"; shift 2 ;;
    --) shift; excludes=("$@"); break ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

git fetch -q origin "${base_ref#origin/}" 2>/dev/null || echo "warning: could not fetch $base_ref; using local ref" >&2
base="$(git merge-base HEAD "$base_ref")"

pathspec=(.)
if [[ ${#excludes[@]} -gt 0 ]]; then pathspec+=("${excludes[@]}"); fi
stat="$(git diff --shortstat "$base" HEAD -- "${pathspec[@]}")"
files="$(echo "$stat" | grep -oE '[0-9]+ files? changed' | grep -oE '^[0-9]+' || echo 0)"
added="$(echo "$stat" | grep -oE '[0-9]+ insertions?' | grep -oE '^[0-9]+' || echo 0)"
deleted="$(echo "$stat" | grep -oE '[0-9]+ deletions?' | grep -oE '^[0-9]+' || echo 0)"
lines=$((added + deleted))

ahead="$(git rev-list --count "$base_ref"..HEAD)"
behind="$(git rev-list --count HEAD.."$base_ref")"

echo "size: $files files, +$added -$deleted ($lines lines) since merge-base ${base:0:11}"
over=0
if [[ -n "$budget_lines" ]]; then
  echo "budget lines: $lines / $budget_lines"
  [[ "$lines" -gt "$budget_lines" ]] && over=1
fi
if [[ -n "$budget_files" ]]; then
  echo "budget files: $files / $budget_files"
  [[ "$files" -gt "$budget_files" ]] && over=1
fi
echo "commits: $ahead ahead, $behind behind $base_ref"

if [[ "$behind" -gt 0 ]]; then
  if conflicts="$(git merge-tree --write-tree --name-only HEAD "$base_ref" 2>/dev/null)"; then
    echo "merge preview: clean"
  else
    echo "merge preview: conflicts in"
    echo "$conflicts" | tail -n +2 | sed '/^$/,$d' | sed 's/^/  /'
  fi
fi

[[ "$over" -eq 1 ]] && echo "DRIFT: over budget" || echo "drift: within budget"
