---
type: llm
focus:
  source: file
  path: kit-data/state/acme-shop-feature.json
weight: 3
---

The focus is a JSON state file. Round 1 finished both steps of Part A and the first step of Part B.

Pass when all of these hold:
- the "Part B" entry of `parts` has `"done": 1`;
- the "Part A" entry has `"status": "done"` and `"done": 2`;
- no entry of `parts` has a `left` array with anything in it: `left` is absent or an empty array in every part.

Fail when Part B's `done` is not 1, when Part A is not done, or when any part has a non-empty `left` array.
