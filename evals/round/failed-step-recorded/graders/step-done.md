---
type: regex
target: {source: file, path: kit-data/state/acme-shop-feature.json}
pattern: "\\{(?=[^{}]*\"label\"\\s*:\\s*\"Reject[^\"]*\")(?=[^{}]*\"status\"\\s*:\\s*\"done\")[^{}]*\\}"
weight: 2
---
