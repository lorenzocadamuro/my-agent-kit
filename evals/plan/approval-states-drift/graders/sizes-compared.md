---
type: regex
target: last_message
pattern: "(ticket|asked|chiede|richiest)[^\\n]{0,200}(one[- ]line|\\b1 (line|riga)|una riga|\\d+ (lines|righe))[\\s\\S]{0,400}(plan|piano)[^\\n]{0,200}~? ?\\d+ ?(\\+|-|–)? ?\\d* ?(lines|righe|production lines)"
flags: i
weight: 3
---
