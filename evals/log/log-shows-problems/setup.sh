#!/usr/bin/env bash
mkdir -p kit-data
cat > kit-data/suite-log.md <<'P'
# Suite log

## 20260101-01 · scope-plan · fixed 1.2.0 (abc1234)

- When: 2026-01-01 10:00
- Where: acme/web · main · session unknown
- What happened: The plan asked for the size budget twice.
- Expected: Ask each question once.
- Suspected cause: scope-plan step 4.
- Signal: question re-asked

## 20260102-01 · review-lens · wontfix: behaves as designed

- When: 2026-01-02 11:00
- Where: acme/web · main · session unknown
- What happened: The review graded a style nit as a note instead of a block.
- Expected: Block every style nit.
- Suspected cause: unknown
- Signal: other

## 20260103-01 · pr-round · open

- When: 2026-01-03 09:00
- Where: acme/web · feature-x · session unknown
- What happened: The round pushed the branch although the targeted tests timed out after ten minutes.
- Expected: A timed-out test run stops the round before the push.
- Suspected cause: pr-round step 6 treats a timeout as a pass.
- Signal: unplanned stop

## 20260104-01 · merge-main · open

- When: 2026-01-04 15:00
- Where: acme/web · feature-y · session unknown
- What happened: The merge regenerated the lockfile with an unpinned package manager, adding hundreds of unrelated lines.
- Expected: Regenerate lockfiles with the pinned package manager version.
- Suspected cause: merge-main lockfile step.
- Signal: other
P
