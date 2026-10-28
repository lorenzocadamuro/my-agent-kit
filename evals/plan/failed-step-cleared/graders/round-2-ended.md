---
type: regex
target: {source: file, path: kit-data/state/acme-shop-feature.json}
pattern: "\\{(?=[^{}]*\"n\"\\s*:\\s*2\\b)(?=[^{}]*\"endedAt\"\\s*:\\s*\"[^\"]+\")[^{}]*\\}"
weight: 2
---
