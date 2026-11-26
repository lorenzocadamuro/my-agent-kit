#!/usr/bin/env bash
mkdir -p kit-data/projects
cat > kit-data/method.md <<'M'
# Method

| Kind | Judgement | Class | Matches | State | Last matches | Hand-over |
| ---- | --------- | ----- | ------- | ----- | ------------ | --------- |
| K1 | For the size budget of a change that touches one module, choose about 200 changed lines | work | 2 | asked | 2026-09-03, 2026-09-11 | none |
| K2 | For syncing with main before a round that is behind it, choose to sync first | work | 5 | proposed | 2026-09-01, 2026-09-08, 2026-09-15 | none |
| K3 | For the bar of a one-line text fix, choose the module's existing tests plus one test on the new text | work | 6 | handed over | 2026-09-02, 2026-09-09, 2026-09-16 | handed over 2026-09-10 |
M
cat > kit-data/suite-log.md <<'L'
# Suite log

## 20260901-01 · plan:scope · open

- When: 2026-09-01 10:00
- Where: acme/shop · main · session unknown
- What happened: The plan asked for the size budget twice.
- Expected: Ask each question once.
- Suspected cause: plan:scope step 4.
- Signal: question re-asked

## 20260902-01 · pr:sync · open

- When: 2026-09-02 11:00
- Where: acme/shop · feature-x · session unknown
- What happened: The sync regenerated the lockfile with an unpinned package manager.
- Expected: Regenerate lockfiles with the pinned version.
- Suspected cause: pr:sync lockfile step.
- Signal: other
L
cat > kit-data/projects/acme-shop.md <<'R'
# acme/shop

- Tests: `pytest`
- Worktree root: `~/src/acme-shop/.claude/worktrees`
R
