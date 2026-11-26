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

Reviewers requested: rev-ana

## Diff
+ payments/charge.py (new file, shown in full in the workspace)
P
mkdir -p kit-data/reviewers kit-data/study
cat > kit-data/reviewers/rev-ana.md <<'P'
# Reviewer: rev-ana

Built from study pages; every line cites the study page it comes from.

## Lenses they use most

- Failure modes — asks what happens when a remote call times out after it succeeded (study/rev-ana-idempotency.md)

## Questions they typically ask

- "a retry without an idempotency key is a double charge waiting to happen" (study/rev-ana-idempotency.md)

## What they let pass

- naming and log wording, as follow-ups

## How to prepare a change for them

- show the idempotency key on every retried payment call
P
cat > kit-data/study/rev-ana-idempotency.md <<'P'
# Refund retries — rev-ana

PR: acme/pay#4 · Review date: 2026-09-02 · Reading time: ~4 min

## Layer 0: what you need now

- **Verdict:** changes requested — 1 blocking
- **What you owe:** an idempotency key on the refund retry
- **The move worth learning:** for every retry, ask whether the first attempt may have succeeded

## Layer 1: the comments that matter

### 1. "a retry without an idempotency key is a double charge waiting to happen" — blocking

**In plain words:** a timeout does not mean the provider did nothing; retrying without a key can repeat the money movement.

**How they reason:** they follow every retry back to the remote call and ask what the provider guarantees on a repeat.
P
