---
type: regex
target: {source: file, path: wt/.plans/plan.md}
pattern: "\\n## Existing vs new behaviour(?:(?!\\n## )[\\s\\S])*?\\n\\|[^\\n]*reus[^\\n]*\\|[^\\n]*\\|[^\\n]*(24 ?h|24 hours|24 ore|within a day)[^\\n]*\\|"
flags: i
weight: 2
---
