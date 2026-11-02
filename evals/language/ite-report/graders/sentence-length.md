---
type: regex
# 26 words on one line with no ".", "?" or "!" between them: a sentence over ITE's 25 words. A table row
# (a line that starts with "|") holds cells, not a sentence, and is skipped.
pattern: '^(?![ \t]*\|).*?(?:[^\s.?!]+[ \t]+){25}[^\s.?!]+'
flags: m
match: not_contains
weight: 1
---
