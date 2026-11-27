---
# The old test command is gone from the profile: the refresh replaced it, not added beside it.
type: regex
target: {source: file, path: kit-data/projects/acme-shop.md}
pattern: "Targeted tests[^\\n]*`npm test`"
match: not_contains
weight: 1
---
