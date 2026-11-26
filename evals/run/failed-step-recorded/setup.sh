#!/usr/bin/env bash
mkdir -p wt/.plans git-out kit-data/state
cat > wt/.plans/plan.md <<'P'
# Refuse expired coupons
Size: S. Boundary: valid coupons redeem as today. Bar: parts A and B done with tests.

## Parts

### Part A: expired coupons
- [ ] Reject expired coupons in redeem()
- [ ] Add a test that drives checkout() with an expired coupon

### Part B: coupon docs
- [ ] Document coupon expiry in docs/coupons.md
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: expired coupons
Comments read until: none
## Items
### 1. Reject expired coupons in redeem()
### 2. Add a test that drives checkout() with an expired coupon
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
- Tests: pytest tests/ → 12 passed, 2 failed
  - FAILED tests/test_checkout.py::test_checkout_rejects_expired_coupon
  - FAILED tests/test_checkout.py::test_checkout_expired_coupon_message
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature [ahead 2]
$ git log --oneline origin/feature..HEAD
d00d1e2 Round 1 item 2: test checkout with an expired coupon
c0ffee1 Round 1 item 1: reject expired coupons
$ git show --stat --oneline c0ffee1
c0ffee1 Round 1 item 1: reject expired coupons
 shop/coupons.py           | 6 ++++++
 tests/test_coupons.py     | 9 +++++++++
$ git show --stat --oneline d00d1e2
d00d1e2 Round 1 item 2: test checkout with an expired coupon
 tests/test_checkout.py    | 21 +++++++++++++++++++++
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
P
cat > kit-data/state/acme-shop-feature.json <<'P'
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","startedAt":"2026-01-10T07:00:00Z","updatedAt":"2026-01-10T09:00:00Z","mode":"run","plan":{"title":"Refuse expired coupons","path":"./wt/.plans/plan.md"},"parts":[{"title":"Part A: expired coupons","short":"Expired coupons","status":"running","done":0,"total":2,"steps":[{"label":"Reject expired","status":"running"},{"label":"Checkout test","status":"running"}]},{"title":"Part B: coupon docs","short":"Coupon docs","status":"todo","done":0,"total":1,"steps":[{"label":"Expiry docs","status":"todo"}]}],"round":1,"step":"execute","items":{"done":2,"total":2},"state":"running","reason":null,"rounds":[{"n":1,"startedAt":"2026-01-10T08:30:00Z"}],"pr":null}
P
cat > kit-data/state/acme-shop-feature.progress.json <<'P'
{"round":1,"items":{"done":2,"total":2},"updatedAt":"2026-01-10T09:00:00Z"}
P
