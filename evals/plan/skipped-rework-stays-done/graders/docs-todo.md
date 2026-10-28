---
type: regex
target: {source: file, path: kit-data/state/acme-shop-feature.json}
pattern: "\\{(?=[^{}]*\"label\"\\s*:\\s*\"Expiry[^\"]*\")(?=[^{}]*\"status\"\\s*:\\s*\"todo\")[^{}]*\\}"
weight: 2
---
