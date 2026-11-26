#!/usr/bin/env bash
mkdir -p wt/.plans git-out kit-data/state
cat > wt/.plans/plan.md <<'P'
# Refuse expired coupons
Size: S. Boundary: valid coupons redeem as today. Bar: parts A and B done with tests.

## Parts

### Part A: expired coupons
- [x] Reject expired coupons in redeem()

### Part B: checkout and docs
- [x] Add a test that drives checkout() with an expired coupon
- [ ] Document coupon expiry in docs/coupons.md
P
cat > wt/.plans/round-1-summary.md <<'P'
# Round 1 summary
HEAD before: a1b2c3d · HEAD after: d00d1e2 · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | c0ffee1 | |
| 2 | done | d00d1e2 | |
## Verification
- Tests: pytest tests/ → 12 passed
P
cat > wt/.plans/round-1-review.md <<'P'
# Round 1 review
Verdict: not met.
## Block
1. tests/test_checkout.py:14: the expired-coupon checkout test checks the status code only, so it passes even when checkout() accepts an expired coupon. Fix: assert the refusal and its message.
## Ticket
## Note
P
cat > wt/.plans/round-2.md <<'P'
# Round 2: round 1's block finding
Comments read until: none
Triage check: skipped (size S)
## Items
### 1. The checkout test asserts the refusal of an expired coupon
- Source: round 1 review, Block 1. Plan step: Checkout test (reworks).
P
cat > wt/.plans/round-2-summary.md <<'P'
# Round 2 summary
HEAD before: d00d1e2 · HEAD after: f1e2d3c · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | f1e2d3c | the checkout test asserts the refusal and its message |
## Decisions taken alone
None.
## Verification
- Tests: pytest tests/ → 12 passed, 1 failed
  - FAILED tests/test_checkout.py::test_checkout_rejects_expired_coupon
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature [ahead 3]
$ git log --oneline origin/feature..HEAD
f1e2d3c Round 2 item 1: the checkout test asserts the refusal of an expired coupon
d00d1e2 Round 1 item 2: test checkout with an expired coupon
c0ffee1 Round 1 item 1: reject expired coupons
$ git show --stat --oneline f1e2d3c
f1e2d3c Round 2 item 1: the checkout test asserts the refusal of an expired coupon
 tests/test_checkout.py    | 8 ++++++--
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
P
cat > kit-data/state/acme-shop-feature.json <<'P'
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","startedAt":"2026-01-10T07:00:00Z","updatedAt":"2026-01-10T10:00:00Z","mode":"round","plan":{"title":"Refuse expired coupons","path":"./wt/.plans/plan.md"},"parts":[{"title":"Part A: expired coupons","short":"Expired coupons","status":"done","done":1,"total":1,"steps":[{"label":"Reject expired","status":"done"}]},{"title":"Part B: checkout and docs","short":"Checkout, docs","status":"running","done":1,"total":2,"steps":[{"label":"Checkout test","status":"running"},{"label":"Expiry docs","status":"todo"}]}],"round":2,"step":"execute","state":"running","reason":null,"rounds":[{"n":1,"startedAt":"2026-01-10T08:30:00Z","endedAt":"2026-01-10T09:10:00Z","verdict":"block 1"},{"n":2,"startedAt":"2026-01-10T09:40:00Z"}],"pr":null}
P
