#!/usr/bin/env bash
mkdir -p wt/.plans wt/shop wt/tests git-out kit-data
cat > wt/shop/orders.py <<'P'
ORDERS = {}


def get_order(order_id):
    if order_id not in ORDERS:
        raise KeyError("Ordre not found")
    return ORDERS[order_id]
P
cat > wt/tests/test_orders.py <<'P'
import unittest
from shop.orders import get_order


class T(unittest.TestCase):
    def test_missing(self):
        with self.assertRaises(KeyError):
            get_order(1)
P
cat > wt/.plans/plan.md <<'P'
# Fix the "Ordre not found" typo

Size: S · Type: bug fix

## Goal
The error says "Order not found".

## Boundary
`get_order` raises the same exception type.

## Bar for done
- [ ] message fixed, with a test on the message

How it is checked: every round, `python3 -m unittest discover -s tests -q` (baseline on origin/main: 1 passed).

## Verification
- [ ] `get_order` on a missing id raises KeyError("Order not found") — test first: test_missing_message
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
