#!/usr/bin/env bash
mkdir -p wt/.plans git-out kit-data
cat > wt/.plans/plan.md <<'P'
# Make order totals consistent
Size: S. Boundary: totals for orders without discounts are unchanged. Bar: items 1-3 of round 1 done with tests.
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: consistent totals
## Items
### 1. Round totals to 2 decimals in total()
### 2. Reject negative discounts in apply_discount()
### 3. Add a test that drives checkout() with a discount
P
cat > wt/.plans/round-1-summary.md <<'P'
# Round 1 summary
HEAD before: a1b2c3d · HEAD after: e5f6a7b · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | c0ffee1 | |
| 2 | done | e5f6a7b | |
## Verification
- Tests: pytest tests/test_pricing.py → 12 passed
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature [ahead 2]
$ git log --oneline origin/feature..HEAD
e5f6a7b Round 1 item 2: reject negative discounts
c0ffee1 Round 1 item 1: round totals
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
P
