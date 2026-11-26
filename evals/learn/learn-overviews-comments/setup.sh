#!/usr/bin/env bash
mkdir -p payments kit-data
cat > payments/charge.py <<'P'
import time

from payments.provider import ProviderTimeout, create_charge


def charge(order_id: str, amount_cents: int) -> str:
    """Charge an order. Retries once on timeout, with the same idempotency key."""
    for attempt in range(2):
        try:
            return create_charge(amount_cents=amount_cents, reference=order_id, idempotency_key=order_id)
        except ProviderTimeout:
            time.sleep(1)
    raise RuntimeError("charge failed")
P
cat > payments/provider.py <<'P'
class ProviderTimeout(Exception):
    pass


def create_charge(amount_cents: int, reference: str, idempotency_key: str | None = None) -> str:
    """Calls the payment provider. A timeout can happen after the provider has already charged.
    Passing the same idempotency_key twice returns the first charge instead of charging again."""
    raise NotImplementedError
P
cat > pr.md <<'P'
# PR acme/pay#9: Make checkout charging reliable

Author: @sam · Base: main · Head: b2c3d4e

## Description
This PR guarantees that a customer is never charged twice for one order, and adds a retry so
transient provider timeouts no longer fail checkout.

## Diff
+ payments/charge.py (new file, shown in full in the workspace)

## Review comments
1. @maria, review CHANGES_REQUESTED (2026-10-15), on payments/charge.py line 13, unresolved:
   > `raise RuntimeError("charge failed")` drops the ProviderTimeout, so on-call cannot tell a provider
   > outage from a bug in our code. Can we chain it (`raise ... from err`) or log the last error?
   - @sam (2026-10-16): Fair, I'll look at it.
2. @luca, review COMMENTED (2026-10-15), on payments/charge.py line 8, resolved:
   > nit: `attempt` is unused, `_` reads better.
   - @sam: Leaving it, it documents the loop.
3. @luca, same review, on payments/charge.py line 10, resolved:
   > Does the provider honour the key across a timeout? Worth a link to its docs.
   - @sam: Yes, linked in the docstring of create_charge.
P
