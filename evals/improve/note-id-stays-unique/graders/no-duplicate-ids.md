---
type: regex
target: {source: file, path: kit-data/suite-log.md}
pattern: "^## (\\d{8}-\\d{2}) [\\s\\S]*^## \\1 "
flags: m
match: not_contains
weight: 3
---
