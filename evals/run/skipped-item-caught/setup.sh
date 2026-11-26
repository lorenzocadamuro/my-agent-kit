#!/usr/bin/env bash
mkdir -p wt/.plans git-out kit-data/state
cat > wt/.plans/plan.md <<'P'
# Make order totals consistent
Boundary: totals for orders without discounts are unchanged. Bar: items 1-3 of round 1 done with tests.
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: consistent totals
Triage check: run
Comments read until: none
## Items
### 1. Round totals to 2 decimals in total()
### 2. Reject negative discounts in apply_discount()
### 3. Add a test that drives checkout() with a discount
P
cat > wt/.plans/round-1-summary.md <<'P'
# Round 1 summary
HEAD before: a1b2c3d · HEAD after: e5f6a7b · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | c0ffee1 | |
| 2 | done | e5f6a7b | |
## Verification
- Tests: pytest tests/test_pricing.py → 12 passed
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature [ahead 2]
$ git log --oneline origin/feature..HEAD
e5f6a7b Round 1 item 2: reject negative discounts
c0ffee1 Round 1 item 1: round totals
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
$ git remote get-url origin
git@github.com:acme/shop.git
P
cat > kit-data/state/acme-shop-feature.json <<'P'
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","startedAt":"2026-01-10T07:00:00Z","updatedAt":"2026-01-10T09:00:00Z","mode":"run","plan":{"title":"Make order totals consistent","path":"./wt/.plans/plan.md"},"parts":[{"title":"Make order totals consistent","short":"Order totals","status":"running","done":0,"total":0,"steps":[]}],"round":1,"step":"execute","items":{"done":2,"total":3},"state":"running","reason":null,"rounds":[{"n":1,"startedAt":"2026-01-10T08:30:00Z"}],"pr":null}
P
cat > kit-data/state/acme-shop-feature.progress.json <<'P'
{"round":1,"items":{"done":2,"total":3},"updatedAt":"2026-01-10T09:00:00Z"}
P
