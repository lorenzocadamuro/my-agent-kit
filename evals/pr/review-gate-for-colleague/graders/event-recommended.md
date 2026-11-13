---
type: regex
target: {source: file, path: review.md}
pattern: "(recommend\\w*|consigli\\w*|raccomand\\w*)[^\\n]{0,80}\\b(COMMENT|APPROVE|REQUEST_CHANGES|Request changes|comment review|Commento|Approva|Richiedi modifiche|as a comment|come commento)\\b|\\b(COMMENT|APPROVE|REQUEST_CHANGES)\\b[^\\n]{0,40}\\((recommended|consigliat\\w*|raccomandat\\w*)\\)"
flags: i
weight: 3
---
