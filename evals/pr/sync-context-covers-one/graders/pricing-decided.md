---
type: regex
target:
  source: file
  path: decision.md
pattern: "pricing\\.py[^\\n]*(non (ancora )?risolt|irrisolt|unresolved|not (yet )?resolved|in attesa|your decision|tua decisione|da decidere|to be decided|\\bstop\\b|mi fermo)"
match: not_contains
flags: i
weight: 2
---
