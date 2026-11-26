#!/usr/bin/env bash
mkdir -p wt/.plans wt/shop wt/tests git-out kit-data
touch wt/shop/__init__.py
cat > wt/shop/cart.py <<'P'
from dataclasses import dataclass, field


@dataclass
class Cart:
    id: int
    customer: str
    items: dict[str, int] = field(default_factory=dict)
    currency: str = "EUR"
    saved_at: float = 0.0


SAVED: dict[int, Cart] = {}


def save_cart(cart: Cart, now: float) -> None:
    cart.saved_at = now
    SAVED[cart.id] = cart
    for sku, qty in cart.items.items():
        if qty <= 0:
            raise ValueError(f"bad quantity for {sku}")
P
cat > wt/tests/test_cart.py <<'P'
import unittest

from shop.cart import Cart, save_cart, SAVED


class SaveCartTest(unittest.TestCase):
    def setUp(self):
        SAVED.clear()

    def test_save_cart(self):
        save_cart(Cart(1, "ann", {"sku1": 2}), now=10.0)
        self.assertEqual(SAVED[1].saved_at, 10.0)

    def test_rejects_bad_quantity(self):
        with self.assertRaises(ValueError):
            save_cart(Cart(2, "bob", {"sku1": 0}), now=10.0)
P
cat > wt/.plans/plan.md <<'P'
# Saved carts

Size: M · Type: feature

## Goal
Customers can save carts and come back to them.

## Boundary
Checkout of an unsaved cart behaves as today.

## Bar for done
- [ ] parts A–E, with tests
- [ ] no block finding open

How it is checked: every round, `python3 -m unittest discover -s tests -q` (baseline on origin/main: 0 tests).

## Gates
- Before any code of round 2 is written (after its triage and its check): the user reads the round file and says go.

## Invariants

| Id | Invariant | Where it holds | Test |
| --- | --- | --- | --- |
| I1 | A cart with a non-positive quantity is never saved | shop/cart.py · save_cart | test_rejects_bad_quantity |

## Size budget
Budget: ~250 changed production lines, 5 files; tests reported apart.

## Parts

### Part A: save a cart
- [x] `save_cart(cart, now)` stores the cart and rejects non-positive quantities — test first: test_save_cart, test_rejects_bad_quantity

### Part B: list saved carts
- [ ] `list_carts(customer)` returns the customer's saved carts, newest first — test first: test_list_carts_newest_first

### Part C: delete a saved cart
- [ ] `delete_cart(cart_id)` removes a saved cart — test first: test_delete_cart

### Part D: purge old carts
- [ ] `purge_carts(now)` removes carts saved more than 30 days ago — test first: test_purge_carts

### Part E: currency on saved carts
- [ ] `save_cart()` also validates the cart's currency against EUR, USD and GBP — test first: test_save_cart_currency
P
cat > wt/.plans/round-1.md <<'P'
# Round 1: save a cart
Start: branch feature, HEAD a1b2c3d (= origin? yes), clean tree required.
Comments read until: none
## Items
### 1. save_cart(cart, now) stores the cart and rejects non-positive quantities
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

Verdict against the bar: not met.

## Block
- B1. `save_cart()` stores the cart before it validates the quantities (shop/cart.py: `SAVED[cart.id] = cart` runs before the loop), so a rejected cart stays saved. This breaks invariant I1, and test_rejects_bad_quantity does not check SAVED. Fix: validate first, then store; extend the test to assert the cart is not in SAVED.

## Ticket
- none

## Note
- N1. `save_cart()` changes again in Part E (currency validation): keep its validation in one place.
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
$ scripts/drift.sh --lines 250 --files 5
size: 2 files, +38 -0 (38 lines) since merge-base 9f8e7d6c5b4
production: 1 files, +20 -0 (20 lines), budget 250 lines, 5 files: within budget
tests: 1 files, +18 -0 (18 lines), outside the budget
commits: 1 ahead, 0 behind origin/main
merge preview: clean
$ python3 -m unittest discover -s tests -q
----------------------------------------------------------------------
Ran 2 tests in 0.001s

OK
P
