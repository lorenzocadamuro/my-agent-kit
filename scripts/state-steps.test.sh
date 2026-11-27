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
# A box in an earlier section is no part; a deeper heading stays inside its part; labels stay by position.
cat > "$tmp/gates.md" <<'P'
## Gates
- [ ] approve the rollout

### Part A: Ledger
- [x] **A1** Write entry — test first: test_write
#### Notes
- [ ] **A2** Replay entry — test first: test_replay
P
printf '{"parts":[{"title":"Part A: Ledger","steps":[{"label":"Write entry","status":"done"}]}]}' > "$tmp/state.json"
bash "$script" "$tmp/state.json" "$tmp/gates.md" --running Z9 > /dev/null 2> "$tmp/err"
expect "a box outside the parts makes no part" "$(q '.parts | length') $(q '.parts[0].title')" "1 Part A: Ledger"
expect "a deeper heading stays inside its part" "$(q '.parts[0].total')" "2"
expect "a kept label stays when a step is added" "$(q '.parts[0].steps[0].label')" "Write entry"
expect "a new label stops before the test note" "$(q '.parts[0].steps[1].label')" "Replay entry"
expect "an unknown running step is reported" "$(grep -c 'Z9' "$tmp/err")" "1"
expect "a missing state folder is created" "$(bash "$script" "$tmp/new/dir/state.json" "$tmp/gates.md" > /dev/null 2>&1; echo $?)" "0"

# --failed marks an unticked step failed; a ticked step stays done, with a warning. --labels set the labels.
bash "$script" "$tmp/state.json" "$tmp/gates.md" --failed A2 --labels "A=Write ledger,Replay ledger" > /dev/null 2> "$tmp/err"
expect "--failed marks an unticked step failed" "$(q '.parts[0].steps[1].status')" "failed"
expect "--labels set the part's labels" "$(q '.parts[0].steps[0].label') / $(q '.parts[0].steps[1].label')" "Write ledger / Replay ledger"
bash "$script" "$tmp/state.json" "$tmp/gates.md" --failed A1 > /dev/null 2> "$tmp/err"
expect "--failed on a ticked step leaves it done" "$(q '.parts[0].steps[0].status')" "done"
expect "--failed on a ticked step is reported" "$(grep -c 'A1' "$tmp/err")" "1"
printf '{}' > "$tmp/state.json"
bash "$script" "$tmp/state.json" "$tmp/small.md" --labels "plan=Date parse,Parse test" --failed 2 > /dev/null 2>&1
expect "a plan without parts takes plan= labels and bare ids" "$(q '[.parts[0].steps[] | .label + " " + .status] | join(",")')" "Date parse done,Parse test failed"

exit "$fail"
