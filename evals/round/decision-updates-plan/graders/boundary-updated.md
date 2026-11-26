---
type: regex
target: {source: file, path: wt/.plans/plan.md}
pattern: "\\n## Boundary\\s*\\n(?:(?!\\n## )[\\s\\S])*?(24 ?h|24 hours|24 ore|within a day)"
flags: i
weight: 2
---
