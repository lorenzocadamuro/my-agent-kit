---
type: regex
target: {source: file, path: plan.md}
pattern: '\n\|\s*[AD]\d+\s*\|[^|\n]*\|[^|\n]*\|(?=[^|\n]*(measur|misur|observ|osserv|metric|usage|dati d.uso|dati reali|real data|contar|conteggi))(?=[^|\n]*(uncapped|no cap|senza (un |alcun |nessun )?(cap|limite|tetto)|without (a |any )?(cap|limit)|log[- ]only|shadow|solo (log|conteggio|misura)|before (setting|choosing|picking|fixing)|prima di (fissare|scegliere|decidere|mettere)|then (pick|set|choose|decide)|poi (si )?(fiss|scegli|decid)|(per|for) (due|2|qualche|alcuni|two|a few) (giorni|days)|(from|dai|dalle|dalla|sulla base de\w*|based on)( [\w-]+){0,3} (measur|misur|dati|data)|measur(e|ing) only|no number (now|yet)|nessun numero (ora|per ora)))'
flags: i
weight: 3
---
