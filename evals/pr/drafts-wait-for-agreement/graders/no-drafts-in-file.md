---
type: regex
target: {source: file, path: review.md}
pattern: "\\n#+[^\\n]*(inline comments?|comment drafts?|review summary|questions for the author|summary to publish)"
flags: i
match: not_contains
weight: 3
---
