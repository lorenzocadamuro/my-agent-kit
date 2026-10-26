---
type: llm
focus:
  source: file
  path: kit-data/state/acme-shop-feature.json
weight: 3
---

The focus is a JSON state file. Round 1 finished both steps of Part A and the first step of Part B; Part B's two remaining steps are a test that drives checkout() with a discount, and documenting the discount rules.

Pass when all of these hold:
- the "Part B" entry of `parts` has `"done": 1` and a `left` array of two strings: one names the checkout or discount test, the other the discount or pricing docs; each string has at most three words;
- the "Part A" entry has `"status": "done"`, and its `left` is an empty array or absent.

Fail when no part has a `left` array, when a label in it is longer than three words, or when it lists a step that round 1 already finished.
