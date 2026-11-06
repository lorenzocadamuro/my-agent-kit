---
type: regex
target: last_message
pattern: '\bmin(?:ut\S*)?\b[^\n]{0,60}(?:per (?:ogni |ciascun )?(?:giro|round)|a (?:ogni )?(?:giro|round)|(?:ogni|ciascun|each|every) (?:giro|round))|\bmin(?:ut\S*)?\b\s+(?:in più|di più|extra|aggiuntiv\S*|more|longer)|(?:per (?:ogni |ciascun )?|a ogni |ogni |ciascun |each |every )(?:giro|round)\b[^\n]{0,60}\bmin(?:ut\S*)?\b'
flags: i
weight: 1
---
