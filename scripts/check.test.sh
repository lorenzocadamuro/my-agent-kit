#!/usr/bin/env bash
# Tests check.sh: a missing deny-word file fails, unless MY_AGENT_KIT_ALLOW_NO_DENY=1 says so.
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

exit "$fail"
