---
# While the question on the user's lint command waits, the recorded hash of the changed source
# stays the old one, so the next check reports it again (no --record before the answer).
type: regex
target: {source: file, path: kit-data/projects/acme-shop.md}
pattern: "`\\.github/workflows/ci\\.yml`: `9ecd7c1c5e0c73e056c0e97efcc88fa6d1efd156`"
weight: 1
---
