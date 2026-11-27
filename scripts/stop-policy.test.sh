#!/usr/bin/env bash
# Tests stop-policy.py, one row per rule of /my:run § Run (skills/plan/run/SKILL.md): the 9 stop
# entries, a decision of a handed-over kind, the success definition, a gate answer, drift over budget,
# a lane merge conflict, a lane merge that failed otherwise, and a plain go. Each row encodes the 7.3.0 rule unchanged.
# Usage: bash scripts/stop-policy.test.sh
set -uo pipefail

script="$(cd "$(dirname "$0")" && pwd)/stop-policy.py"
fail=0
row() { # <description> <expected output> <facts JSON>
  local out; out="$(printf '%s' "$3" | python3 "$script" - 2>&1)"
  if [[ "$out" == "$2" ]]; then echo "ok: $1"; else echo "FAIL: $1: expected '$2', got '$out'"; fail=1; fi
}

# The 9 entries of the stop list, in its order.
row "a gate the plan names" "stop: Plan approval" '{"gate": "Plan approval"}'
row "a decision for the user" "stop: Decision needed (boundary)" '{"decisions": [{"kind": "K3", "flag": "boundary", "handedOver": false}]}'
row "failed verification" "stop: Verification failed" '{"verificationFailed": true}'
row "conflicts with main" "stop: Conflicts with main" '{"conflictsWithMain": true}'
row "new PR comments not covered by the source" "stop: New PR comments (suggest Review comments)" '{"newComments": 2}'
row "red CI known at round start" "stop: Red CI" '{"redCiAtStart": true}'
row "anything to publish" "stop: To publish (draft PR question)" '{"toPublish": ["draft PR question"]}'
row "the ready-for-review gate" "stop: Ready for review" '{"readyForReview": true}'
row "5 consecutive rounds" "stop: Round cap" '{"consecutiveRounds": 5}'
row "4 consecutive rounds go on" "go: round succeeded" '{"consecutiveRounds": 4}'
row "a rejected push" "stop: Push rejected" '{"pushRejected": true}'
row "an executor that stopped" "stop: Executor stopped" '{"executorStopped": true}'

# A decision whose kind the user handed over is decided alone and listed.
row "a handed-over decision goes on" "go: round succeeded; decided alone (handed over: K7)" '{"decisions": [{"kind": "K7", "flag": "none", "handedOver": true}]}'
row "a handed-over and a held decision stop" "stop: Decision needed (rule)" '{"decisions": [{"kind": "K7", "handedOver": true}, {"kind": "K2", "flag": "rule"}]}'

# The success definition: verification passed, the push done or disabled, no question open.
row "an open question is no success" "stop: Open question" '{"openQuestions": 1}'
row "a disabled push still succeeds" "go: round succeeded" '{"pushDisabled": true}'

# After a gate answer, go on unless the answer ends the run.
row "a gate answer goes on" "go: round succeeded" '{"gate": "Drift over budget", "gateAnswer": "go on"}'
row "a gate answer that ends the run" "stop: Run ended by the answer" '{"gate": "Plan approval", "gateAnswer": "end"}'

# Drift over budget is step 2's gate; a lane merge conflict is the stop "conflicts".
row "drift over budget" "stop: Drift over budget" '{"driftOverBudget": true}'
row "a lane merge conflict" "stop: Lane conflict" '{"laneConflict": true}'
row "a lane merge that failed without a conflict" "stop: Executor stopped (lane merge failed)" '{"laneMergeFailed": true}'

# The first matching entry wins, in the stop list's order.
row "the first entry wins" "stop: Verification failed" '{"verificationFailed": true, "newComments": 1, "consecutiveRounds": 5}'

# A plain round goes on.
row "a plain round goes on" "go: round succeeded" '{}'

# A misspelled fact is an error, never a silent go.
expect_err() { printf '%s' "$2" | python3 "$script" - > /dev/null 2>&1; local rc=$?; if [[ $rc -eq 2 ]]; then echo "ok: $1"; else echo "FAIL: $1: exit $rc"; fail=1; fi; }
expect_err "an unknown fact is refused" '{"verificationFaild": true}'
expect_err "a fact of the wrong type is refused" '{"newComments": "two"}'
expect_err "a gate answer other than go on or end is refused" '{"gateAnswer": "maybe"}'
expect_err "input that is not JSON is refused" 'stop'

exit "$fail"
