#!/usr/bin/env bash
mkdir -p shop tests kit-data/reads kit-data/reviews
cat > shop/invoice.py <<'P'
from decimal import ROUND_HALF_UP, Decimal

VAT_RATE = Decimal("0.22")
CENT = Decimal("0.01")


def _cents(amount: Decimal) -> Decimal:
    return amount.quantize(CENT, rounding=ROUND_HALF_UP)


def invoice_total(lines: list[dict]) -> dict:
    """Net, VAT and gross of an invoice. VAT is computed and rounded per line, then summed,
    the same way the accounting export does."""
    net = sum((Decimal(l["net"]) for l in lines), Decimal("0"))
    vat = sum((_cents(Decimal(l["net"]) * VAT_RATE) for l in lines), Decimal("0"))
    return {"net": _cents(net), "vat": vat, "gross": _cents(net) + vat}
P
cat > shop/export.py <<'P'
from decimal import Decimal

from shop.invoice import VAT_RATE, _cents


def export_rows(invoice_id: str, lines: list[dict]) -> list[dict]:
    """Rows for the accounting system: one per invoice line, VAT rounded per line."""
    return [
        {"invoice": invoice_id, "net": Decimal(l["net"]), "vat": _cents(Decimal(l["net"]) * VAT_RATE)}
        for l in lines
    ]
P
cat > tests/test_invoice.py <<'P'
import unittest
from decimal import Decimal

from shop.export import export_rows
from shop.invoice import invoice_total


class InvoiceTotalTest(unittest.TestCase):
    def test_vat_matches_export(self):
        lines = [{"net": "0.10"}, {"net": "0.10"}, {"net": "0.10"}]
        total = invoice_total(lines)
        self.assertEqual(total["vat"], sum(r["vat"] for r in export_rows("I-1", lines)))
        self.assertEqual(total["vat"], Decimal("0.06"))


if __name__ == "__main__":
    unittest.main()
P
cat > pr.md <<'P'
# PR acme/shop#14: Compute invoice VAT per line

Author: @sam · Base: `main` · Head: 7e8f9a0 · CI green

## Description
The accounting export rounds VAT on every invoice line, while `invoice_total` rounded it once on the
invoice's net total. On invoices with many small lines the two disagreed by a few cents, and finance
reconciled them by hand every month (12 invoices in October). `invoice_total` now rounds VAT per line
and sums it, like `export_rows`. Adds a test with three lines of 0.10.

## Diff
```diff
--- a/shop/invoice.py
+++ b/shop/invoice.py
 def invoice_total(lines: list[dict]) -> dict:
-    """Net, VAT and gross of an invoice."""
+    """Net, VAT and gross of an invoice. VAT is computed and rounded per line, then summed,
+    the same way the accounting export does."""
     net = sum((Decimal(l["net"]) for l in lines), Decimal("0"))
-    vat = _cents(net * VAT_RATE)
-    return {"net": _cents(net), "vat": vat, "gross": _cents(net + vat)}
+    vat = sum((_cents(Decimal(l["net"]) * VAT_RATE) for l in lines), Decimal("0"))
+    return {"net": _cents(net), "vat": vat, "gross": _cents(net) + vat}
--- /dev/null
+++ b/tests/test_invoice.py
@@ (new file, 16 lines: test_vat_matches_export, see tests/test_invoice.py)
```
P
