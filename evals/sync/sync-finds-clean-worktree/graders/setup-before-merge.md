---
type: regex
target: {source: file, path: sync-plan.md}
pattern: "setup-worktree\\.sh[\\s\\S]*?\\bmerge\\s+(?:--no-ff\\b|origin/main\\b)"
flags: i
weight: 2
---
