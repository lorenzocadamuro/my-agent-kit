---
type: regex
target: last_message
pattern: "\\*{0,2}(?:Pros?|Vantagg\\w*)\\*{0,2}\\s*:[\\s\\S]{0,600}?\\*{0,2}(?:Contro|Cons?|Svantagg\\w*)\\*{0,2}\\s*:"
flags: i
match: not_contains
weight: 1
---
