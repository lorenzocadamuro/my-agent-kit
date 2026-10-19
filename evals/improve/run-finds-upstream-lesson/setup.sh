#!/usr/bin/env bash
mkdir -p kit-data
cat > kit-data/suite-log.md <<'P'
# Suite log

## 20261101-01 · pr-round · open

- When: 2026-11-01 10:00
- Where: acme/web · feature-a · session unknown
- What happened: The plan measured the e2e suite's baseline on Monday (pass) and put "e2e passes" in the bar. On Thursday round 3 stopped: the e2e suite failed because a local service had stopped since Monday, not because of the change.
- Expected: A failure that exists before the round's first change does not stop the round.
- Suspected cause: pr-round step 3 copies the plan's baseline into stop conditions.
- Signal: unplanned stop

## 20261103-01 · pr-round · open

- When: 2026-11-03 15:00
- Where: acme/api · feature-b · session unknown
- What happened: The plan measured the migration check's baseline (pass). Two days later the local database went stale; round 2's stop condition "migration check passes" failed for that reason, and the round was rerun after the database was rebuilt by hand.
- Expected: The round notices the stale environment before starting, and rebuilds it or records the new baseline.
- Suspected cause: pr-round step 3 stop conditions.
- Signal: unplanned stop
P
