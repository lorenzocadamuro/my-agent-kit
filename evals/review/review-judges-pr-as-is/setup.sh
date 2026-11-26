#!/usr/bin/env bash
mkdir -p payments tests kit-data/reviews
cat > payments/models.py <<'P'
from dataclasses import dataclass


@dataclass
class Order:
    id: str
    charge_id: str
    customer_email: str
    charged_cents: int
    refunded_cents: int = 0

    def save(self) -> None:
        ...


@dataclass
class Refund:
    order_id: str
    amount_cents: int
    provider_id: str

    @classmethod
    def create(cls, **fields) -> "Refund":
        return cls(**fields)
P
cat > payments/provider.py <<'P'
def refund_charge(charge_id: str, amount_cents: int) -> str:
    """Refunds part of a charge at the payment provider and returns the refund id.
    An amount of 0 is accepted and recorded by the provider as an empty refund."""
    raise NotImplementedError
P
cat > payments/notify.py <<'P'
def send_refund_email(to: str, amount_cents: int) -> None:
    """Emails the customer: "We refunded €<amount> to your card"."""
    raise NotImplementedError
P
cat > payments/refunds.py <<'P'
from payments.models import Order, Refund
from payments.notify import send_refund_email
from payments.provider import refund_charge


class RefundTooLarge(Exception):
    pass


def refund(order: Order, amount_cents: int) -> Refund:
    """Refund part of an order's charge. Partial refunds may repeat until the charge is used up."""
    refundable = order.charged_cents - order.refunded_cents
    if amount_cents > refundable:
        raise RefundTooLarge(f"{amount_cents} > {refundable}")
    provider_id = refund_charge(order.charge_id, amount_cents)
    record = Refund.create(order_id=order.id, amount_cents=amount_cents, provider_id=provider_id)
    order.refunded_cents += amount_cents
    order.save()
    send_refund_email(order.customer_email, amount_cents)
    return record
P
cat > payments/api.py <<'P'
from pydantic import BaseModel, Field

from payments.refunds import refund


class RefundRequest(BaseModel):
    amount_cents: int = Field(ge=0)


def post_refund(order, body: RefundRequest):
    record = refund(order, body.amount_cents)
    return {"refund_id": record.provider_id, "amount_cents": record.amount_cents}
P
cat > tests/test_refunds.py <<'P'
import unittest
from unittest import mock

from payments.models import Order
from payments.refunds import RefundTooLarge, refund


def order(**kw):
    return Order(id="A-1", charge_id="ch_1", customer_email="ada@example.com", charged_cents=1000, **kw)


@mock.patch("payments.refunds.send_refund_email")
@mock.patch("payments.refunds.refund_charge", return_value="re_1")
class RefundTest(unittest.TestCase):
    def test_partial_refund(self, _charge, _email):
        o = order()
        refund(o, 400)
        self.assertEqual(o.refunded_cents, 400)

    def test_second_refund_cannot_exceed_what_is_left(self, _charge, _email):
        o = order(refunded_cents=800)
        with self.assertRaises(RefundTooLarge):
            refund(o, 300)


if __name__ == "__main__":
    unittest.main()
P
cat > pr.md <<'P'
# PR acme/pay#21: Partial refunds endpoint

Author: @sam · Base: `refunds-table` (that is PR acme/pay#20, still open, not merged yet) · Head: c3d4e5f

## Description
Adds `POST /orders/<id>/refunds` for partial refunds: an order can be refunded in several parts,
never more than it was charged in total. Stacked on acme/pay#20, which adds the `Refund` model and
the `refunded_cents` column (payments/models.py); this PR will be retargeted to main when #20 merges.
CI is green on this branch.

## Commits
- a1b2c3d (2026-10-26) Add refund() and the endpoint
- b2c3d4e (2026-10-27) Email the customer after a refund
- c3d4e5f (2026-10-29) Check the amount against what is left to refund  <- head

## Existing review threads
1. @lia on payments/refunds.py line 12, commit b2c3d4e (2026-10-28), unresolved:
   > A second partial refund is only compared with the charged total, not with what was already
   > refunded: two refunds of 800 on a 1000 charge both go through.
   - @sam (2026-10-29): Fixed in c3d4e5f, now compared with charged minus refunded, with a test.
P
cat > kit-data/reviews/acme-pay-pr21-2026-10-28.md <<'P'
# Review: acme/pay#21 — analysis (head b2c3d4e, 2026-10-28)

**Verdict:** not ready to merge: partial refunds can add up to more than the charge.

## Findings
1. **block** — `payments/refunds.py:12`: the amount is compared with `order.charged_cents` only, so two
   partial refunds of 800 on a 1000 charge both pass. Breaks the PR's promise ("never more than it was
   charged in total"). Raised as a thread.
P
