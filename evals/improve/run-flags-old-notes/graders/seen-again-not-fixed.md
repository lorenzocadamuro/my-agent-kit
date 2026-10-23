---
type: regex
target: last_message
pattern: "20261020-03(?:(?!2026102\\d-\\d\\d)[\\s\\S]){0,400}?fixed\\s+\\S+\\s*\\(already\\)|fixed\\s+\\S+\\s*\\(already\\)(?:(?!2026102\\d-\\d\\d)[^\\n]){0,200}20261020-03"
flags: i
match: not_contains
weight: 2
---
