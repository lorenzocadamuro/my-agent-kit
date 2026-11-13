---
type: regex
target: {source: file, path: questions.md}
pattern: "(^|\\n)(#{1,4}\\s*|\\*\\*)(Q|D|Domanda |Question )?1\\b(?:(?!\\n#{1,4} |\\n\\*\\*(Q|D|Domanda |Question )?2\\b)[\\s\\S])*?(this PR|questa PR|same PR|stessa PR|later PR|PR success|separate PR|PR separat|follow-up PR|first PR|prima PR|which (items|parts)|quali (parti|voci)|in scope|nello scope|\\bscope\\b|perimetro|split the ticket|dividere il ticket|alone and first|da sola e per prima)"
flags: i
weight: 3
---
