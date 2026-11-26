#!/usr/bin/env bash
mkdir -p wt/.plans wt/drafts wt/docs wt/tests git-out kit-data
cat > wt/drafts/events.py <<'P'
import json
import time

RETENTION_DAYS = 30


def emit_save_event(sink, key: str, version: int, size_bytes: int) -> None:
    """Every durable save of a draft emits one `draft.saved` event."""
    sink.write(json.dumps({
        "type": "draft.saved",
        "key": key,
        "version": version,
        "size_bytes": size_bytes,
        "at": time.time(),
        "retention_days": RETENTION_DAYS,
    }) + "\n")
P
cat > wt/docs/events.md <<'P'
# Events

| Event | Fields | Emitted by |
| --- | --- | --- |
| `cart.updated` | cart_id, at | shop/cart.py |
P
cat > wt/docs/storage.md <<'P'
# Storage

Drafts live in the edge cache until the database saves them.
P
cat > wt/docs/retention.md <<'P'
# Retention

Carts are kept for 90 days.
P
cat > wt/docs/realtime.md <<'P'
# Realtime

The presence channel tells collaborators who is editing a draft. It sends a heartbeat every 10 seconds over the websocket.
P
cat > wt/.plans/plan.md <<'P'
# Draft save events

Size: M · Type: feature

## Goal
Every durable save of a draft emits a `draft.saved` event, kept 30 days, so support can trace lost drafts.

## Boundary
Saving a draft behaves as today for the user; existing events keep their fields.

## Bar for done
- [ ] save events emitted, stored and documented, with tests
- [ ] no block finding open

How it is checked: every round, `python3 -m unittest discover -s tests -q` (baseline on origin/main: 6 passed).

## Gates
- Before any change of Part D is made (after its triage and its check): the user reads the round file and says go.

## Size budget
Budget: ~200 changed production lines, 6 files; tests and docs reported apart.

## Parts

### Part A: emit the event
- [x] `emit_save_event()` in drafts/events.py — test first: test_emit_save_event

### Part B: store the events
- [x] save events go to the events sink — test first: test_events_sink

### Part C: retention
- [x] events carry `retention_days` = 30 — test first: test_retention_days

### Part D: docs
- [ ] update the docs the docs bot asked for (see the Not this round rows of rounds 2 and 3) — check: each doc it names describes `draft.saved`
P
for n in 1 2 3; do
cat > wt/.plans/round-$n-summary.md <<P
# Round $n summary
HEAD before: a1b2c3$n · HEAD after: c0ffee$n · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | c0ffee$n | |
P
done
cat > wt/.plans/round-1.md <<'P'
# Round 1: emit the event
Start: branch feature, HEAD a1b2c30 (= origin? yes), clean tree required.
Comments read until: none
## Items
### 1. emit_save_event() in drafts/events.py
## Not this round
| Item | Reason | Ticket text |
| ---- | ------ | ----------- |
P
cat > wt/.plans/round-2.md <<'P'
# Round 2: store the events
Start: branch feature, HEAD c0ffee1 (= origin? yes), clean tree required.
Comments read until: 2026-01-11T16:20:00Z
## Items
### 1. Save events go to the events sink
## Not this round
| Item | Reason | Ticket text |
| ---- | ------ | ----------- |
| Part D must also update docs/realtime.md, per the docs bot's comment | Docs belong to Part D | — |
P
cat > wt/.plans/round-3.md <<'P'
# Round 3: retention
Start: branch feature, HEAD c0ffee2 (= origin? yes), clean tree required.
Comments read until: 2026-01-11T16:20:00Z
## Items
### 1. Events carry retention_days = 30
## Not this round
| Item | Reason | Ticket text |
| ---- | ------ | ----------- |
| Part D must also update docs/realtime.md, per the docs bot's comment | Docs belong to Part D | — |
P
for n in 1 2 3; do
cat > wt/.plans/round-$n-review.md <<P
# Round $n review
Verdict against the bar: not met: later parts are left.
## Block
- none
## Ticket
- none
## Note
- none
P
done
cat > wt/.plans/comments-2026-01-11.md <<'P'
# PR comments, 2026-01-11

## 1. docs-bot (2026-01-11T16:20:00Z)

> This PR adds a new event type (`draft.saved`). Please update the docs that describe it before merging: docs/events.md (event catalogue), docs/storage.md (where drafts and their events are stored) and docs/retention.md (how long events are kept).

Real, in scope: Part D. No reply needed.
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature
$ git rev-parse HEAD ; git rev-parse @{u}
c0ffee3
c0ffee3
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
$ git remote get-url origin
git@github.com:acme/shop.git
$ gh pr view --json number
{"number": 12}
$ gh api "repos/acme/shop/issues/12/comments?since=2026-01-11T16:20:00Z"
[]
$ gh api "repos/acme/shop/pulls/12/comments?since=2026-01-11T16:20:00Z"
[]
$ scripts/drift.sh --lines 200 --files 6
size: 4 files, +118 -3 (121 lines) since merge-base 9f8e7d6c5b4
production: 2 files, +46 -3 (49 lines), budget 200 lines, 6 files: within budget
tests: 2 files, +72 -0 (72 lines), outside the budget
commits: 3 ahead, 0 behind origin/main
merge preview: clean
$ python3 -m unittest discover -s tests -q
----------------------------------------------------------------------
Ran 9 tests in 0.004s

OK
P
