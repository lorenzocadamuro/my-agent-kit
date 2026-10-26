#!/usr/bin/env bash
mkdir -p app kit-data
touch app/__init__.py
cat > app/retry.py <<'P'
import time

MAX_ATTEMPTS = 3
BACKOFF_S = (0.5, 2.0)


def charge(gateway, order):
    """Charge an order. Retries only on a timeout: a declined card is final, and a retry would charge twice
    on gateways that confirm late (see plan.md, decision D2)."""
    for attempt in range(MAX_ATTEMPTS):
        try:
            return gateway.charge(order.id, order.total, idempotency_key=order.id)
        except gateway.Timeout:
            if attempt == MAX_ATTEMPTS - 1:
                raise
            time.sleep(BACKOFF_S[min(attempt, len(BACKOFF_S) - 1)])
P
cat > comments.md <<'P'
Review on PR acme/shop#88 by dana (a colleague), state: CHANGES_REQUESTED

R1 (dana, app/retry.py line 12): Why only retry on Timeout? We should retry on any gateway error, a 502 or a declined card can be transient too.
R2 (dana, app/retry.py line 4): 3 attempts feels low, can we make it 5 with exponential backoff like the payout service does?
P
cat > plan.md <<'P'
# Retry card charges on gateway timeouts

## Decisions

- D2: retry only on `Timeout`. Two of the three gateways confirm a charge late: a retry after a 502 or a decline charged customers twice in the incident of March. Every retry carries the order id as idempotency key, which only the timeout path is tested with.
- D3: 3 attempts, backoff 0.5 s then 2 s: checkout waits at most ~3 s; at 5 exponential attempts it would wait ~15 s, past the client's 10 s timeout, so the user would see an error while the charge still goes through.
P
