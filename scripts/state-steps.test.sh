#!/usr/bin/env bash
# Tests state-steps.sh: statuses come from plan.md's boxes, the running list and a kept failed mark,
# in that order; part counts follow; labels and other fields are kept; a new round clears failed.
# Usage: bash scripts/state-steps.test.sh
set -uo pipefail

script="$(cd "$(dirname "$0")" && pwd)/state-steps.sh"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
expect() { if [[ "$2" == "$3" ]]; then echo "ok: $1"; else echo "FAIL: $1: expected '$3', got '$2'"; fail=1; fi; }
q() { jq -r "$1" "$tmp/state.json"; }

cat > "$tmp/plan.md" <<'P'
# Refuse expired coupons

## Bar for done
- [ ] parts A to C done

## Parts

### Part A: Expired coupons
- [x] **A1** Reject expired coupons in redeem()
- [x] **A2** Drive checkout() with one

### Part B: Coupon telemetry
- [x] **B1** Count rejections
- [ ] **B2** Add the region field

### Part C: Docs
- [ ] **C1** Document expiry
P
cat > "$tmp/state.json" <<'J'
{ "state": "running", "startedAt": "2026-01-10T08:00:00Z", "rounds": [{ "n": 3, "startedAt": "x" }],
  "parts": [
    { "title": "Part A: Expired coupons", "short": "Expired coupons", "status": "running", "done": 1, "total": 2,
      "steps": [ { "label": "Reject expired", "status": "done" }, { "label": "Checkout test", "status": "todo" } ] },
    { "title": "Part B: Coupon telemetry", "short": "Telemetry", "status": "todo", "done": 0, "total": 2,
      "steps": [ { "label": "Rejection count", "status": "todo" }, { "label": "Region field", "status": "failed" } ] },
    { "title": "Part C: Docs", "short": "Docs", "left": ["Expiry docs"] }
  ] }
J

bash "$script" "$tmp/state.json" "$tmp/plan.md" --running C1 > /dev/null 2> "$tmp/err"
expect "a ticked box is done, whoever wrote todo" "$(q '.parts[0].steps[1].status')" "done"
expect "a part with every box ticked is done" "$(q '.parts[0].status') $(q '.parts[0].done')/$(q '.parts[0].total')" "done 2/2"
expect "a failed step stays failed while unticked" "$(q '.parts[1].steps[1].status')" "failed"
expect "a half-ticked part is running" "$(q '.parts[1].status') $(q '.parts[1].done')" "running 1"
expect "a step the open round implements is running" "$(q '.parts[2].steps[0].status') $(q '.parts[2].status')" "running running"
expect "labels and short titles are kept" "$(q '.parts[1].steps[0].label') / $(q '.parts[1].short')" "Rejection count / Telemetry"
expect "a step without a label gets its first words" "$(q '.parts[2].steps[0].label')" "Document expiry"
expect "the unlabelled step is reported" "$(grep -c C1 "$tmp/err")" "1"
expect "the old left field is dropped" "$(q '.parts[2].left // "none"')" "none"
expect "other fields are kept" "$(q '.startedAt') $(q '.rounds[0].n')" "2026-01-10T08:00:00Z 3"

bash "$script" "$tmp/state.json" "$tmp/plan.md" --new-round > /dev/null 2>&1
expect "a new round clears the failed mark" "$(q '.parts[1].steps[1].status')" "todo"
expect "without --running nothing runs" "$(q '[.parts[].steps[] | select(.status == "running")] | length')" "0"

# A plan without parts is one part: its boxes, outside the bar for done.
printf '# Small fix\n\n## Bar for done\n- [ ] tests pass\n\n## Verification\n- [x] Fix the date parse\n- [ ] Add a test\n' > "$tmp/small.md"
echo '{}' > "$tmp/state.json"
bash "$script" "$tmp/state.json" "$tmp/small.md" > /dev/null 2>&1
expect "a plan without parts is one part of its own steps" "$(q '.parts | length') $(q '.parts[0].done')/$(q '.parts[0].total')" "1 1/2"

expect "no temp file is left" "$(ls -a "$tmp" | grep -c '^\.state-')" "0"
exit "$fail"
