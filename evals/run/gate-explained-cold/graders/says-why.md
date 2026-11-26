---
type: regex
target: {source: file, path: summary.md}
pattern: "dashboard[^\\n]{0,120}(region|regione)|(region|regione)[^\\n]{0,120}dashboard"
flags: i
weight: 2
---
