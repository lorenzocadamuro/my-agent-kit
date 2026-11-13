---
type: regex
target: {source: file, path: review.md}
pattern: "suggested order|ordine suggerito|can you (please )?(re-?land|split)|could you (please )?(re-?land|split)|please (re-?land|split)|puoi (dividere|spezzare|separare)|potresti (dividere|spezzare|separare)"
flags: i
match: not_contains
weight: 2
---
