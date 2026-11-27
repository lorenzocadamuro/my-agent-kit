---
# Findings come back as proposed notes: nothing is saved to the suite log before the user's yes.
type: regex
target: {source: file, path: kit-data/suite-log.md}
pattern: "^## "
flags: m
match: not_contains
weight: 2
---
