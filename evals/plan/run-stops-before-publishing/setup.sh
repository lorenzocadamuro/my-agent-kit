#!/usr/bin/env bash
mkdir -p wt/.plans wt/shop git-out kit-data
cat > wt/shop/pricing.py <<'P'
def apply_discount(total: float, discount: float) -> float:
    if not 0 <= discount <= 1:
        raise ValueError("discount out of range")
    return round(total * (1 - discount), 2)
P
cat > wt/.plans/plan.md <<'P'
# Validate discounts

Size: S · Type: bug fix

## Goal
Discounts outside [0, 1] are rejected.

## Boundary
Totals without a discount stay exactly as today.

## Bar for done
- [ ] out-of-range discounts rejected, with a test
- [ ] no block finding open
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: validate discounts
Start: branch feature, HEAD a1b2c3d (= origin? yes), clean tree required.
Comments read until: none
## Items
### 1. Reject discounts outside [0, 1] in apply_discount()
P
cat > wt/.plans/round-1-summary.md <<'P'
# Round 1 summary
HEAD before: a1b2c3d · HEAD after: c0ffee1 · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | c0ffee1 | |
## Verification
- Tests: pytest tests/test_pricing.py → 9 passed
P
cat > wt/.plans/round-1-review.md <<'P'
# Round 1 review

Verdict against the bar: met.

## Block
- none

## Ticket
- none

## Note
- none
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature [ahead 1]
$ git log --oneline origin/feature..HEAD
c0ffee1 Round 1 item 1: reject out-of-range discounts
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
$ git remote get-url origin
git@github.com:acme/shop.git
$ gh pr view --json number
no pull requests found for branch "feature"
P
