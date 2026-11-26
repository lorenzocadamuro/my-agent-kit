#!/usr/bin/env bash
mkdir -p payments tests kit-data
cat > payments/receipts.py <<'P'
def receipt_title(order_id: str, customer: str) -> str:
    """Title of a receipt, for example "Receipt A-17 for Ada"."""
    return f"Receipt {order_id} for {customer}"
P
cat > payments/checkout.py <<'P'
from payments.receipts import receipt_title


def receipt_header(order: dict) -> str:
    return receipt_title(order["id"], order["customer_name"])
P
cat > tests/test_receipts.py <<'P'
import unittest

from payments.receipts import receipt_title


class ReceiptTitleTest(unittest.TestCase):
    def test_title(self):
        self.assertEqual(receipt_title("A-17", "Ada"), "Receipt A-17 for Ada")


if __name__ == "__main__":
    unittest.main()
P
cat > pr.md <<'P'
# PR acme/pay#12: Rename cust to customer in receipt_title

## Description
Pure rename for readability: the parameter `cust` of `receipt_title` becomes `customer`, and the
docstring typo "Reciept" is fixed. No behaviour change. The only caller passes the arguments
positionally. CI is green.

## Diff
```diff
--- a/payments/receipts.py
+++ b/payments/receipts.py
-def receipt_title(order_id: str, cust: str) -> str:
-    """Title of a reciept, for example "Reciept A-17 for Ada"."""
-    return f"Receipt {order_id} for {cust}"
+def receipt_title(order_id: str, customer: str) -> str:
+    """Title of a receipt, for example "Receipt A-17 for Ada"."""
+    return f"Receipt {order_id} for {customer}"
```
P
