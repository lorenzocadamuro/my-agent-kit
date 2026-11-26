---
type: regex
target: {source: file, path: review.md}
pattern: "(?:\\n#+|\\n\\*\\*)[^\\n]*(summary|riassunto|sommario)[^\\n]*\\n(?:(?!\\n#|\\n\\*\\*)[\\s\\S])*?\\b(fixed|over-?refunds?|resolved|resolving|flagged|addressed)\\b"
flags: i
match: not_contains
weight: 2
---
