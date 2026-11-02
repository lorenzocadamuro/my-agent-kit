---
type: regex
target: {source: file, path: kit-data/study/page.md}
pattern: "(?:^### \\d+\\.[\\s\\S]*?){6}"
flags: m
match: not_contains
weight: 1
---
