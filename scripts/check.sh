#!/usr/bin/env bash
# Validates the plugin and blocks employer- or person-specific words.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
deny_file="${MY_AGENT_KIT_DENY:-${MY_AGENT_KIT_HOME:-$HOME/.my-agent-kit}/deny-words.txt}"

claude plugin validate "$root"

if [[ -f "$deny_file" ]]; then
  pattern="$(grep -v -e '^#' -e '^[[:space:]]*$' "$deny_file" | paste -sd '|' -)"
  if [[ -n "$pattern" ]]; then
    hits="$(git -C "$root" grep -n -i -I -E "$pattern" -- . ':!scripts/check.sh' || true)"
    if [[ -n "$hits" ]]; then
      echo "Privacy check failed: these lines contain words from $deny_file" >&2
      echo "$hits" >&2
      exit 1
    fi
  fi
elif [[ "${MY_AGENT_KIT_ALLOW_NO_DENY:-}" == "1" ]]; then
  echo "Privacy check skipped: $deny_file not found (MY_AGENT_KIT_ALLOW_NO_DENY=1)" >&2
else
  echo "Privacy check failed: $deny_file not found. Create it, or set MY_AGENT_KIT_ALLOW_NO_DENY=1 on a machine without it." >&2
  exit 1
fi

# The scripts' own tests and the mods' script tests (check.test.sh tests this file, so it runs apart).
# Inside a git hook, git exports GIT_DIR and GIT_INDEX_FILE: a test's own repositories would then
# write to this one.
shopt -s nullglob
for t in "$root"/scripts/*.test.sh "$root"/mods/*/scripts/*.test.sh; do
  [[ "$t" == "$root/scripts/check.test.sh" ]] && continue
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE -u GIT_PREFIX -u GIT_COMMON_DIR -u GIT_OBJECT_DIRECTORY \
    -u GIT_ALTERNATE_OBJECT_DIRECTORIES bash "$t" > /dev/null || { echo "check.sh: ${t#"$root"/} failed" >&2; exit 1; }
done

echo "check.sh: OK"
