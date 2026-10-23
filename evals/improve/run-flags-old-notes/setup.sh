#!/usr/bin/env bash
mkdir -p kit-data
cat > kit-data/suite-log.md <<'P'
# Suite log

## 20261021-04 · plan:round · open

- When: 2026-10-21 18:00
- Kit: 4.0.0
- Where: acme/web · feature-d · session unknown
- What happened: The run stopped at "drift over budget": the plan's split threshold was 400 changed lines, and about 250 of the 450 lines were the guard tests the plan itself asked for.
- Why it was a problem: A stop for growth the plan wanted (its tests), not for a change too large to review; I had to restart the run by hand.
- Missing question: "Is what grows the code to review, or the tests the plan asked for?"
- Expected: The split threshold and the size budget count production lines; test lines are measured and reported apart, and never trigger the stop.
- Suspected cause: `scripts/drift.sh` counts every changed line, and plan:round compares that total with the plan's budget.
- Signal: unplanned stop

## 20261023-02 · plan:run · open

- When: 2026-10-23 11:00
- Kit: 5.1.0
- Where: acme/api · feature-e · session unknown
- What happened: At a gate, a decision changed a rule of the plan ("a release is final" became "final within 24 hours"). The coordinator updated the invariants, but not the Boundary nor the "Existing vs new" table, which still stated the old rule; the round's review found them stale.
- Why it was a problem: The plan contradicted itself, and a review could have judged the code against the wrong sentence.
- Missing question: "Does this decision change a rule the plan repeats elsewhere (boundary, invariants, tables, intentional changes)?"
- Expected: When a gate decision changes a rule, find every place in the plan that repeats it and update them together.
- Suspected cause: question-format § After the answer records the decision in the Decisions table, but does not carry it to the rest of the plan.
- Signal: review found unplanned issue
P
