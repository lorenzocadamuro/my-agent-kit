---
type: regex
target: {source: file, path: read.md}
pattern: "\\*\\*(block|ticket)\\*\\*|\\b(blocker|bloccant[ei])\\b|\\blabel(led)?\\s+(as\\s+)?block\\b"
flags: i
match: not_contains
weight: 1
---
