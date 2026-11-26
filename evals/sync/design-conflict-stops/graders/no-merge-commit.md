---
type: regex
target: trace
pattern: "git (-C \\S+ )?commit"
match: not_contains
weight: 1
---
