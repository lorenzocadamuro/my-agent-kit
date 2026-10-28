---
type: llm
focus:
  source: file
  path: kit-data/state/acme-shop-feature.json
weight: 3
---

The focus is a JSON state file. Round 1 finished both steps of Part A and the first step of Part B (rejecting negative discounts); Part B's other two steps (a checkout test with a discount, the pricing docs) are not started.

Pass when all of these hold:
- the "Part B" entry of `parts` has a `steps` array of three entries, each with a `label` of at most three words and a `status`; the first step (negative discounts) has `"status": "done"`, the other two have `"status": "todo"`;
- every entry of Part A's `steps` has `"status": "done"`;
- no step in any part has `"status": "running"`;
- the first entry of `rounds` (`"n": 1`) has an `endedAt` and a non-empty `verdict`.

Fail when any of these does not hold, for example when Part B's first step is still `todo`, when a step is `running`, or when `rounds[0]` has no `endedAt` or no `verdict`.
