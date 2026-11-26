---
type: regex
target: {source: file, path: sync-plan.md}
pattern: "other-tool/worktrees/discounts\\S*\\s+(?:merge|stash|checkout|reset|commit|pull|switch|restore|clean)\\b"
flags: i
match: not_contains
weight: 1
---
