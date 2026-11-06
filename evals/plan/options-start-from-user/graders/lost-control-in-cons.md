---
type: regex
target: {source: file, path: questions.md}
pattern: '(?:\bfast\b|\b2[- ]credit|\b2 credit)(?:(?!\n#|\n\*\*[A-D][.)])[\s\S]){0,600}?(?:\b(?:cons|contro|svantaggi?)\b|\bcon\s*:)[^\n]*?(?:\n[ \t]*[-*+][^\n]*?){0,3}?(?:(?:\blos[et]\b|\bloses\b|no longer|cannot|can.t|non (?:\w+ )?più|non (?:può|puo|possono|potr\w*|sceglie|scelgono|decide\w*)|\bperd\w*|\btolt\w*|\btogli\w*|takes? away|overrid\w*|ignor\w*|scavalc\w*|replac\w*|sostitu\w*|\bforz\w*|\bforc\w*|senza poter\w*|without\b)[^\n]*?(?:model|modello|cost limit|limit\b|limite|scelt\w*|choice|choos\w*|pick\w*|settings?|impostazion\w*|control\w*)|(?:model|modello|cost limit|limit\b|limite|scelt\w*|choice|choos\w*|pick\w*|settings?|impostazion\w*|control\w*)[^\n]*?(?:\blos[et]\b|\bloses\b|no longer|cannot|can.t|non (?:\w+ )?più|non (?:può|puo|possono|potr\w*|sceglie|scelgono|decide\w*)|\bperd\w*|\btolt\w*|\btogli\w*|takes? away|overrid\w*|ignor\w*|scavalc\w*|replac\w*|sostitu\w*|\bforz\w*|\bforc\w*|senza poter\w*|without\b))'
flags: im
weight: 1
---
