---
type: regex
target: trace
pattern: "git (-C \\S+ )?push"
match: not_contains
weight: 1
---
