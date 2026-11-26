#!/usr/bin/env bash
# Round 2 executed three of Part B's four steps: the part stays open after verification.
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
cat > wt/runs/routes.py <<'P'
from runs.visibility import is_visible_run


def route_rows(rows):
    """The chat's visible past runs, oldest first."""
    return sorted((r for r in rows if is_visible_run(r)), key=lambda r: r["created_at"])
P
cat > wt/pages/route.py <<'P'
from runs.routes import route_rows


def render_route(chat_id: str, rows=()) -> str:
    """The chat's route page: a heading, then one list item per past run, or a message when there is none."""
    items = "".join(f"<li>{r['title']}</li>" for r in route_rows(rows))
    return f"<h1>Route of {chat_id}</h1>" + (f"<ul>{items}</ul>" if items else "<p>No past runs yet</p>")
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
        self.assertEqual([r["created_at"] for r in route_rows(rows)], [1, 2])
P
cat > wt/tests/test_route_page.py <<'P'
import unittest

from pages.route import render_route


def run(title, created_at, status="done"):
    return {"title": title, "status": status, "deleted_at": None, "created_at": created_at}


class RoutePageTest(unittest.TestCase):
    def test_route_page_lists_rows(self):
        html = render_route("c1", [run("a", 1), run("b", 2), run("c", 3, "hidden")])
        self.assertEqual(html.count("<li>"), 2)

    def test_route_page_empty_message(self):
        self.assertIn("No past runs yet", render_route("c1", []))
P
cat > wt/.plans/plan.md <<'P'
# Show past runs on the chat's route page

Size: M · Type: feature

## Goal
The route page lists the chat's past runs.

## Boundary
`live_rows()` keeps its results.

## Bar for done
- [ ] the route page lists the chat's past runs, with tests
- [ ] no block finding open

How it is checked: every round, `python3 -m unittest discover -s tests -q` (baseline on origin/main: 0 tests).

## Invariants
| # | Statement | Holds at | Test that fails if broken |
| --- | --- | --- | --- |
| I1 | Hidden and deleted runs never show | `runs/visibility.py · is_visible_run` | `tests/test_routes.py::test_route_rows_hides_hidden_and_deleted` |

## Intentional changes
- The route page lists past runs, or says there is none.

## Out of scope
| Item | Why not now | Ticket |
| --- | --- | --- |
| Paging the route list | chats hold few runs | none: accepted |

## Size budget
Budget: ~300 changed production lines, 6 files; tests apart. Split trigger: more than 300 production lines.

## Parts

### Part A: the route page exists
- [x] empty route page

### Part B: the route page lists the chat's past runs
- [ ] `route_rows(rows)` in `runs/routes.py` returns the visible runs, oldest first, through `is_visible_run` — test: `test_route_rows_hides_hidden_and_deleted`
- [ ] `render_route` shows one list item per route row — test: `test_route_page_lists_rows`
- [ ] `render_route` says "No past runs yet" when the chat has none — test: `test_route_page_empty_message`
- [ ] the heading shows how many past runs the chat has — test: `test_route_heading_counts_runs`

### Part C: the chat page links to its route
- [ ] a "Route" link on the chat page — test: `test_chat_page_links_route`
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: the route page exists
Comments read until: none
## Items
### 1. Empty route page
P
cat > wt/.plans/round-1-review.md <<'P'
# Round 1 review
Verdict against the bar: not met yet: Part B is open.
## Block
none
P
cat > wt/.plans/round-2.md <<'P'
# Round 2: route rows on the route page

Plan: `.plans/plan.md` · Trigger: plan part B
Start: branch feature, HEAD a1b2c3d (= origin? yes), clean tree required.
Comments read until: none

## Items

### 1. `route_rows(rows)` returns the visible runs, oldest first, through `is_visible_run`
- Owning code point: `runs/routes.py · route_rows`
- Change: new function (~5 production lines)
- Test: `tests/test_routes.py::test_route_rows_hides_hidden_and_deleted`, fails without the filter

### 2. `render_route` shows one list item per route row
- Owning code point: `pages/route.py · render_route`
- Change: list the rows (~3 production lines)
- Test: `tests/test_route_page.py::test_route_page_lists_rows`, fails while the list is empty

### 3. `render_route` says "No past runs yet" when the chat has none
- Owning code point: `pages/route.py · render_route`
- Change: the empty-state message (~1 production line)
- Test: `tests/test_route_page.py::test_route_page_empty_message`, fails without the message

## Not this round

| Item | Reason | Ticket text |
| ---- | ------ | ----------- |
| Part B step 4 (heading count) | next round | none |
P
cat > wt/.plans/round-2-summary.md <<'P'
# Round 2 summary
HEAD before: a1b2c3d · HEAD after: c0ffee3 · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | c0ffee1 | callers of `is_visible_run`: 2 (runs/live.py:5, runs/routes.py:6) |
| 2 | done | c0ffee2 | |
| 3 | done | c0ffee3 | |
## Verification
- Tests: python3 -m unittest discover -s tests -q → 3 passed
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature [ahead 3]
$ git log --oneline origin/feature..HEAD
c0ffee3 Round 2 item 3: empty route message
c0ffee2 Round 2 item 2: list route rows
c0ffee1 Round 2 item 1: route_rows
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
$ git remote get-url origin
git@github.com:acme/shop.git
$ gh pr view --json number,comments,reviews
{"number": 12, "comments": [], "reviews": []}
$ scripts/verify-round.sh .plans 2
HEAD c0ffee3 · upstream a1b2c3d · items: 3
verify-round: OK
$ scripts/drift.sh --lines 300 --files 6
size: 4 files, +45 -2 (47 lines) since merge-base 9f8e7d6c5b4
production: 2 files, +12 -2 (14 lines), budget 300 lines, 6 files: within budget
tests: 2 files, +33 -0 (33 lines), outside the budget
commits: 4 ahead, 0 behind origin/main
merge preview: clean
$ git diff a1b2c3d..HEAD
diff --git a/runs/routes.py b/runs/routes.py
new file mode 100644
--- /dev/null
+++ b/runs/routes.py
@@ -0,0 +1,6 @@
+from runs.visibility import is_visible_run
+
+
+def route_rows(rows):
+    """The chat's visible past runs, oldest first."""
+    return sorted((r for r in rows if is_visible_run(r)), key=lambda r: r["created_at"])
diff --git a/pages/route.py b/pages/route.py
--- a/pages/route.py
+++ b/pages/route.py
@@ -1,3 +1,7 @@
-def render_route(chat_id: str) -> str:
-    """The chat's route page: a heading, and an empty list for now."""
-    return f"<h1>Route of {chat_id}</h1><ul></ul>"
+from runs.routes import route_rows
+
+
+def render_route(chat_id: str, rows=()) -> str:
+    """The chat's route page: a heading, then one list item per past run, or a message when there is none."""
+    items = "".join(f"<li>{r['title']}</li>" for r in route_rows(rows))
+    return f"<h1>Route of {chat_id}</h1>" + (f"<ul>{items}</ul>" if items else "<p>No past runs yet</p>")
diff --git a/tests/test_routes.py b/tests/test_routes.py
new file mode 100644
--- /dev/null
+++ b/tests/test_routes.py
@@ -0,0 +1,14 @@
+import unittest
+
+from runs.routes import route_rows
+
+
+class RoutesTest(unittest.TestCase):
+    def test_route_rows_hides_hidden_and_deleted(self):
+        rows = [
+            {"status": "done", "deleted_at": None, "created_at": 2},
+            {"status": "hidden", "deleted_at": None, "created_at": 3},
+            {"status": "done", "deleted_at": "x", "created_at": 4},
+            {"status": "done", "deleted_at": None, "created_at": 1},
+        ]
+        self.assertEqual([r["created_at"] for r in route_rows(rows)], [1, 2])
diff --git a/tests/test_route_page.py b/tests/test_route_page.py
new file mode 100644
--- /dev/null
+++ b/tests/test_route_page.py
@@ -0,0 +1,17 @@
+import unittest
+
+from pages.route import render_route
+
+
+def run(title, created_at, status="done"):
+    return {"title": title, "status": status, "deleted_at": None, "created_at": created_at}
+
+
+class RoutePageTest(unittest.TestCase):
+    def test_route_page_lists_rows(self):
+        html = render_route("c1", [run("a", 1), run("b", 2), run("c", 3, "hidden")])
+        self.assertEqual(html.count("<li>"), 2)
+
+    def test_route_page_empty_message(self):
+        self.assertIn("No past runs yet", render_route("c1", []))
P
