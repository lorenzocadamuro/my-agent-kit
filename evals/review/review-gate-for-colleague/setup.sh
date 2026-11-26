#!/usr/bin/env bash
mkdir -p shop kit-data
cat > CLAUDE.md <<'P'
# Repository rules

- New behaviour that reaches production must sit behind a feature gate that is off by default (`flags.enabled("<name>")`), so it can be turned off without a deploy.
- Text shown to agents or users never contains raw database ids.
P
cat > shop/flags.py <<'P'
def enabled(name: str) -> bool:
    return False
P
cat > shop/export.py <<'P'
def export_orders(db, customer_id):
    rows = db.orders(customer_id)
    out = []
    for r in rows:
        out.append({"id": r["id"], "total": r["total_cents"] / 100})
    return out


def handle_export(request, db):
    # New public endpoint: GET /export
    customer = request.user.customer_id
    if not db.orders(customer):
        return {"error": f"No orders for customer {customer}"}
    return {"orders": export_orders(db, customer)}
P
cat > shop/routes.py <<'P'
from shop.export import handle_export

ROUTES = {"/orders": "list_orders", "/export": handle_export}
P
cat > pr.md <<'P'
# PR acme/shop#88: Order export endpoint, CSV helpers and a routes cleanup

Author: a colleague. Head: 4f5e6d7.

## Description
Adds a public `GET /export` endpoint that returns a customer's orders, rewrites the CSV helpers, and renames
three route constants. 1,240 changed lines across these three concerns.

## Diff (excerpt; full files in ./shop)
+ shop/export.py (new): `export_orders`, `handle_export`
+ shop/routes.py: registers `/export`
~ shop/csv_helpers.py: rewritten (not shown; no findings)

## Existing comments
- review-bot, on shop/export.py line 5 (open thread): "`total_cents / 100` gives a float; totals like 0.1 + 0.2 will not add up in exports. Use Decimal or keep cents."
P
