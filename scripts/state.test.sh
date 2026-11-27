#!/usr/bin/env bash
# Tests state.sh, the only writer of the state file: fields set, every other field kept; a round
# appended once and ended with its verdict; startedAt kept unless the file is done; the step flags
# (--running, --failed, --labels, --short) passed to state-steps.sh; no temp file left behind.
# Usage: bash scripts/state.test.sh
set -uo pipefail

script="$(cd "$(dirname "$0")" && pwd)/state.sh"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
expect() { if [[ "$2" == "$3" ]]; then echo "ok: $1"; else echo "FAIL: $1: expected '$3', got '$2'"; fail=1; fi; }
q() { jq -c -r "$1" "$tmp/state.json"; }
st() { bash "$script" "$tmp/state.json" "$@" > "$tmp/out" 2> "$tmp/err"; }

cat > "$tmp/plan.md" <<'P'
# Coupons

## Parts

### Part A: Expired coupons
- [x] Reject expired coupons in redeem()
- [ ] Drive checkout() with one

### Part B: Coupon telemetry
- [ ] Count rejections
P
printf '{ "repo": "acme/shop", "state": "running", "startedAt": "2026-01-10T08:00:00Z", "pr": 456 }\n' > "$tmp/state.json"

st --set step=execute --set "reason=Tests failing" --json 'items={"done":1,"total":3}' --json round=3
expect "a field is set" "$(q '.step') / $(q '.reason')" "execute / Tests failing"
expect "a JSON field is set" "$(q '.items') $(q '.round | type')" '{"done":1,"total":3} number'
expect "other fields are kept" "$(q '.repo') $(q '.pr')" "acme/shop 456"
expect "updatedAt is written" "$(q '.updatedAt | test("^20[0-9-]+T[0-9:]+Z$")')" "true"
st --json reason=null
expect "a field can be cleared" "$(q '.reason')" "null"

st --started now
expect "startedAt stays when the file has one" "$(q '.startedAt')" "2026-01-10T08:00:00Z"
st --set state=done; st --started 2026-02-01T09:00:00Z --set state=planning
expect "a done file counts as having none" "$(q '.startedAt') $(q '.state')" "2026-02-01T09:00:00Z planning"

st --plan "$tmp/plan.md" --new-round 4 --running A2 --short "A=Expired coupons" --labels "A=Reject expired,Checkout test" --labels "B=Rejection count"
expect "a round is appended" "$(q '[.rounds[] | .n] | join(",")') $(q '.rounds[0].startedAt != null')" "4 true"
expect "the short title is written" "$(q '.parts[0].short')" "Expired coupons"
expect "the labels are written" "$(q '[.parts[].steps[].label] | join(",")')" "Reject expired,Checkout test,Rejection count"
expect "the running step is derived" "$(q '[.parts[0].steps[].status] | join(",")')" "done,running"
st --plan "$tmp/plan.md" --new-round 4 --running A2
expect "a round that has an entry is not appended again" "$(q '.rounds | length')" "1"

st --plan "$tmp/plan.md" --failed B1
expect "--failed reaches state-steps.sh" "$(q '.parts[1].steps[0].status')" "failed"
st --plan "$tmp/plan.md" --end-round "failed: Tests failing"
expect "the open round ends with its verdict" "$(q '.rounds[0].verdict') $(q '.rounds[0].endedAt != null')" "failed: Tests failing true"
expect "the failed mark stays at the round's end" "$(q '.parts[1].steps[0].status')" "failed"
st --plan "$tmp/plan.md" --end-round "block 1"
expect "an ended round is not ended again" "$(q '.rounds[0].verdict')" "failed: Tests failing"
st --plan "$tmp/plan.md" --new-round 5
expect "a new round clears the failed mark" "$(q '.parts[1].steps[0].status') $(q '.rounds | length')" "todo 2"
st --plan "$tmp/plan.md" --new-round 5 --failed B1
st --plan "$tmp/plan.md" --new-round 5
expect "a round already appended does not clear the mark" "$(q '.parts[1].steps[0].status')" "failed"

expect "a step flag without --plan is refused" "$(st --running A1; echo $?)" "2"
expect "an unknown argument is refused" "$(st --sett x=y; echo $?)" "2"
expect "a set without = is refused" "$(st --set state; echo $?)" "2"
expect "bad JSON is refused and the file kept" "$(st --json 'items={done'; echo $?) $(q '.repo')" "2 acme/shop"
expect "no temp file is left" "$(ls -a "$tmp" | grep -c '^\.state')" "0"

rm "$tmp/state.json"
st --set state=planning --started now
expect "a missing file is created" "$(q '.state') $(q '.startedAt != null')" "planning true"
exit "$fail"
