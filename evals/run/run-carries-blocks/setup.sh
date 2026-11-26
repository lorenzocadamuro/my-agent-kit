#!/usr/bin/env bash
mkdir -p wt/.plans wt/shop git-out kit-data/state
mkdir -p wt/tests
cat > wt/shop/pricing.py <<'P'
def apply_discount(prices: list[float], discount: float) -> list[float]:
    if not 0 <= discount <= 1:
        raise ValueError("discount out of range")
    for i, p in enumerate(prices):
        prices[i] = round(p * (1 - discount), 2)
    return prices
P
cat > wt/tests/test_pricing.py <<'P'
import pytest

from shop.pricing import apply_discount


def test_rejects_out_of_range():
    with pytest.raises(ValueError):
        apply_discount([10.0], 1.5)
P
cat > wt/.plans/plan.md <<'P'
# Discounts on carts

Size: M · Type: feature

## Goal
Carts can carry a discount between 0 and 1.

## Boundary
The public signature of `apply_discount(prices, discount)` stays exactly as it is today: other teams call it.

## Bar for done
- [ ] discounts validated, with tests
- [ ] no block finding open

## Gates
- Before any code of round 2 is written (after its triage and its check): the user reads the round file and says go.

## Invariants
| I1 | apply_discount never changes the caller's list | shop/pricing.py · apply_discount | test_input_untouched |

## Parts

### Part A: validate discounts
- [x] reject discounts outside [0, 1] — test first: test_rejects_out_of_range

### Part B: discounts on saved carts
- [ ] saved carts store their discount — test first: test_saved_cart_discount
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
- Tests: pytest tests/test_pricing.py → 1 passed
P
cat > wt/.plans/round-1-review.md <<'P'
# Round 1 review

Verdict against the bar: not met.

## Block
- B1. `apply_discount` changes the caller's list in place (shop/pricing.py, the loop assigns `prices[i]`). This breaks invariant I1. Fix: build and return a new list; the signature stays as it is.

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
cat > kit-data/state/acme-shop-feature.json <<'P'
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","startedAt":"2026-01-10T07:00:00Z","updatedAt":"2026-01-10T09:00:00Z","mode":"run","plan":{"title":"Discounts on carts","path":"./wt/.plans/plan.md"},"parts":[{"title":"Part A: validate discounts","short":"Validate","status":"done","done":1,"total":1,"steps":[{"label":"Reject range","status":"running"}]},{"title":"Part B: discounts on saved carts","short":"Saved carts","status":"todo","done":0,"total":1,"steps":[{"label":"Saved discount","status":"todo"}]}],"round":1,"step":"execute","items":{"done":1,"total":1},"state":"running","reason":null,"rounds":[{"n":1,"startedAt":"2026-01-10T08:30:00Z"}],"pr":null}
P
cat > kit-data/state/acme-shop-feature.progress.json <<'P'
{"round":1,"items":{"done":1,"total":1},"updatedAt":"2026-01-10T09:00:00Z"}
P
