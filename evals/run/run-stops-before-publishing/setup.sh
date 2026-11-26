#!/usr/bin/env bash
mkdir -p wt/.plans wt/shop wt/tests git-out kit-data/state
: > wt/conftest.py
cat > wt/shop/pricing.py <<'P'
def apply_discount(total: float, discount: float) -> float:
    if not 0 <= discount <= 1:
        raise ValueError("discount out of range")
    return round(total * (1 - discount), 2)
P
cat > wt/tests/test_pricing.py <<'P'
import pytest
from shop.pricing import apply_discount


@pytest.mark.parametrize("discount", [-1, -0.01, 1.01, 2, 100])
def test_out_of_range_discount_rejected(discount):
    with pytest.raises(ValueError):
        apply_discount(100.0, discount)


@pytest.mark.parametrize("total, discount, expected", [(100.0, 0, 100.0), (19.99, 0, 19.99), (100.0, 0.25, 75.0), (100.0, 1, 0.0)])
def test_in_range_discount(total, discount, expected):
    assert apply_discount(total, discount) == expected
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

## Steps
- [ ] Reject discounts outside [0, 1] in apply_discount() — test first: test_out_of_range_discount_rejected
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
$ git show --stat --format=%h HEAD
c0ffee1
 shop/pricing.py       |  2 ++
 tests/test_pricing.py | 13 +++++++++++++
 2 files changed, 15 insertions(+)
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
$ git remote get-url origin
git@github.com:acme/shop.git
$ gh pr view --json number
no pull requests found for branch "feature"
P
cat > kit-data/state/acme-shop-feature.json <<'P'
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","startedAt":"2026-01-10T07:00:00Z","updatedAt":"2026-01-10T09:00:00Z","mode":"run","plan":{"title":"Validate discounts","path":"./wt/.plans/plan.md"},"parts":[{"title":"Validate discounts","short":"Validate","status":"running","done":0,"total":1,"steps":[{"label":"Reject range","status":"running"}]}],"round":1,"step":"execute","items":{"done":1,"total":1},"state":"running","reason":null,"rounds":[{"n":1,"startedAt":"2026-01-10T08:30:00Z"}],"pr":null}
P
