---
type: regex
target: {source: file, path: kit-data/state/acme-shop-feature.json}
pattern: "\\{(?=[^{}]*\"label\"\\s*:\\s*\"Checkout[^\"]*\")(?=[^{}]*\"status\"\\s*:\\s*\"failed\")[^{}]*\\}"
weight: 3
---
