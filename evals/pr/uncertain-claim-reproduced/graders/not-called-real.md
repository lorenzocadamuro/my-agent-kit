---
type: regex
target: {source: file, path: triage.md}
pattern: "U002[^\\n]*\\|\\s*\\**(real|reale)\\**\\s*\\|"
flags: i
match: not_contains
weight: 3
---
