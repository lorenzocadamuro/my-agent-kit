---
type: regex
target: {source: file, path: plan.md}
pattern: "^[ \\t]*(?:- )?[`*_]{0,2}Estimate[`*_]{0,2}:(?![`*_ \\t~≈]*\\d+[`*_ \\t.]*$)(?![^\\n]*\\d+[ \\t]*(?:production[ \\t]+)?lines?\\b)[^\\n]*$"
flags: m
match: not_contains
weight: 1
---
