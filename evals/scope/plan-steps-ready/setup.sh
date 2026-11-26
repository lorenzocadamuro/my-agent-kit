#!/usr/bin/env bash
mkdir -p shop api web emails tests kit-data/projects
cat > shop/__init__.py <<'P'
P
cat > api/__init__.py <<'P'
P
cat > web/__init__.py <<'P'
P
cat > emails/__init__.py <<'P'
P
cat > shop/totals.py <<'P'
TAX_RATES = {"IT": 0.22, "DE": 0.19, "US": 0.0}


def order_total_with_tax(order: dict) -> int:
    """The order's total in cents: its line items plus the tax of its country, rounded half up."""
    subtotal = sum(item["unit_cents"] * item["qty"] for item in order["items"])
    rate = TAX_RATES.get(order["country"], 0.0)
    return subtotal + int(subtotal * rate + 0.5)
P
cat > shop/money.py <<'P'
SYMBOLS = {"EUR": "€", "USD": "$"}


def format_cents(cents: int, currency: str) -> str:
    """An amount as users see it: the currency symbol, then units with two decimals."""
    return f"{SYMBOLS.get(currency, currency + ' ')}{cents // 100}.{cents % 100:02d}"
P
cat > api/orders.py <<'P'
from shop.money import format_cents
from shop.totals import order_total_with_tax


def list_orders(db, customer_id: str) -> list[dict]:
    """GET /orders: the customer's orders, newest first, each with its total as the orders page shows it."""
    orders = db.select("orders", customer_id=customer_id)
    orders.sort(key=lambda o: o["created_at"], reverse=True)
    return [
        {
            "id": o["id"],
            "date": o["created_at"].date().isoformat(),
            "status": o["status"],
            "total": format_cents(order_total_with_tax(o), o["currency"]),
        }
        for o in orders
    ]
P
cat > web/orders_page.py <<'P'
from api.orders import list_orders


def render(db, customer_id: str) -> str:
    """The orders page: a heading and one table row per order."""
    rows = "".join(
        f"<tr><td>{o['id']}</td><td>{o['date']}</td><td>{o['status']}</td><td>{o['total']}</td></tr>"
        for o in list_orders(db, customer_id)
    )
    return f"<h1>Your orders</h1><table>{rows}</table>"
P
cat > emails/receipt.py <<'P'
from shop.money import format_cents
from shop.totals import order_total_with_tax


def receipt_line(order: dict) -> str:
    return f"Order {order['id']}: {format_cents(order_total_with_tax(order), order['currency'])}"
P
cat > tests/__init__.py <<'P'
P
cat > tests/test_totals.py <<'P'
import unittest

from shop.totals import order_total_with_tax


class TotalsTest(unittest.TestCase):
    def test_tax_rounded_half_up(self):
        order = {"country": "IT", "items": [{"unit_cents": 1000, "qty": 1}]}
        self.assertEqual(order_total_with_tax(order), 1220)


if __name__ == "__main__":
    unittest.main()
P
cat > README.md <<'P'
# acme/shop

Shop service. Run the tests with `python3 -m unittest discover -s tests -q`.
P
cat > ticket.md <<'P'
# SHOP-88: Customers can download their orders as CSV

Add `GET /orders/export.csv`: one row per order of the customer, newest first, with the columns id, date (ISO), status and total.
The total in the CSV must equal the total the orders page shows for the same order, tax included, in the order's currency.
Add a "Download CSV" link above the table on the orders page.
Tests for the export and the link.
P
cat > kit-data/projects/acme-shop.md <<'P'
# Project profile: acme/shop

Confirmed by the user on 2026-01-10. Correct it through `/my:improve` when it is wrong.

## Repository

- Default branch: `main` · New branches from: `origin/main`
- Session follows the worktree: no

## Rules to load

| Area (path glob) | Guide       |
| ---------------- | ----------- |
| `**`             | `README.md` |

## Commands

| Purpose        | Command                                    |
| -------------- | ------------------------------------------ |
| Targeted tests | `python3 -m unittest discover -s tests -q` |
| Deep review    | none                                       |

## Tickets

- Tracker: Linear, team SHOP
P
