---
type: regex
target: {source: file, path: questions.md}
pattern: '^#{1,4}[ \t]*\**[ \t]*Q\d+\b(?:[^\n]*?(?:\bgoal|obiettiv|\bboundary|\bconfin[ei]\b|\bbar\b|bar for done|\bcriteri[oa]?\b|\bbudget|\binvariant|out of scope|fuori (?:dallo )?scope)|[^\n]*\n(?:(?![^\n]*\?)[^\n]*\n){0,7}[^\n?]*?(?:\bgoal|obiettiv|\bboundary|\bconfin[ei]\b|\bbar\b|bar for done|\bcriteri[oa]?\b|\bbudget|\binvariant|out of scope|fuori (?:dallo )?scope)[^\n]*\?)'
match: not_contains
flags: im
weight: 3
---
