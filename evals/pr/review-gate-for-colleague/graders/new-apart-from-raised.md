---
type: regex
target: {source: file, path: review.md}
pattern: "\\b(\\d+|one|two|three|four|uno|una|due|tre|quattro)\\s+(new|nuov[oaie])\\b|\\b(are|is|sono)\\s+(new|nuov[oaie])\\b|\\bnew\\b[^\\n]{0,40}(findings?|issues?|blocks?)[^\\n]{0,80}(no one|nobody|not (yet )?raised|beyond|besides|apart from|already)|nuov[ie][^\\n]{0,80}(non (ancora )?segnalat|oltre|rispetto|già)"
flags: i
weight: 3
---
