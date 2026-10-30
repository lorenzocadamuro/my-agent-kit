---
type: regex
target: {source: file, path: wt/.plans/round-2.md}
pattern: "^(?![\\s\\S]*###\\s*\\d+\\.[^\\n]*(currency|Part E))|(Part E|currency)[^\\n]{0,300}\\b(because|perché|reason|why)\\b|\\b(because|perché|reason|why)\\b[^\\n]{0,300}(Part E|currency)"
flags: i
weight: 2
---
