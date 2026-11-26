---
type: regex
target: {source: file, path: questions.md}
pattern: '^#{1,4}[ \t]*\**[ \t]*Q\d+(?:[^\n]*\n){0,2}?[^\n]*?\bR(?:2|4|6|8|10|12)\b[\s\S]*?\n#{1,4}[ \t]*\**[ \t]*Q\d+(?:[^\n]*\n){0,2}?[^\n]*?\bR(?:2|4|6|8|10|12)\b'
match: not_contains
flags: m
weight: 2
---
