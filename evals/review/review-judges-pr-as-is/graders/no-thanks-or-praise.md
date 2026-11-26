---
type: regex
target: {source: file, path: review.md}
pattern: "\\b(thanks?|thank you|grazie|nice|great|good job|well done|love|appreciate[ds]?|kudos)\\b"
flags: i
match: not_contains
weight: 3
---
