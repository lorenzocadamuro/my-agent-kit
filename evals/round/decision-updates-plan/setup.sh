#!/usr/bin/env bash
mkdir -p wt/.plans wt/placement wt/tests git-out kit-data
cat > wt/placement/records.py <<'P'
import time

RECORDS: dict[str, dict] = {}


def release(record_id: str) -> None:
    """Releases a placement record. A released record never takes a slot again."""
    RECORDS[record_id]["released_at"] = time.time()


def can_reuse(record_id: str) -> bool:
    return "released_at" not in RECORDS[record_id]
P
cat > wt/.plans/plan.md <<'P'
# Released placement records stay bounded

Size: M · Type: bug fix

## Goal
The store of placement records stops growing without bound.

## Boundary
A release is final at any delay: a released record never takes a slot again, whatever happens after it.

## Bar for done
- [ ] released records are swept, with tests
- [ ] no block finding open

## Invariants

| #  | Statement | Holds at (file · function) | Test that fails if broken |
| -- | --------- | -------------------------- | ------------------------- |
| I1 | A sweep deletes only released records | placement/records.py · sweep | test_sweep_keeps_live |
| I2 | A release is final at any delay | placement/records.py · can_reuse | test_released_never_reused |

## Existing vs new behaviour

| Behaviour | Today | After |
| --------- | ----- | ----- |
| A released record is reused | never, at any delay (`can_reuse`, test_released_never_reused) | never, at any delay |

## Intentional changes

- Released records are deleted by a sweep — operators see a smaller store.

## Parts

### Part A: sweep
- [x] sweep released records — test first: test_sweep_keeps_live

### Part B: late reuse (gate: Q1 decides it)
- [ ] apply Q1's answer to `can_reuse` — test first: test_late_reuse

## Decisions

| #  | Date       | Kind | Recommended | Chosen | Why |
| -- | ---------- | ---- | ----------- | ------ | --- |
| D1 | 2026-10-20 | K1   | sweep daily | sweep daily | cheap, enough |

## Open questions

- Q1: can a record released long ago take a slot again? — owner: the user, needed by Part B
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: sweep
Start: branch feature, HEAD a1b2c3d (= origin? yes), clean tree required.
Comments read until: none
## Items
### 1. Sweep released records
P
cat > wt/.plans/round-1-summary.md <<'P'
# Round 1 summary
HEAD before: a1b2c3d · HEAD after: c0ffee1 · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | c0ffee1 | |
P
cat > wt/.plans/round-1-review.md <<'P'
# Round 1 review
Verdict against the bar: Part A meets it.
## Block
- none
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature
$ git rev-parse HEAD ; git rev-parse @{u}
c0ffee1
c0ffee1
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
$ git remote get-url origin
git@github.com:acme/placement.git
$ gh pr view --json number,comments,reviews
{"number": 7, "comments": [], "reviews": []}
$ scripts/drift.sh --lines 400 --files 8
production: 1 files, +40 -0 (40 lines), budget 400 lines, 8 files: within budget
tests: 1 files, +30 -0 (30 lines), outside the budget
commits: 1 ahead, 0 behind origin/main
merge preview: clean
P
