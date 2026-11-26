#!/usr/bin/env bash
mkdir -p wt/.plans kit-data/state kit-data/retros
cat > wt/.plans/plan.md <<'P'
# Make order totals consistent
Size: S. Boundary: totals for orders without discounts are unchanged. Bar: parts A and B done with tests.

## Parts

### Part A: rounding
- [x] Round totals to 2 decimals in total()
- [x] Add a test for rounding half up

### Part B: discounts
- [x] Reject negative discounts in apply_discount()
- [x] Add a test that drives checkout() with a discount
P
cat > wt/.plans/round-2-review.md <<'P'
# Round 2 review
Verdict: the bar is met. Parts A and B are done, with tests.
## Block
none
## Ticket
none
## Note
none
P
cat > kit-data/retros/acme-shop-feature.md <<'P'
# Retrospective: consistent totals
Rounds: 2. No rework.
P
cat > kit-data/state/acme-shop-feature.json <<'P'
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","updatedAt":"2026-01-10T09:00:00Z","mode":"round","plan":{"title":"Make order totals consistent","path":"./wt/.plans/plan.md"},"parts":[{"title":"Part A: rounding","status":"done","done":2,"total":2,"left":[]},{"title":"Part B: discounts","status":"done","done":2,"total":2,"left":[]}],"round":2,"step":"report","state":"needs_you","reason":"PR description","rounds":[{"n":1,"startedAt":"2026-01-10T07:00:00Z","endedAt":"2026-01-10T07:40:00Z"},{"n":2,"startedAt":"2026-01-10T08:00:00Z","endedAt":"2026-01-10T08:50:00Z"}],"pr":88}
P
