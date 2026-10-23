#!/usr/bin/env bash
# Reports how far a change has drifted: size versus budget, distance from origin/main, and a conflict preview.
# The budgets count production code only; test changes are reported apart and never put a change over budget.
# Usage: drift.sh [--lines N] [--files N] [--base REF] [--tests <pathspec>…] [-- <pathspec excludes, e.g. ':!**/generated/**'>]
#   --tests replaces the default test paths: test/tests/__tests__/spec/specs folders, and files named
#   *_test.*, *.test.*, *.spec.*, test_*.*, *_spec.*, conftest.py.
set -euo pipefail

budget_lines=""; budget_files=""; base_ref="origin/main"; excludes=(); tests=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --lines) budget_lines="$2"; shift 2 ;;
    --files) budget_files="$2"; shift 2 ;;
    --base) base_ref="$2"; shift 2 ;;
    --tests) shift; while [[ $# -gt 0 && "$1" != --* ]]; do tests+=("$1"); shift; done ;;
    --) shift; excludes=("$@"); break ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done
if [[ ${#tests[@]} -eq 0 ]]; then
  for p in '**/test/**' '**/tests/**' '**/__tests__/**' '**/spec/**' '**/specs/**' \
    '**/*_test.*' '**/*.test.*' '**/*.spec.*' '**/test_*.*' '**/*_spec.*' '**/conftest.py'; do
    tests+=(":(glob)$p")
  done
fi

git fetch -q origin "${base_ref#origin/}" 2>/dev/null || echo "warning: could not fetch $base_ref; using local ref" >&2
base="$(git merge-base HEAD "$base_ref")"

excl=(); if [[ ${#excludes[@]} -gt 0 ]]; then excl=("${excludes[@]}"); fi
# Test paths on either side of the diff; a renamed file is classed by its new path.
test_paths=$'\n'"$(git diff --name-only --no-renames -z "$base" HEAD -- "${tests[@]}" ${excl[@]+"${excl[@]}"} | tr '\0' '\n')"$'\n'
files=0; added=0; deleted=0; t_files=0; t_added=0; t_deleted=0
while IFS= read -r -d '' rec; do
  a="${rec%%$'\t'*}"; rest="${rec#*$'\t'}"; d="${rest%%$'\t'*}"; path="${rest#*$'\t'}"
  if [[ -z "$path" ]]; then IFS= read -r -d '' _ && IFS= read -r -d '' path; fi
  [[ "$a" == - ]] && a=0; [[ "$d" == - ]] && d=0  # binary files count as files, with 0 lines
  files=$((files + 1)); added=$((added + a)); deleted=$((deleted + d))
  if [[ "$test_paths" == *$'\n'"$path"$'\n'* ]]; then t_files=$((t_files + 1)); t_added=$((t_added + a)); t_deleted=$((t_deleted + d)); fi
done < <(git diff --numstat -z -M "$base" HEAD -- . ${excl[@]+"${excl[@]}"})
lines=$((added + deleted)); t_lines=$((t_added + t_deleted))
p_files=$((files - t_files)); p_added=$((added - t_added)); p_deleted=$((deleted - t_deleted)); p_lines=$((lines - t_lines))

ahead="$(git rev-list --count "$base_ref"..HEAD)"
behind="$(git rev-list --count HEAD.."$base_ref")"

echo "size: $files files, +$added -$deleted ($lines lines) since merge-base ${base:0:11}"
echo "production: $p_files files, +$p_added -$p_deleted ($p_lines lines)"
echo "tests: $t_files files, +$t_added -$t_deleted ($t_lines lines), outside the budget"
over=0
if [[ -n "$budget_lines" ]]; then
  echo "budget lines: $p_lines / $budget_lines (production)"
  [[ "$p_lines" -gt "$budget_lines" ]] && over=1
fi
if [[ -n "$budget_files" ]]; then
  echo "budget files: $p_files / $budget_files (production)"
  [[ "$p_files" -gt "$budget_files" ]] && over=1
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
