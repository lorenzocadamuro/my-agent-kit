---
type: regex
target: {source: file, path: read.md}
pattern: "\\b(block|blocker|bloccante)\\b"
flags: i
match: not_contains
weight: 1
---
