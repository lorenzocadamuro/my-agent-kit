---
type: regex
target:
  source: file
  path: decision.md
pattern: "pricing\\.py[^\\n]*tax_rate[^\\n]*(scont|discount)|pricing\\.py[^\\n]*(scont|discount)[^\\n]*tax_rate"
flags: i
weight: 2
---
