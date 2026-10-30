#!/usr/bin/env bash
mkdir -p wt/.plans git-out kit-data/state
cat > wt/.plans/plan.md <<'P'
# Billing webhooks survive retries
Size: S. Boundary: webhooks that arrive on time are processed as today. Bar: parts A, B and C done with tests.

## Parts

### Part A: Reconciliation of duplicated settlement notifications from the processor
- [x] Drop a settlement notification whose id was already processed

### Part B: The billing worker tells a late webhook apart from a transport failure
- [x] Classify a webhook older than 10 minutes as late, not failed
- [ ] Log late webhooks with their delay in seconds

### Part C: Idempotent refund replays across processor outages
- [ ] Replay a refund only when no refund with its idempotency key exists
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
- Tests: pytest tests/ → 14 passed
P
cat > wt/.plans/round-1-review.md <<'P'
# Round 1 review
Verdict: not met: Part B's log step and Part C are left.
## Block
## Ticket
## Note
P
cat > wt/.plans/round-2.md <<'P'
# Round 2: log late webhooks
Comments read until: none
Triage check: skipped (size S)
## Items
### 1. Log late webhooks with their delay in seconds
- Source: plan, Part B. Plan step: Log late webhooks (implements).
P
cat > wt/.plans/round-2-summary.md <<'P'
# Round 2 summary
HEAD before: d00d1e2 · HEAD after: e11e2f3 · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | e11e2f3 | |
## Decisions taken alone
None.
## Verification
- Tests: pytest tests/ → 15 passed
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature [ahead 3]
$ git log --oneline origin/feature..HEAD
e11e2f3 Round 2 item 1: log late webhooks with their delay
d00d1e2 Round 1 item 2: classify late webhooks
c0ffee1 Round 1 item 1: drop duplicated settlement notifications
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
$ git remote get-url origin
git@github.com:acme/shop.git
P
cat > kit-data/state/acme-shop-feature.json <<'P'
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","updatedAt":"2026-01-10T10:00:00Z","mode":"round","plan":{"title":"Billing webhooks survive retries","path":"./wt/.plans/plan.md"},"parts":[{"title":"Part A: Reconciliation of duplicated settlement notifications from the processor","status":"done","done":1,"total":1,"left":[]},{"title":"Part B: The billing worker tells a late webhook apart from a transport failure","status":"running","done":1,"total":2,"left":["Log late webhooks with their delay in seconds"]},{"title":"Part C: Idempotent refund replays across processor outages","status":"todo","done":0,"total":1,"left":["Replay a refund only when no refund with its idempotency key exists"]}],"round":2,"step":"execute","state":"running","reason":null,"rounds":[{"n":1,"startedAt":"2026-01-10T08:30:00Z","endedAt":"2026-01-10T09:10:00Z","verdict":"not met"},{"n":2,"startedAt":"2026-01-10T09:40:00Z"}],"pr":null}
P
