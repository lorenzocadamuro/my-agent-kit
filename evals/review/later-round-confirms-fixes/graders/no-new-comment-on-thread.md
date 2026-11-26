---
type: regex
target: {source: file, path: review.md}
pattern: "\\n#+[^\\n]*inline[^\\n]*\\n(?:(?!\\n#{1,2} |\\n#+[^\\n]*(reply|rispost|summary|riassunto|sommario|question|domand))[\\s\\S])*?\\b(from err|from exc|from last|drops? the|swallows?|loses|perde|chain)"
flags: i
match: not_contains
weight: 2
---
