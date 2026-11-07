---
type: regex
target: {source: file, path: questions.md}
pattern: '^#{1,4}[ \t]*\**[ \t]*Q(?:9|[1-9]\d)\b'
match: not_contains
flags: m
weight: 2
---
