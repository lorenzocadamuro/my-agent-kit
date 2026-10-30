#!/usr/bin/env bash
# One open note in compressed technical English. The proposal must open with the concrete case (the CI type check failing
# 40 minutes after the push) before the missing question, and state its cost in the user's time. Regex graders: LLM
# judges failed every reply here, good or bad (evals/README.md, Lessons).
mkdir -p kit-data
cat > kit-data/suite-log.md <<'P'
# Suite log

## 20261027-01 · plan:round · open

- When: 2026-10-27 14:10
- Kit: 5.7.0
- Where: acme/api · feature-k · session unknown
- What happened: Round 2 verification ran only the bar's commands (the unit suite), then pushed the draft. CI's `typecheck` job failed 40 minutes later on a wrong return type in `api/handlers.py`; round 3 was spent on it.
- Why it was a problem: unknown
- Missing question: unknown
- Expected: The round checks include the local equivalent of each CI job on the touched paths; each command runs once in the worktree with its prerequisites; a command needing authorisation runs its safe part.
- Suspected cause: plan:round verification step; profile commands not mapped to CI jobs.
- Signal: rework

P
