---
type: regex
target: {source: file, path: kit-data/projects/acme-shop.md}
pattern: "Lint / format[^\\n]*biome"
match: not_contains
weight: 1
---
