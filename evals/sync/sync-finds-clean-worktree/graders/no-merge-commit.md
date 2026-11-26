---
type: regex
target: trace
pattern: "\"command\":\"(?:[^\"\\\\]|\\\\.)*?git\\s+(?:-C\\s+\\S+\\s+)?commit\\b"
match: not_contains
weight: 1
---
