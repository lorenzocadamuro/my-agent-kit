#!/usr/bin/env bash
mkdir -p wt/.plans wt/shop git-out kit-data/state
cat > wt/shop/edge.py <<'P'
from shop.queue import enqueue


def handle_save(request) -> None:
    pop = request.headers.get("X-Edge-Pop", "unknown")  # e.g. "fra2": the edge site that served the request
    request.log_fields["pop"] = pop
    enqueue("save_draft", {"key": request.json["key"], "body": request.json["body"]})
P
cat > wt/shop/store_worker.py <<'P'
import os

from shop.events import emit

STORE_POP = os.environ.get("STORE_POP", "iad1")  # the site where this worker runs


def save_draft(job: dict) -> None:
    # ... writes the draft to the database ...
    emit("draft.saved", {"key": job["key"]})
P
cat > wt/.plans/plan.md <<'P'
# Save events say where the save came from
Size: S. Boundary: save events keep their current fields. Bar: parts A and B done with tests.

## Goal
`draft.saved` carries `pop`.

## Decisions

| Date | Kind | Decision | Why |
| --- | --- | --- | --- |
| 2026-01-08 | K3 | pop from the edge request | the saves-by-region dashboard groups saves by it |

## Parts

### Part A: read the pop
- [x] Read `pop` from the edge request headers in handle_save()

### Part B: save events
- [ ] Add `pop` to the save events
P
cat > wt/.plans/round-1-summary.md <<'P'
# Round 1 summary
HEAD before: a1b2c3d · HEAD after: c0ffee1 · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | c0ffee1 | |
## Verification
- Tests: pytest tests/ → 8 passed
P
cat > wt/.plans/round-1-review.md <<'P'
# Round 1 review
Verdict: not met: Part B is left.
## Block
## Ticket
## Note
P
cat > wt/.plans/round-2.md <<'P'
# Round 2: pop on save events
Comments read until: none
Triage check: skipped (size S)
## Items
### 1. Add pop to the draft.saved events
- Source: plan, Part B. Plan step: Pop on events (implements).
P
cat > wt/.plans/round-2-summary.md <<'P'
# Round 2 summary
HEAD before: c0ffee1 · HEAD after: c0ffee1 · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | stopped | none | question below |
## Decisions taken alone
None.
## Verification
- Tests: pytest tests/ → 8 passed
## Stops and questions for the coordinator
- Item 1: the request's pop does not reach the store (save_draft runs in the store worker, the job has no pop). Drop pop, or use the store's own pop (STORE_POP)?
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature [ahead 1]
$ git log --oneline origin/feature..HEAD
c0ffee1 Round 1 item 1: read the pop in handle_save
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
$ git remote get-url origin
git@github.com:acme/shop.git
P
cat > kit-data/state/acme-shop-feature.json <<'P'
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","startedAt":"2026-01-10T07:00:00Z","updatedAt":"2026-01-10T10:00:00Z","mode":"run","plan":{"title":"Save events say where the save came from","path":"./wt/.plans/plan.md"},"parts":[{"title":"Part A: read the pop","short":"Read pop","status":"done","done":1,"total":1,"steps":[{"label":"Read pop","status":"done"}]},{"title":"Part B: save events","short":"Save events","status":"running","done":0,"total":1,"steps":[{"label":"Pop on events","status":"running"}]}],"round":2,"step":"execute","items":{"done":0,"total":1},"state":"running","reason":null,"rounds":[{"n":1,"startedAt":"2026-01-10T08:30:00Z","endedAt":"2026-01-10T09:10:00Z","verdict":"not met"},{"n":2,"startedAt":"2026-01-10T09:40:00Z"}],"pr":null}
P
