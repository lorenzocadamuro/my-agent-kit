---
type: regex
target: {source: file, path: out.md}
pattern: "speed,[^.\\n]*reliability,?[^.\\n]*scalability"
flags: i
match: not_contains
weight: 1
---
