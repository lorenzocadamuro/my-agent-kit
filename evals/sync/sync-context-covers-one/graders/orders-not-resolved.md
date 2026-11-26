---
type: regex
target:
  source: file
  path: decision.md
pattern: "orders\\.py[^\\n]*((?<!un|not |non |ancora )resolved|(?<!non |ir|ancora )risolt|(?<!be |va )decided by|(?<!va )decis[oa] da|applied (your|the) (context|note)|applicat[oa] (il )?(tuo )?contesto)"
match: not_contains
flags: i
weight: 2
---
