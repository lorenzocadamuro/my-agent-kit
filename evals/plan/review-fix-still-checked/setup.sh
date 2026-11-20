#!/usr/bin/env bash
mkdir -p wt/.plans wt/runs wt/pages wt/tests git-out kit-data
touch wt/runs/__init__.py wt/pages/__init__.py
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
cat > wt/pages/route.py <<'P'
def render_route(chat_id: str) -> str:
    """The chat's route page: a heading, and an empty list for now."""
    return f"<h1>Route of {chat_id}</h1><ul></ul>"
P
cat > wt/tests/test_live.py <<'P'
import unittest

from runs.live import live_rows


class LiveTest(unittest.TestCase):
    def test_live_rows_unchanged(self):
        rows = [{"status": "done", "deleted_at": None}, {"status": "hidden", "deleted_at": None}]
        self.assertEqual(live_rows(rows), [rows[0]])
P
cat > wt/runs/routes.py <<'P'
from runs.visibility import is_visible_run


def route_rows(rows):
    """The chat's visible past runs, oldest first."""
    return sorted((r for r in rows if is_visible_run(r)), key=lambda r: r["created_at"], reverse=True)
P
cat > wt/tests/test_routes.py <<'P'
import unittest

from runs.routes import route_rows


class RoutesTest(unittest.TestCase):
    def test_route_rows_hides_hidden_and_deleted(self):
        rows = [
            {"status": "done", "deleted_at": None, "created_at": 2},
            {"status": "hidden", "deleted_at": None, "created_at": 3},
            {"status": "done", "deleted_at": "x", "created_at": 4},
            {"status": "done", "deleted_at": None, "created_at": 1},
        ]
        self.assertEqual([r["created_at"] for r in route_rows(rows)], [2, 1])
P
cat > wt/tests/test_route_page.py <<'P'
import unittest

from pages.route import render_route


class RoutePageTest(unittest.TestCase):
    def test_empty_route_page(self):
        self.assertIn("<h1>Route of c1</h1>", render_route("c1"))
P
cat > wt/.plans/plan.md <<'P'
# Show past runs on the chat's route page

Size: M · Type: feature

## Goal
The route page lists the chat's past runs next to the live ones.

## Boundary
`live_rows()` keeps its results.

## Bar for done
- [ ] route rows listed on the route page, with tests
- [ ] no block finding open

How it is checked: every round, `python3 -m unittest discover -s tests -q` (baseline on origin/main: 2 passed).

## Invariants
| # | Statement | Holds at | Test that fails if broken |
| --- | --- | --- | --- |
| I1 | Hidden and deleted runs never show | `runs/visibility.py · is_visible_run` | `tests/test_routes.py::test_route_rows_hides_hidden_and_deleted` |

## Intentional changes
- The route page lists past runs.

## Out of scope
| Item | Why not now | Ticket |
| --- | --- | --- |
| Paging the route list | chats hold few runs | none: accepted |

## Size budget
Budget: ~300 changed production lines, 6 files; tests apart. Split trigger: more than 300 production lines.

## Parts

### Part A: the route page exists
- [x] empty route page — test: tests/test_route_page.py

### Part B: the route page lists the chat's past runs
- [x] `route_rows(rows)` returns the chat's visible past runs, oldest first
  - Files: `runs/routes.py` (new) · `route_rows`, the owning code point; it calls `runs/visibility.py · is_visible_run`
  - Searches: `grep -rn "is_visible_run" runs pages` → 3 hits (runs/visibility.py:1, runs/live.py:1, runs/live.py:5); `grep -rn "route_rows" runs pages tests` → 0 hits
  - Test: `tests/test_routes.py::test_route_rows_hides_hidden_and_deleted` (unittest, as `tests/test_live.py`): calls `route_rows` with a hidden, a deleted and two visible rows in reverse order, asserts the two visible ones oldest first; fails without the filter
  - Environment: plain Python 3, no provider, no mock; the rows are dicts built in the test
  - Pins: boundary `live_rows()` keeps its results: `tests/test_live.py::test_live_rows_unchanged` (passes today, must keep passing); I1: the same test as Test
  - Estimate: ~8 production lines
- [ ] `render_route` shows one list item per route row
  - Files: `pages/route.py · render_route`, the owning code point
  - Searches: `grep -rn "render_route" runs pages tests` → 3 hits (pages/route.py:1, tests/test_route_page.py:3, tests/test_route_page.py:8)
  - Test: `tests/test_route_page.py::test_route_page_lists_rows` (unittest): renders a chat with two visible runs and one hidden run, asserts two `<li>` items; fails while the list is empty
  - Environment: plain Python 3; rows passed in by the test through `render_route(chat_id, rows)`
  - Pins: `tests/test_route_page.py::test_empty_route_page` keeps passing (a chat with no runs)
  - Estimate: ~6 production lines

## Decisions
| # | Date | Kind | Recommended | Chosen | Why |
| --- | --- | --- | --- | --- | --- |
| D1 | 2026-11-01 | none | Reuse `is_visible_run` | from the request | one owner for visibility |
P
cp wt/.plans/plan.md wt/.plans/plan-approved.md
sed -i.bak -e "s/^- \[x\] empty route page/- [ ] empty route page/" -e "s/^- \[x\] .route_rows/- [ ] \`route_rows/" wt/.plans/plan-approved.md && rm wt/.plans/plan-approved.md.bak
cat > wt/.plans/round-1.md <<'P'
# Round 1: the route page exists
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
cat > wt/.plans/round-2.md <<'P'
# Round 2: route rows
Comments read until: none
## Items
### 1. `route_rows(rows)` returns the chat's visible past runs, oldest first
P
cat > wt/.plans/round-2-summary.md <<'P'
# Round 2 summary
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | c0ffee1 | |
P
cat > wt/.plans/round-2-review.md <<'P'
# Round 2 review
Verdict against the bar: not met: one block finding.
## Block
1. `runs/routes.py:6`: `route_rows` sorts newest first (`reverse=True`), while the plan's step says oldest first; `test_route_rows_hides_hidden_and_deleted` asserts `[2, 1]`, so it pins the wrong order. Fix: sort oldest first, and assert `[1, 2]`.
## Ticket
none
## Note
none
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
size: 4 files, +40 -0 (40 lines) since merge-base 9f8e7d6c5b4
production: 2 files, +10 -0 (10 lines), budget 300 lines, 6 files: within budget
tests: 2 files, +30 -0 (30 lines), outside the budget
commits: 2 ahead, 0 behind origin/main
merge preview: clean
GITOUT
