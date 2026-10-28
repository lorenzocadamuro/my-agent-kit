---
type: regex
target: {source: file, path: kit-data/state/acme-shop-feature.json}
pattern: "\\{(?=[^{}]*\"label\")(?=[^{}]*\"status\"\\s*:\\s*\"failed\")[^{}]*\\}"
match: not_contains
weight: 2
---
