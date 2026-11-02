---
type: regex
# 26 words on one line with no ".", "?" or "!" between them: a sentence over ITE's 25 words.
pattern: '(?:[^\s.?!]+[ \t]+){25}[^\s.?!]+'
match: not_contains
weight: 1
---
