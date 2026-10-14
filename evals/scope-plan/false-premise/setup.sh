#!/usr/bin/env bash
mkdir -p shop tests kit-data
cat > shop/orders.py <<'P'
from dataclasses import dataclass

ORDERS: dict[int, "Order"] = {}


@dataclass
class Order:
    id: int
    customer_email: str
    status: str = "open"


def get_order(order_id: int) -> Order:
    if order_id not in ORDERS:
        raise KeyError("Ordre not found")
    return ORDERS[order_id]


def cancel_order(order_id: int) -> Order:
    order = get_order(order_id)
    order.status = "cancelled"
    return order
P
cat > shop/notify.py <<'P'
def send_email(to: str, subject: str) -> None:
    print(f"email to {to}: {subject}")


def send_sms(to: str, text: str) -> None:
    print(f"sms to {to}: {text}")
P
cat > tests/test_orders.py <<'P'
from shop.orders import ORDERS, Order, cancel_order


def test_cancel_sets_status():
    ORDERS[1] = Order(id=1, customer_email="a@example.com")
    assert cancel_order(1).status == "cancelled"
P
