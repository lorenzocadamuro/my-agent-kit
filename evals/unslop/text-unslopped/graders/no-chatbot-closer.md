---
# unslop rule 20: no chatbot phrases. The input closes with "Let me know if you have any questions."; fails when out.md keeps that closer or another offer of more help.
type: regex
target: {source: file, path: out.md}
pattern: "\\blet me know\\b|\\bhope this helps\\b|\\bhappy to\\b|\\bfeel free\\b|\\bany (?:other |further |more )?questions\\b"
flags: i
match: not_contains
weight: 1
---
