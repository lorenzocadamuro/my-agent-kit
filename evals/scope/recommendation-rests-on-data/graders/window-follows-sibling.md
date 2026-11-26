---
type: regex
target: {source: file, path: plan.md}
pattern: '\n\|\s*[AD]\d+\s*\|(?=[^\n]*(check_import_quota|imports/quota|import))(?=[^\n]*(rolling|mobil|scorrevol|24\s*(h\b|ore|hours)|ultime 24|last 24))(?=[^\n]*(come|like|\bas\b|same|stess|segu|follow|allinea|align|coerent|consistent|default|predefinit|mirror|riusa|reuse|già|already|match|corrispond|\buses?\b|\busa\b|sibling|gemell))'
flags: i
weight: 2
---
