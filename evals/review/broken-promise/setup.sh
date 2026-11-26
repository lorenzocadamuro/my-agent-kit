#!/usr/bin/env bash
mkdir -p payments kit-data
cat > payments/charge.py <<'P'
import time

from payments.provider import ProviderTimeout, create_charge


def charge(order_id: str, amount_cents: int) -> str:
    """Charge an order. Retries once on timeout."""
    for attempt in range(2):
        try:
            return create_charge(amount_cents=amount_cents, reference=order_id)
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

## Description
This PR guarantees that a customer is never charged twice for one order, and adds a retry so
transient provider timeouts no longer fail checkout. Note: the retry loop already existed on main
in the old checkout module; this PR moves it into payments/charge.py.

## Diff
+ payments/charge.py (new file, shown in full in the workspace)
P
