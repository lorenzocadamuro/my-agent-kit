---
type: regex
target: {source: file, path: plan.md}
pattern: "\\b401\\b|login\\.sh|(login|session)[^\\n]{0,80}(expired|scadut)|(expired|scadut)[^\\n]{0,80}(login|session)"
flags: i
weight: 2
---
