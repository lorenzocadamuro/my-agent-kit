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
Verdict: not met: Part B's docs step is left.
## Block
## Ticket
## Note
P
cat > wt/.plans/round-2.md <<'P'
# Round 2: Part B's docs
Comments read until: none
Triage check: skipped (size S)
## Items
### 1. docs/coupons.md documents coupon expiry
- Source: plan, Part B. Plan step: Expiry docs (implements).
P
cat > wt/.plans/round-2-summary.md <<'P'
# Round 2 summary
HEAD before: d00d1e2 · HEAD after: d00d1e2 · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | stopped | none | docs/coupons.md does not exist; question for the user below |
## Decisions taken alone
None.
## Verification
- Tests: pytest tests/ → 12 passed
## Stops and questions for the coordinator
- Item 1: docs/coupons.md does not exist. Create it (recommended), or add an expiry section to README.md?
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
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","startedAt":"2026-01-10T07:00:00Z","updatedAt":"2026-01-10T10:00:00Z","mode":"round","plan":{"title":"Refuse expired coupons","path":"./wt/.plans/plan.md"},"parts":[{"title":"Part A: expired coupons","short":"Expired coupons","status":"done","done":1,"total":1,"steps":[{"label":"Reject expired","status":"done"}]},{"title":"Part B: checkout and docs","short":"Checkout, docs","status":"running","done":1,"total":2,"steps":[{"label":"Checkout test","status":"todo"},{"label":"Expiry docs","status":"running"}]}],"round":2,"step":"execute","state":"running","reason":null,"rounds":[{"n":1,"startedAt":"2026-01-10T08:30:00Z","endedAt":"2026-01-10T09:10:00Z","verdict":"not met"},{"n":2,"startedAt":"2026-01-10T09:40:00Z"}],"pr":null}
P
