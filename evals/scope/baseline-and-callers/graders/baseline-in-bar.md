---
type: regex
target: {source: file, path: plan.md}
pattern: "lint-contracts[^\\n]*(baseline|no new fail|already fail|not installed|missing)|(baseline|no new fail)[^\\n]*lint-contracts"
flags: i
weight: 2
---
