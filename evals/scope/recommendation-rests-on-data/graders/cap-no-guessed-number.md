---
type: regex
target: {source: file, path: plan.md}
pattern: '\n\|\s*[AD]\d+\s*\|[^|\n]*\|[^|\n]*\|[^|\n]*(\b\d{1,4}\s*(run|esecuzion|avvi|scheduled|pianificat|/\s*(giorno|day|utente|user|24\s*h)|al giorno|per (day|giorno|utente|user)|a day|al dì|daily|giornalier|ogni 24)|(default|predefinit\w*|valore iniziale|initial value|start(ing)? (at|with)|partire da)\s*:?\s*`?\d{1,4}\b|(cap|limite|tetto|limit|provvisori\w*|provisional\w*|iniziale|initial)\D{0,15}\b\d{1,4}\b(?!\s*(h\b|ore|hours|giorni|days|settiman|weeks|%)))'
match: not_contains
flags: i
weight: 2
---
