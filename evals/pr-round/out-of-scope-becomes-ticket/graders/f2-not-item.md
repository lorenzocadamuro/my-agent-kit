---
type: regex
target:
  source: file
  path: wt/.plans/round-2.md
pattern: "###\\s*\\d+\\.[^\\n]*(cach|performance)"
flags: i
match: not_contains
weight: 1
---
