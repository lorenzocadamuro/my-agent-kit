---
type: llm
focus:
  source: file
  path: plan.md
weight: 3
---

The user claimed that cancelling an order already sends a confirmation email. In the code, `cancel_order` in `shop/orders.py` only sets the status; nothing sends an email. Pass only if the plan:

1. states explicitly that no email is sent on cancellation today, citing the code (for example `cancel_order` in `shop/orders.py`), in an existing-versus-new behaviour section or equivalent;
2. treats the email as new behaviour, or as an open decision for the user, rather than assuming it exists;
3. has a goal, a boundary, a bar for done, and an out-of-scope list.
