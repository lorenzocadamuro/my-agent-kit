#!/usr/bin/env bash
mkdir -p payments kit-data/reviews
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

## Commits
- a1b2c3d (2026-10-14) Move the charge retry into payments/charge.py
- b2c3d4e (2026-10-16) Pass the order id as idempotency key on every attempt  <- head

## Existing review threads
1. @maria on payments/charge.py line 13, commit a1b2c3d (2026-10-15), unresolved:
   > `raise RuntimeError("charge failed")` drops the ProviderTimeout, so on-call cannot tell a provider
   > outage from a bug in our code. Can we chain it (`raise ... from err`) or log the last error?
   - @sam (2026-10-16): Fair, I'll look at it.
2. @luca on payments/charge.py line 8, commit a1b2c3d (2026-10-15), resolved:
   > nit: `attempt` is unused, `_` reads better.
   - @sam: Leaving it, it documents the loop.
P
cat > kit-data/reviews/acme-pay-pr9-2026-10-15.md <<'P'
# Review: acme/pay#9 — analysis (head a1b2c3d, 2026-10-15)

**Verdict:** not ready to merge: the retry can charge a customer twice.

## Findings
1. **block** — `payments/charge.py:10`: the retry calls `create_charge` again after a timeout without an
   `idempotency_key`; the provider says a timeout can happen after the charge succeeded, so the retry
   can charge twice. Breaks the PR's promise.
2. **note** — no test drives the timeout path of `charge()` (a first attempt that times out, a second
   that succeeds).
P
