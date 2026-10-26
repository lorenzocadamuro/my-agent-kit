#!/usr/bin/env bash
mkdir -p wt/.plans git-out kit-data/state
cat > wt/.plans/plan.md <<'P'
# Make order totals consistent
Size: S. Boundary: totals for orders without discounts are unchanged. Bar: parts A and B done with tests.

## Parts

### Part A: rounding
- [ ] Round totals to 2 decimals in total()
- [ ] Add a test for rounding half up

### Part B: discounts
- [ ] Reject negative discounts in apply_discount()
- [ ] Add a test that drives checkout() with a discount
- [ ] Document the discount rules in docs/pricing.md
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: rounding, and the first discount step
Comments read until: none
## Items
### 1. Round totals to 2 decimals in total()
### 2. Add a test for rounding half up
### 3. Reject negative discounts in apply_discount()
P
cat > wt/.plans/round-1-summary.md <<'P'
# Round 1 summary
HEAD before: a1b2c3d · HEAD after: e5f6a7b · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | c0ffee1 | |
| 2 | done | d00d1e2 | |
| 3 | done | e5f6a7b | |
## Verification
- Tests: pytest tests/test_pricing.py → 14 passed
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature [ahead 3]
$ git log --oneline origin/feature..HEAD
e5f6a7b Round 1 item 3: reject negative discounts
d00d1e2 Round 1 item 2: test rounding half up
c0ffee1 Round 1 item 1: round totals
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
P
cat > kit-data/state/acme-shop-feature.json <<'P'
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","updatedAt":"2026-01-10T09:00:00Z","mode":"round","plan":{"title":"Make order totals consistent","path":"./wt/.plans/plan.md"},"parts":[{"title":"Part A: rounding","status":"running","done":0,"total":2},{"title":"Part B: discounts","status":"todo","done":0,"total":3}],"round":1,"step":"execute","state":"running","reason":null,"rounds":[{"n":1,"startedAt":"2026-01-10T08:30:00Z"}],"pr":null}
P
