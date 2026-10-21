---
type: regex
target:
  source: file
  path: decision.md
pattern: "pricing\\.py[^\\n]*((?<!un|not |non |ancora )resolved|(?<!non |ir|ancora )risolt|(?<!be |va )decided by|(?<!va )decis[oa] da|applied|applicat)"
flags: i
weight: 2
---
