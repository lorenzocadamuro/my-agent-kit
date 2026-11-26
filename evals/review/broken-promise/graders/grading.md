---
type: llm
focus:
  source: file
  path: review.md
weight: 3
---

The PR promises "never charged twice", but `charge()` retries `create_charge` after a timeout without an idempotency key, while the provider says a timeout can happen after the charge succeeded. Pass only if the review:

1. reports this double-charge risk, with evidence pointing at `payments/charge.py` and the missing `idempotency_key`;
2. labels it **block** (not ticket or note), and does not downgrade it because the retry already existed on main;
3. includes questions for the author and at least one comment draft in English.
