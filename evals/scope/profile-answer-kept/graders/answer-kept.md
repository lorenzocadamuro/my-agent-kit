---
# The lint command is the user's own answer: it stays until the user says yes.
type: regex
target: {source: file, path: kit-data/projects/acme-shop.md}
pattern: "Lint / format[^\\n]*npm run lint"
weight: 2
---
