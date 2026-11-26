#!/usr/bin/env bash
mkdir -p wt/.plans wt/shop kit-data
cat > wt/shop/pricing.py <<'P'
def apply_discount(total: float, discount: float) -> float:
    return total * (1 - discount)


def order_total(prices: list[float], discount: float) -> float:
    return round(apply_discount(sum(prices), discount), 2)
P
cat > wt/.plans/plan.md <<'P'
# Discounts on order totals
Size: S · Type: feature
## Goal
Orders can carry a discount between 0 and 1.
## Boundary
Orders without a discount keep exactly today's totals.
## Bar for done
- [ ] discount validated (0 <= d <= 1) with a test
- [ ] no block finding open
## Gates
- Before any code of round 2 is written (after its triage): the user reads the round file and says go.
## Invariants
| I1 | discount is always within [0, 1] when applied | shop/pricing.py · apply_discount | test_rejects_out_of_range_discount |
## Out of scope
| Performance work on pricing | not needed for this change | - |
P
cat > wt/review.md <<'P'
Review findings on round 1:
F1. apply_discount accepts discount=1.5 and returns a negative total. This breaks invariant I1.
F2. order_total recomputes sum(prices) on every call; caching per order would save time on large carts.
P
