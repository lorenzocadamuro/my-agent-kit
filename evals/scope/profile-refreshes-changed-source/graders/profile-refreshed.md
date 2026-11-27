---
# The CI file changed since the profile recorded it: the profile's test command follows it.
type: regex
target: {source: file, path: kit-data/projects/acme-shop.md}
pattern: "Targeted tests[^\\n]*pnpm vitest run"
weight: 2
---
