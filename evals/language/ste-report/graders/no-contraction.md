---
type: regex
# Straight and curly apostrophes.
pattern: '\b\w+n[''’]t\b|\b(I|you|we|they|it|that|there|what|let)[''’](s|re|ve|ll|d|m)\b'
flags: i
match: not_contains
weight: 1
---
