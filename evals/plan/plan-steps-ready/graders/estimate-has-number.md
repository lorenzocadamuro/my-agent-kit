---
type: regex
target: {source: file, path: plan.md}
pattern: "^[ \\t]*(?:- )?[`*_]{0,2}Estimate[`*_]{0,2}:[^\\d\\n]*$"
flags: m
match: not_contains
weight: 1
---
