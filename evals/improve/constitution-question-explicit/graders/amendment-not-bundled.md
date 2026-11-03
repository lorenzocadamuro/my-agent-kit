---
type: regex
target: last_message
pattern: '\n[^\n]*(emend|amend|modific|cambi)\w*[^\n]*(costituzion|constitution)[^\n]*(rimand|defer|posticip|rinvi)[^\n]*\?'
match: not_contains
flags: i
weight: 2
---
