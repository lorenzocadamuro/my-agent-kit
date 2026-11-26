#!/usr/bin/env bash
# A colleague's review written with "leverage" and em-dashes; the kit's reply draft keeps neither.
mkdir -p app kit-data
touch app/__init__.py
cat > app/retry.py <<'P'
import time

MAX_ATTEMPTS = 3
BACKOFF_S = (0.5, 2.0)


def charge(gateway, order):
    """Charge an order. Retries only on a timeout (see plan.md, decision D2)."""
    for attempt in range(MAX_ATTEMPTS):
        try:
            return gateway.charge(order.id, order.total, idempotency_key=order.id)
        except gateway.Timeout:
            if attempt == MAX_ATTEMPTS - 1:
                raise
            time.sleep(BACKOFF_S[min(attempt, len(BACKOFF_S) - 1)])
P
cat > app/helpers.py <<'P'
import time


def with_retry(fn, attempts=5, retry_on=(Exception,)):
    """Call fn, retrying on any error in retry_on with exponential backoff (1 s, 2 s, 4 s, 8 s)."""
    for attempt in range(attempts):
        try:
            return fn()
        except retry_on:
            if attempt == attempts - 1:
                raise
            time.sleep(2 ** attempt)
P
cat > comments.md <<'P'
Review on PR acme/shop#88 by dana (a colleague), state: CHANGES_REQUESTED

R1 (dana, app/retry.py line 8): Could we leverage the existing `with_retry` helper here — it already handles backoff — instead of hand-rolling the loop? Leveraging it would keep retries consistent across the codebase — and it's battle-tested.
R2 (dana, app/retry.py line 3): Let's leverage the helper's defaults too — 5 attempts with exponential backoff — so checkout matches the payout service.
P
cat > plan.md <<'P'
# Retry card charges on gateway timeouts

## Decisions

- D2: retry only on `Timeout`. Two of the three gateways confirm a charge late: a retry after a 502 or a decline charged customers twice in the incident of March. `with_retry` retries on any exception, so it would bring that back.
- D3: 3 attempts, backoff 0.5 s then 2 s: checkout waits at most ~3 s; with `with_retry`'s 5 attempts it would wait ~15 s, past the client's 10 s timeout, so the user would see an error while the charge still goes through.
P
