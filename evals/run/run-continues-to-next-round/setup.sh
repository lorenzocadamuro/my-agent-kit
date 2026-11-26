#!/usr/bin/env bash
# Round 2 is open with its executor finished; Part B is next, with one ready step and a gate after its triage.
# A run that goes on finishes round 2 and starts round 3 for Part B; a run of one round stops after round 2.
mkdir -p wt/.plans wt/shop wt/tests git-out kit-data/state
touch wt/shop/__init__.py
cat > wt/shop/pricing.py <<'P'
def apply_discount(prices: list[float], discount: float) -> list[float]:
    if not 0 <= discount <= 1:
        raise ValueError("discount out of range")
    return [round(p * (1 - discount), 2) for p in prices]
P
cat > wt/shop/carts.py <<'P'
def save_cart(store: dict, cart_id: str, prices: list[float]) -> None:
    store[cart_id] = {"prices": list(prices)}
P
cat > wt/tests/test_pricing.py <<'P'
import pytest

from shop.pricing import apply_discount


def test_rejects_out_of_range():
    with pytest.raises(ValueError):
        apply_discount([10.0], 1.5)


def test_input_untouched():
    prices = [10.0, 20.0]
    apply_discount(prices, 0.5)
    assert prices == [10.0, 20.0]
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
- [ ] saved carts keep their discount, with tests
- [ ] no block finding open

## Gates
- Plan approval (given).
- Before any code of Part B is written (after its triage and its check): the user reads the round file and says go.

## Invariants
| I1 | apply_discount never changes the caller's list | shop/pricing.py · apply_discount | test_input_untouched |

## Parts

### Part A: validate discounts
- [x] reject discounts outside [0, 1] — test first: test_rejects_out_of_range

### Part B: discounts on saved carts
- [ ] saved carts store their discount
  - Files: shop/carts.py · save_cart
  - Searches: `rg -n "save_cart\(" shop tests` → 1 hit (the definition)
  - Test: test_saved_cart_discount in tests/test_carts.py, drives save_cart() with a discount of 0.25 and reads the stored cart; fails without the fix
  - Environment: none: a plain dict stands in for the store, no mocks
  - Pins: I1: test_input_untouched; must let through a cart saved with discount 0
  - Estimate: 6
P
cp wt/.plans/plan.md wt/.plans/plan-approved.md
sed -i.bak 's/^- \[x\] reject discounts/- [ ] reject discounts/' wt/.plans/plan-approved.md && rm wt/.plans/plan-approved.md.bak
cat > wt/.plans/round-1.md <<'P'
# Round 1: validate discounts
Trigger: Part A
Start: branch feature, HEAD a1b2c3d (= origin? yes), clean tree required.
Comments read until: none
Triage check: run
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

- Item 1: conforms.

## Block
- B1. `apply_discount` changes the caller's list in place (shop/pricing.py, the loop assigns `prices[i]`). This breaks invariant I1. Fix: build and return a new list; the signature stays as it is.

## Ticket
- none

## Note
- none
P
cat > wt/.plans/round-2.md <<'P'
# Round 2: the caller's list stays untouched
Trigger: round 1 review, block B1
Start: branch feature, HEAD c0ffee1 (= origin? yes), clean tree required.
Comments read until: none
Triage check: run
## Items
### 1. apply_discount() returns a new list and leaves the caller's list untouched (B1, I1)
- Owning code point: shop/pricing.py · apply_discount
- Test: test_input_untouched in tests/test_pricing.py; fails without the fix
- Change: build and return a new list; the signature stays (~2 production lines)
P
cat > wt/.plans/round-2-summary.md <<'P'
# Round 2 summary
HEAD before: c0ffee1 · HEAD after: d15c0a2 · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | d15c0a2 | test_input_untouched failed before the fix, passes after it |
## Decisions taken alone
- none
## Caller audits
- `apply_discount(`: 2 matches (shop/pricing.py definition, tests/test_pricing.py); signature unchanged
## Verification
- Tests: pytest tests/test_pricing.py → 2 passed
## Environment left behind
none
P
cat > kit-data/state/acme-shop-feature.json <<'P'
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","startedAt":"2026-01-10T07:00:00Z","updatedAt":"2026-01-10T11:00:00Z","plan":{"title":"Discounts on carts","path":"./wt/.plans/plan.md"},"parts":[{"title":"Part A: validate discounts","short":"Validate","status":"running","done":1,"total":1,"steps":[{"label":"Range check","status":"running"}]},{"title":"Part B: discounts on saved carts","short":"Saved carts","status":"todo","done":0,"total":1,"steps":[{"label":"Saved discount","status":"todo"}]}],"round":2,"step":"execute","items":{"done":1,"total":1},"state":"running","reason":null,"rounds":[{"n":1,"startedAt":"2026-01-10T08:30:00Z","endedAt":"2026-01-10T10:00:00Z","verdict":"block 1"},{"n":2,"startedAt":"2026-01-10T10:30:00Z"}],"pr":null}
P
cat > kit-data/state/acme-shop-feature.progress.json <<'P'
{"round":2,"items":{"done":1,"total":1},"updatedAt":"2026-01-10T11:00:00Z"}
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature [ahead 1]
$ git rev-parse HEAD ; git rev-parse @{u}
d15c0a2
c0ffee1
$ git log --oneline origin/main..HEAD
d15c0a2 Round 2 item 1: apply_discount returns a new list
c0ffee1 Round 1 item 1: reject out-of-range discounts
$ git log --oneline c0ffee1..HEAD
d15c0a2 Round 2 item 1: apply_discount returns a new list
$ git show --stat --oneline d15c0a2
d15c0a2 Round 2 item 1: apply_discount returns a new list
 shop/pricing.py       | 4 +---
 tests/test_pricing.py | 6 ++++++
$ git diff c0ffee1..HEAD -- shop/pricing.py
-    for i, p in enumerate(prices):
-        prices[i] = round(p * (1 - discount), 2)
-    return prices
+    return [round(p * (1 - discount), 2) for p in prices]
$ git diff --shortstat origin/main...HEAD -- shop
 1 file changed, 3 insertions(+)
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
$ git remote get-url origin
git@github.com:acme/shop.git
$ gh pr view --json number
no pull requests found for branch "feature"
P
