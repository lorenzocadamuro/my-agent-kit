---
type: regex
target: {source: file, path: review.md}
pattern: "suggested order|ordine suggerito|split (this PR|it) into|re-?land (this|it) as|please (re-?land|split)|dividila in|spezzala in"
flags: i
match: not_contains
weight: 2
---
