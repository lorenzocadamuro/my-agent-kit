#!/usr/bin/env bash
# Tests append-entry.sh: ten sessions appending at once get ten different ids, in the log and in the
# method; the next id follows today's highest; check lists duplicates.
# Usage: bash scripts/append-entry.test.sh
set -uo pipefail

script="$(cd "$(dirname "$0")" && pwd)/append-entry.sh"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
today="$(date +%Y%m%d)"
expect() { if [[ "$2" == "$3" ]]; then echo "ok: $1"; else echo "FAIL: $1: expected '$3', got '$2'"; fail=1; fi; }

# The log: today's highest is 03, an older day's 07 does not count.
printf '# Suite log\n\n## 20200101-07 · plan:scope · open\n\n## %s-03 · plan:round · open\n' "$today" > "$tmp/log.md"
printf '## <id> · pr:review · open\n\n- When: now\n' > "$tmp/entry.md"
expect "the next id follows today's highest" "$(bash "$script" log "$tmp/log.md" "$tmp/entry.md")" "$today-04"
for i in $(seq 1 10); do bash "$script" log "$tmp/log.md" "$tmp/entry.md" > "$tmp/out-$i" & done
wait
expect "ten sessions at once get ten ids" "$(cat "$tmp"/out-* | sort -u | wc -l | tr -d ' ')" "10"
expect "no duplicate in the log" "$(bash "$script" check "$tmp/log.md"; echo $?)" "0"
expect "the entry keeps its body" "$(grep -c '^- When: now' "$tmp/log.md")" "11"
expect "the lock is released" "$([[ -d "$tmp/log.md.lock" ]] && echo held || echo free)" "free"

# A missing log is created with its heading.
expect "a new log starts at 01" "$(bash "$script" log "$tmp/new.md" "$tmp/entry.md")" "$today-01"
expect "a new log has its heading" "$(head -1 "$tmp/new.md")" "# Suite log"

# The method: rows numbered after the highest K.
printf '# Method\n\n| Kind | Judgement |\n| --- | --- |\n| K1 | a |\n| K9 | b |\n' > "$tmp/method.md"
printf '| <id> | For X, choose Y |\n' > "$tmp/row.md"
expect "the next kind follows the highest" "$(bash "$script" kind "$tmp/method.md" "$tmp/row.md")" "K10"
for i in $(seq 1 10); do bash "$script" kind "$tmp/method.md" "$tmp/row.md" > "$tmp/kind-$i" & done
wait
expect "ten kinds at once get ten ids" "$(cat "$tmp"/kind-* | sort -u | wc -l | tr -d ' ')" "10"
expect "the row is in the table" "$(tail -1 "$tmp/method.md" | grep -cE '^\| K[0-9]+ \| For X, choose Y \|$')" "1"

# check lists what is already there twice, in both kinds of file.
printf '| Kind |\n| --- |\n| K3 | a |\n| K3 | b |\n' > "$tmp/dup-method.md"
expect "check finds a duplicate kind" "$(bash "$script" check "$tmp/dup-method.md")" "K3"
printf '## 20261029-05 · a · open\n\n## 20261029-05 · b · open\n' > "$tmp/dup-log.md"
expect "check finds a duplicate entry" "$(bash "$script" check "$tmp/dup-log.md" | tr '\n' ' '; echo "${PIPESTATUS[0]}")" "20261029-05 1"

exit "$fail"
