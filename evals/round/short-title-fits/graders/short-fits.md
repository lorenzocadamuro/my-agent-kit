---
type: regex
target: {source: file, path: kit-data/state/acme-shop-feature.json}
pattern: "\"short\"\\s*:\\s*\"[^\"]{17,}\""
match: not_contains
weight: 3
---
