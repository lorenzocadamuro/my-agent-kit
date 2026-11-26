---
type: regex
target: {source: file, path: plan.md}
pattern: "[`*_]{0,2}Files[`*_]{0,2}:(?:(?![ \\t]*(?:- )?[`*_]{0,2}Searches)[^\\n]*\\n){0,8}?(?![ \\t]*(?:- )?[`*_]{0,2}Searches)[^\\n]*(order_total_with_tax|list_orders)"
match: contains
weight: 2
---
