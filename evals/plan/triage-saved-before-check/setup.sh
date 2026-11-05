#!/usr/bin/env bash
mkdir -p wt/.plans wt/reports wt/tests git-out kit-data
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
cat > wt/.plans/plan.md <<'P'
# Finance can export and reconcile orders

Size: M · Type: feature

## Goal
Finance downloads orders as CSV and reconciles them against the payment provider's statement.

## Boundary
`list_orders()` keeps its signature and results.

## Bar for done
- [ ] CSV export and reconciliation, with tests
- [ ] no block finding open

How it is checked: every round, `python3 -m unittest discover -s tests -q` (baseline on origin/main: 4 passed).

## Size budget
Budget: ~300 changed production lines, 6 files; tests reported apart. Split trigger: more than 300 production lines.

## Parts

### Part A: order filters
- [x] filter by status and date range — test first: test_filters

### Part B: CSV export and reconciliation
- [ ] `export_csv(orders, out)` in a new `reports/export.py`: a header row, then one row per order with id, customer, total in euros with 2 decimals and status; values with commas or newlines quoted — test first: test_export_csv
- [ ] `reconcile(orders, statement_rows)` in a new `reports/reconcile.py`: match statement rows to orders by id, and return the orders missing from the statement, the statement rows with no order, and the pairs whose amounts differ by more than 1 cent — test first: test_reconcile
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: order filters
Start: branch feature, HEAD a1b2c3d (= origin? yes), clean tree required.
Comments read until: none
## Items
### 1. Filter orders by status and date range
P
cat > wt/.plans/round-1-summary.md <<'P'
# Round 1 summary
HEAD before: a1b2c3d · HEAD after: c0ffee1 · Tree clean: yes
## Items
| Item | State | Commit | Note |
| --- | --- | --- | --- |
| 1 | done | c0ffee1 | |
P
cat > wt/.plans/round-1-review.md <<'P'
# Round 1 review
Verdict against the bar: Part A meets it.
## Block
- none
## Ticket
- none
## Note
- none
P
cat > git-out/git.txt <<'P'
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
size: 5 files, +390 -8 (398 lines) since merge-base 9f8e7d6c5b4
production: 3 files, +262 -8 (270 lines), budget 300 lines, 6 files: within budget
tests: 2 files, +128 -0 (128 lines), outside the budget
commits: 4 ahead, 0 behind origin/main
merge preview: clean
P
