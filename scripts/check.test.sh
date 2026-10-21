#!/usr/bin/env bash
# Tests check.sh: a missing deny-word file fails, unless MY_AGENT_KIT_ALLOW_NO_DENY=1 says so;
# the file is found under $MY_AGENT_KIT_HOME when MY_AGENT_KIT_DENY is unset.
# Usage: bash scripts/check.test.sh
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

if MY_AGENT_KIT_DENY=/nonexistent bash "$root/scripts/check.sh" >/dev/null 2>&1; then
  echo "FAIL: check.sh passed with a missing deny-word file" >&2; fail=1
else
  echo "ok: missing deny-word file fails"
fi

if MY_AGENT_KIT_DENY=/nonexistent MY_AGENT_KIT_ALLOW_NO_DENY=1 bash "$root/scripts/check.sh" >/dev/null 2>&1; then
  echo "ok: MY_AGENT_KIT_ALLOW_NO_DENY=1 lets it pass"
else
  echo "FAIL: check.sh failed with MY_AGENT_KIT_ALLOW_NO_DENY=1" >&2; fail=1
fi

tmp="$(mktemp -d)"
mkdir -p "$tmp/home" "$tmp/data"
echo "Principles" > "$tmp/data/deny-words.txt"
if HOME="$tmp/home" MY_AGENT_KIT_HOME="$tmp/data" env -u MY_AGENT_KIT_DENY bash "$root/scripts/check.sh" >/dev/null 2>"$tmp/err"; then
  echo "FAIL: check.sh passed with a deny word in \$MY_AGENT_KIT_HOME/deny-words.txt" >&2; fail=1
elif grep -q "contain words from $tmp/data/deny-words.txt" "$tmp/err"; then
  echo "ok: the deny-word file is read from \$MY_AGENT_KIT_HOME"
else
  echo "FAIL: check.sh did not read \$MY_AGENT_KIT_HOME/deny-words.txt: $(head -1 "$tmp/err")" >&2; fail=1
fi
rm -rf "$tmp"

exit "$fail"
