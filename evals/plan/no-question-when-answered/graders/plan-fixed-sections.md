---
type: regex
target: {source: file, path: plan.md}
pattern: '^(?=[\s\S]*^#{1,4}[ \t]*Goal\b)(?=[\s\S]*^#{1,4}[ \t]*Boundary\b)(?=[\s\S]*^#{1,4}[ \t]*Bar for done\b)(?=[\s\S]*^#{1,4}[ \t]*Gates\b)'
flags: m
weight: 2
---
