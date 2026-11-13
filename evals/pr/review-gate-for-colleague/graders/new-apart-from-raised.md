---
type: regex
target: {source: file, path: review.md}
pattern: "\\b(\\d+|one|two|three|four|uno|una|due|tre|quattro)\\s+(new\\s+)?(blocks?|findings?|issues?|points?|problemi|rilievi|blocchi)\\s+(are|is|sono)\\s+(new|nuov[oaie])\\b|\\b(\\d+|one|two|three|four)\\s+new\\s+(blocks?|findings?|issues?|points?)|\\b(due|tre|quattro)\\s+(nuovi|nuove)\\s+(finding|rilievi|problemi|blocchi)|(no one|nobody|not yet)\\s+(has\\s+)?raised|nessuno\\s+(ha\\s+)?(ancora\\s+)?(sollevat|segnalat)|non\\s+(l[aeio]\\s+)?ha\\s+(ancora\\s+)?(sollevat|segnalat)\\w*\\s+nessuno"
flags: i
weight: 3
---
