---
type: regex
target: {source: file, path: review.md}
pattern: "\\b(once|after|when|until|as soon as)\\s+(the\\s+)?(base|stack|#20|acme/pay#20|pr\\s*#?20)|\\b(base|#20)(\\s+pr)?\\s+(lands|merges|is merged|has merged|merging|landing|is in\\b)"
flags: i
match: not_contains
weight: 3
---
