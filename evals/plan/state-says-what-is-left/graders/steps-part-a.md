---
type: regex
target: {source: file, path: kit-data/state/acme-shop-feature.json}
pattern: '"title"\s*:\s*"Part A[^"]*"[^{}]*"steps"\s*:\s*\[\s*\{(?=[^{}]*"status"\s*:\s*"done")[^{}]*\}(?:\s*,\s*\{(?=[^{}]*"status"\s*:\s*"done")[^{}]*\})*\s*\]'
weight: 1
---
