#!/usr/bin/env bash
# A round of a small plan whose executor has finished; this session's signals file holds one pending
# signal, so the round's closing step must turn it into a note in ./kit-data/suite-log.md.
mkdir -p wt/.plans git-out kit-data/state kit-data/signals
cat > wt/.plans/plan.md <<'P'
# Make order totals consistent
Size: S. Boundary: totals for orders without discounts are unchanged. Bar: parts A and B done with tests.

## Gates
- After the round that finishes Part A (after its report): the user checks the rounded totals on staging and says go.

## Parts

### Part A: rounding
- [ ] Round totals to 2 decimals in total()
- [ ] Add a test for rounding half up

### Part B: discounts
- [ ] Reject negative discounts in apply_discount()
- [ ] Add a test that drives checkout() with a discount
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: rounding
Comments read until: none
## Items
### 1. Round totals to 2 decimals in total()
### 2. Add a test for rounding half up
P
cat > wt/.plans/round-1-summary.md <<'P'
# Round 1 summary
HEAD before: a1b2c3d · HEAD after: d00d1e2 · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | c0ffee1 | |
| 2 | done | d00d1e2 | rewritten twice: the round file did not say which rounding mode the test pins |
## Verification
- Tests: pytest tests/test_pricing.py → 12 passed
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature [ahead 2]
$ git log --oneline origin/feature..HEAD
d00d1e2 Round 1 item 2: test rounding half up
c0ffee1 Round 1 item 1: round totals
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
P
cat > kit-data/signals/acme-shop-feature.md <<'P'
# Signals: acme/shop · feature

- 2026-01-10 09:20 · rework · plan:round · Item 2's test was rewritten twice: the round file did not say which rounding mode the test pins. · round 1 summary · kit 7.3.0
P
cat > kit-data/state/acme-shop-feature.json <<'P'
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","startedAt":"2026-01-10T07:00:00Z","updatedAt":"2026-01-10T09:00:00Z","mode":"run","plan":{"title":"Make order totals consistent","path":"./wt/.plans/plan.md"},"parts":[{"title":"Part A: rounding","short":"Rounding","status":"running","done":0,"total":2,"steps":[{"label":"Round totals","status":"todo"},{"label":"Rounding test","status":"todo"}]},{"title":"Part B: discounts","short":"Discounts","status":"todo","done":0,"total":2,"steps":[{"label":"Negative discounts","status":"todo"},{"label":"Checkout test","status":"todo"}]}],"round":1,"step":"execute","items":{"done":2,"total":2},"state":"running","reason":null,"rounds":[{"n":1,"startedAt":"2026-01-10T08:30:00Z"}],"pr":null}
P
cat > kit-data/state/acme-shop-feature.progress.json <<'P'
{"round":1,"items":{"done":2,"total":2},"updatedAt":"2026-01-10T09:00:00Z"}
P
