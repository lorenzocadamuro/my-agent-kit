---
type: regex
target:
  source: file
  path: decision.md
pattern: "\\b(Pros?|Vantagg\\w*|A favore)\\b.*\\b(Contro|Cons?|Svantagg\\w*)\\b.*\\b(Pros?|Vantagg\\w*|A favore)\\b.*\\b(Contro|Cons?|Svantagg\\w*)\\b"
flags: is
weight: 2
---
