#!/usr/bin/env bash
mkdir -p wt/.plans wt/reports wt/tests git-out kit-data/state
touch wt/reports/__init__.py
cat > wt/reports/orders.py <<'P'
from dataclasses import dataclass


@dataclass
class Order:
    id: int
    customer: str
    total_cents: int
    status: str


ORDERS: list[Order] = []


def list_orders(status: str | None = None) -> list[Order]:
    return [o for o in ORDERS if status is None or o.status == status]
P
cat > wt/reports/export.py <<'P'
import csv

from reports.orders import Order

HEADER = ["id", "customer", "total", "status"]


def export_csv(orders: list[Order], out) -> None:
    writer = csv.writer(out)
    writer.writerow(HEADER)
    for o in orders:
        writer.writerow([o.id, o.customer, f"{o.total_cents / 100:.2f}", o.status])
P
cat > wt/reports/reconcile.py <<'P'
import csv


def reconcile_csv(export_file, statement_rows: list[dict]) -> dict:
    """Match an export_csv file against the payment provider's statement rows ({"id", "amount"})."""
    exported = {int(r["id"]): round(float(r["total"]) * 100) for r in csv.DictReader(export_file)}
    statement = {int(r["id"]): round(float(r["amount"]) * 100) for r in statement_rows}
    return {
        "missing_from_statement": sorted(set(exported) - set(statement)),
        "unknown_in_statement": sorted(set(statement) - set(exported)),
        "amount_differs": sorted(i for i in exported.keys() & statement.keys() if abs(exported[i] - statement[i]) > 1),
    }
P
cat > wt/tests/test_reports.py <<'P'
import io
import unittest

from reports.export import export_csv
from reports.orders import Order
from reports.reconcile import reconcile_csv


class ReportsTest(unittest.TestCase):
    def test_export_csv(self):
        out = io.StringIO()
        export_csv([Order(1, "Acme, Inc", 1250, "paid")], out)
        self.assertEqual(out.getvalue().splitlines(), ["id,customer,total,status", '1,"Acme, Inc",12.50,paid'])

    def test_reconcile_csv(self):
        out = io.StringIO()
        export_csv([Order(1, "a", 1000, "paid"), Order(2, "b", 500, "paid")], out)
        out.seek(0)
        result = reconcile_csv(out, [{"id": "2", "amount": "5.10"}, {"id": "3", "amount": "1.00"}])
        self.assertEqual(result, {"missing_from_statement": [1], "unknown_in_statement": [3], "amount_differs": [2]})
P
cat > wt/.plans/plan.md <<'P'
# Finance can export and reconcile orders

Size: M · Type: feature

## Goal
Finance downloads orders as CSV and reconciles the downloaded file against the payment provider's statement.

## Boundary
`list_orders()` keeps its signature and results.

## Bar for done
- [ ] CSV export and reconciliation, with tests
- [ ] no block finding open

How it is checked: every round, `python3 -m unittest discover -s tests -q` (baseline on origin/main: 0 tests).

## Size budget
Budget: ~200 changed production lines, 4 files; tests reported apart. Split trigger: more than 200 production lines.

## Gates
- Before round 2's verification (after its items are done): the user starts the verification.

## Parts

### Part A: CSV export and reconciliation
- [ ] `export_csv(orders, out)` in a new `reports/export.py`: a header row, then one row per order with id, customer, total in euros with 2 decimals and status — test first: test_export_csv
- [ ] `reconcile_csv(export_file, statement_rows)` in a new `reports/reconcile.py`: reads a file written by `export_csv`, and returns the orders missing from the statement, the statement rows with no order, and the ids whose amounts differ by more than 1 cent — test first: test_reconcile_csv
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: project setup
Start: branch feature, HEAD a1b2c3d (= origin? yes), clean tree required.
Comments read until: none
Triage check: no problems
## Items
### 1. Add the reports package and the test runner command
P
cat > wt/.plans/round-1-summary.md <<'P'
# Round 1 summary
HEAD before: a1b2c3d · HEAD after: b0b0b0b · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | b0b0b0b | |
P
cat > wt/.plans/round-1-review.md <<'P'
# Round 1 review
Verdict against the bar: not met yet (Part A open).
## Block
- none
## Ticket
- none
## Note
- none
P
cat > wt/.plans/round-2.md <<'P'
# Round 2: CSV export and reconciliation

Plan: `.plans/plan.md` · Trigger: plan part A
Start: branch feature, HEAD b0b0b0b (= origin? yes), clean tree required.
Comments read until: none
Triage check: no problems (fresh agent)
Bar: see plan § Bar for done. Act only on items below; anything else is reported, not fixed.

## Rules for every item

- Test first; the test must fail without the fix and drive the production caller.
- One commit per item; the commit message states the item number.
- Caller audits are untruncated: give the match count and every hit.
- Stop and report instead of deciding anything that touches the boundary, a repository rule, the plan's decisions, or another person's code.

## Items

### 1. export_csv writes a header and one row per order

- Verified at: `reports/orders.py:5` (b0b0b0b) — `Order` has id, customer, total_cents, status
- Callers covered (paths): none yet (new function); the header is read by `reconcile_csv` (item 2)
- Owning code point: reports/export.py · export_csv
- Change: new function (~12 production lines)
- Test: test_export_csv — header row, comma in a name quoted, total in euros with 2 decimals
- Stop if: `list_orders()` would need to change

### 2. reconcile_csv matches an export file against the statement

- Verified at: `reports/export.py` (item 1) — columns id, customer, total, status
- Callers covered (paths): reads the file `export_csv` writes, by column name (`id`, `total`)
- Owning code point: reports/reconcile.py · reconcile_csv
- Change: new function (~12 production lines)
- Test: test_reconcile_csv — drives `export_csv`, then `reconcile_csv` on its output: one missing, one unknown, one amount differing by 10 cents
- Stop if: the statement format is not `{"id", "amount"}`

## Not this round

| Item | Reason | Ticket text |
| ---- | ------ | ----------- |

## End of round

Return the summary in the shape of `templates/round-summary.md`, one row per item, including skipped ones.
P
cat > kit-data/state/acme-shop-feature.progress.json <<'P'
{"round": 2, "items": {"done": 2, "total": 2}, "updatedAt": "2026-01-10T10:20:00Z"}
P
cat > kit-data/state/acme-shop-feature.json <<'P'
{"repo":"acme/shop","branch":"feature","worktree":"./wt","session":"unknown","startedAt":"2026-01-10T07:00:00Z","updatedAt":"2026-01-10T10:00:00Z","mode":"run","plan":{"title":"Finance can export and reconcile orders","path":"./wt/.plans/plan.md"},"parts":[{"title":"Part A: CSV export and reconciliation","short":"Export, reconcile","status":"running","done":0,"total":2,"steps":[{"label":"CSV export","status":"running"},{"label":"Reconcile","status":"running"}]}],"round":2,"step":"execute","items":{"done":2,"total":2},"state":"running","reason":null,"rounds":[{"n":1,"startedAt":"2026-01-10T08:30:00Z","endedAt":"2026-01-10T09:10:00Z","verdict":"not met, block 0"},{"n":2,"startedAt":"2026-01-10T09:40:00Z"}],"pr":12,"commentsReadUntil":null}
P
cat > git-out/git.txt <<'P'
$ git status --short --branch
## feature...origin/feature [ahead 2]
$ git log --oneline origin/feature..HEAD
d00d1e2 Round 2 item 2: reconcile_csv matches an export file against the statement
c0ffee1 Round 2 item 1: export_csv writes a header and one row per order
$ git rev-parse HEAD ; git rev-parse @{u}
d00d1e2
b0b0b0b
$ git rev-parse --git-dir ; git rev-parse --git-common-dir
/repo/.git/worktrees/wt
/repo/.git
$ git remote get-url origin
git@github.com:acme/shop.git
$ gh pr view --json number,comments,reviews
{"number": 12, "comments": [], "reviews": []}
$ scripts/drift.sh --lines 200 --files 4
size: 4 files, +58 -0 (58 lines) since merge-base 9f8e7d6c5b4
production: 3 files, +30 -0 (30 lines), budget 200 lines, 4 files: within budget
tests: 1 files, +28 -0 (28 lines), outside the budget
commits: 3 ahead, 0 behind origin/main
merge preview: clean
$ python3 -m unittest discover -s tests -q
----------------------------------------------------------------------
Ran 2 tests in 0.002s

OK
P
