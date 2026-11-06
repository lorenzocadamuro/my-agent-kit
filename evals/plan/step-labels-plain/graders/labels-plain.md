---
type: regex
target: {source: file, path: kit-data/state/acme-shop-feature.json}
pattern: "\"label\"\\s*:\\s*\"[^\"]*(?:[a-z][a-z0-9]*[A-Z]|[A-Z][a-z0-9]+[A-Z][a-z]|[A-Za-z0-9]_[A-Za-z0-9]|[A-Za-z0-9]\\.[a-z]{1,4}\\b|`|[()]|\\b(?:ts|tsx|js|py)\\b)"
match: not_contains
weight: 3
---
