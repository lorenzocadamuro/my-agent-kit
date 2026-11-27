---
type: regex
target: {source: file, path: review.md}
pattern: "\\b(\\d+|one|two|three|four|uno|una|due|tre|quattro)\\s+(new\\s+)?(blocks?|findings?|issues?|points?|problemi|rilievi|blocchi|punti)(\\s+(?!(che|that|which|where)\\b)[^\\s.,;:]+){0,3}?(?<!\\b(non|not))\\s+(are|is|sono)\\s+(new|nuov[oaie])\\b|\\b(\\d+|one|two|three|four)\\s+new\\s+(blocks?|findings?|issues?|points?)|\\b(due|tre|quattro)\\s+(nuovi|nuove)\\s+(finding|rilievi|problemi|blocchi)|(no one|nobody|not yet)\\s+(has\\s+)?raised|nessuno\\s+(l[aeio]\\s+)?(ha\\s+)?(ancora\\s+)?(sollevat|segnalat)|non\\s+(l[aeio]\\s+)?ha\\s+(ancora\\s+)?(sollevat|segnalat)\\w*\\s+nessuno|\\b(\\d+|one|two|three|four|five|six|seven|eight|nine|ten|uno|una|due|tre|quattro|cinque|sei|sette|otto|nove|dieci)\\s+((findings?|rilievi|problemi|blocchi|blocks?|punti|issues?|points?|note|notes|domande|questions?)(/[^\\s.,;:]+)?\\s+)?(nuovi|nuove|new)\\b(?!\\s+(commits?|files?|righe|lines?)\\b)"
flags: i
weight: 3
---
