---
type: regex
target: {source: file, path: out.md}
pattern: "[—–]|[A-Za-z0-9.,)`] -{1,2} [A-Za-z0-9(`]"
match: not_contains
weight: 1
---
