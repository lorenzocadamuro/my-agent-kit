---
type: regex
target: {source: file, path: review.md}
pattern: "\\n#+[^\\n]*inline[^\\n]*\\n(?:(?!\\n#)[\\s\\S])*?(from err|from last|drops? the|perde|chain)"
flags: i
match: not_contains
weight: 2
---
