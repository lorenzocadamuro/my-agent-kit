---
type: regex
target: {source: file, path: questions.md}
pattern: '(?:^#{1,4}[ \t]*\**[ \t]*Q\d+\b[\s\S]*?){9}'
match: not_contains
flags: m
weight: 2
---
