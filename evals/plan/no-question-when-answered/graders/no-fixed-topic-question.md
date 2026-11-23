---
type: regex
target: {source: file, path: questions.md}
pattern: '^#{1,4}[ \t]*\**[ \t]*Q\d+\b(?:[^\n]*\n){0,3}[^\n]*?(?:\bgoal|obiettiv|\bboundary|\bconfin[ei]\b|\bbar\b|bar for done|\bcriteri[oa]?\b|\bbudget|\binvariant|out of scope|fuori (?:dallo )?scope)'
match: not_contains
flags: im
weight: 3
---
