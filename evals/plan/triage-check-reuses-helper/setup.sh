#!/usr/bin/env bash
mkdir -p wt/.plans wt/runs wt/tests git-out kit-data
cat > wt/runs/visibility.py <<'P'
def is_visible_run(row) -> bool:
    """A run row the user may see: not hidden by its owner, not deleted."""
    return row["status"] != "hidden" and row["deleted_at"] is None
P
cat > wt/runs/live.py <<'P'
from runs.visibility import is_visible_run


def live_rows(rows):
    return [r for r in rows if is_visible_run(r)]
P
cat > wt/.plans/plan.md <<'P'
# Show past runs on the chat's route page

Size: M · Type: feature

## Goal
The route page lists the chat's past runs next to the live ones.

## Boundary
`live_rows()` keeps its results.

## Bar for done
- [ ] route rows listed, with tests
- [ ] no block finding open

How it is checked: every round, `python3 -m unittest discover -s tests -q` (baseline on origin/main: 3 passed).

## Size budget
Budget: ~300 changed production lines, 6 files; tests apart. Split trigger: more than 300 production lines.

## Parts

### Part A: route page shell
- [x] empty route page — test first: test_route_page

### Part B: route rows
- [ ] `route_rows(rows)` in a new `runs/routes.py`: keep the rows whose status is not "hidden" and whose deleted_at is None, sorted by created_at — test first: test_route_rows
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: route page shell
Comments read until: none
## Items
### 1. Empty route page
P
cat > wt/.plans/round-1-review.md <<'P'
# Round 1 review
Verdict against the bar: Part A meets it.
## Block
- none
P
cat > git-out/git.txt <<'GITOUT'
$ git status --short --branch
## feature...origin/feature
$ git rev-parse HEAD ; git rev-parse @{u}
c0ffee1
c0ffee1
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
$ git remote get-url origin
git@github.com:acme/shop.git
$ gh pr view --json number,comments,reviews
{"number": 12, "comments": [], "reviews": []}
$ scripts/drift.sh --lines 300 --files 6
size: 2 files, +60 -0 (60 lines) since merge-base 9f8e7d6c5b4
production: 1 files, +30 -0 (30 lines), budget 300 lines, 6 files: within budget
tests: 1 files, +30 -0 (30 lines), outside the budget
commits: 1 ahead, 0 behind origin/main
merge preview: clean
GITOUT
