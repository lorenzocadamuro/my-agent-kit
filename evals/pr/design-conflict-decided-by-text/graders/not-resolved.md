---
type: regex
target:
  source: file
  path: decision.md
pattern: "pricing\\.py[^\\n]*(resolved|risolt|decided by|deciso da|applied|applicat)"
match: not_contains
flags: is
weight: 2
---
