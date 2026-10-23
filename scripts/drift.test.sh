#!/usr/bin/env bash
# Tests drift.sh: the line and file budgets count production code only; test changes are reported
# apart and never put a change over budget; --tests replaces the default test paths; excludes still apply.
# Usage: bash scripts/drift.test.sh
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# A repository of its own, unaffected by the user's git configuration.
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
lines() { for ((i = 1; i <= $2; i++)); do echo "line $i"; done > "$1"; }

git init -q --bare -b main "$tmp/origin.git"
git clone -q "$tmp/origin.git" "$tmp/work" 2>/dev/null
cd "$tmp/work" || exit 1
git checkout -q -b main
echo "start" > README
git add README && git commit -q -m start && git push -q origin main
git checkout -q -b change
mkdir -p src tests qa
lines src/app.py 10          # production: 10 lines
lines tests/test_app.py 40   # test (folder and name): 40 lines
lines src/app.test.js 20     # test (name): 20 lines
lines qa/check.sh 15         # production by default; a test with --tests
git add . && git commit -q -m change

# Totals: 4 files, 85 lines. Default production: src/app.py + qa/check.sh = 2 files, 25 lines.
check() { # <description> <expected regex> <drift.sh arguments…>
  local desc="$1" want="$2"; shift 2
  local out; out="$(bash "$root/scripts/drift.sh" "$@" 2>&1)"
  if grep -qE "$want" <<<"$out"; then
    echo "ok: $desc"
  else
    echo "FAIL: $desc (expected /$want/), got:" >&2; sed 's/^/  /' <<<"$out" >&2; fail=1
  fi
}

check "a budget between production and total lines is within budget" \
  '^drift: within budget$' --lines 50
check "test lines and files are reported apart" \
  '^tests: 2 files, \+60 -0 \(60 lines\)' --lines 50
check "production lines and files are reported" \
  '^production: 2 files, \+25 -0 \(25 lines\)' --lines 50
check "the total size line stays" \
  '^size: 4 files, \+85 -0 \(85 lines\) since merge-base' --lines 50
check "a file budget counts production files only" \
  '^drift: within budget$' --files 2
check "a production-only overrun is over budget" \
  '^DRIFT: over budget$' --lines 20
check "--tests replaces the default test paths" \
  '^production: 3 files, \+70 -0 \(70 lines\)' --lines 50 --tests ':(glob)qa/**'
check "--tests changes the verdict" \
  '^DRIFT: over budget$' --lines 50 --tests ':(glob)qa/**'
check "excludes after -- still remove paths" \
  '^drift: within budget$' --lines 5 -- ':!src/**' ':!qa/**'

# A file moved from production into a test folder is a rename: one test file, no lines.
git mv README tests/README && git commit -q -m move
check "a file moved into tests counts as a test file" \
  '^tests: 3 files, \+60 -0 \(60 lines\)' --lines 50
check "a move leaves the production count as it was" \
  '^production: 2 files, \+25 -0 \(25 lines\)' --lines 50

exit "$fail"
