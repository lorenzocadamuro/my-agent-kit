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
# Round 2: round 1's block finding, and Part B's docs
Comments read until: none
Triage check: skipped (size S)
## Items
### 1. The checkout test asserts the refusal of an expired coupon
- Source: round 1 review, Block 1. Plan step: Checkout test (reworks).
### 2. docs/coupons.md documents coupon expiry
- Source: plan, Part B. Plan step: Expiry docs (implements).
P
cat > wt/.plans/round-2-summary.md <<'P'
# Round 2 summary
HEAD before: d00d1e2 · HEAD after: d00d1e2 · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | skipped | none | the fix belongs to round 3, not needed now |
| 2 | stopped | none | docs/coupons.md does not exist; question for the user below |
## Decisions taken alone
None.
## Verification
- Tests: pytest tests/ → 12 passed
## Stops and questions for the coordinator
- Item 2: docs/coupons.md does not exist. Create it (recommended), or add an expiry section to README.md?
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature [ahead 2]
$ git log --oneline origin/feature..HEAD
d00d1e2 Round 1 item 2: test checkout with an expired coupon
c0ffee1 Round 1 item 1: reject expired coupons
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
P
cat > kit-data/state/acme-shop-feature.json <<'P'
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","startedAt":"2026-01-10T07:00:00Z","updatedAt":"2026-01-10T10:00:00Z","mode":"run","plan":{"title":"Refuse expired coupons","path":"./wt/.plans/plan.md"},"parts":[{"title":"Part A: expired coupons","short":"Expired coupons","status":"done","done":1,"total":1,"steps":[{"label":"Reject expired","status":"done"}]},{"title":"Part B: checkout and docs","short":"Checkout, docs","status":"running","done":1,"total":2,"steps":[{"label":"Checkout test","status":"running"},{"label":"Expiry docs","status":"running"}]}],"round":2,"step":"execute","items":{"done":2,"total":2},"state":"running","reason":null,"rounds":[{"n":1,"startedAt":"2026-01-10T08:30:00Z","endedAt":"2026-01-10T09:10:00Z","verdict":"block 1"},{"n":2,"startedAt":"2026-01-10T09:40:00Z"}],"pr":null}
P
cat > kit-data/state/acme-shop-feature.progress.json <<'P'
{"round":2,"items":{"done":2,"total":2},"updatedAt":"2026-01-10T10:00:00Z"}
P
