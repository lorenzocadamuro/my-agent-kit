---
type: regex
target: {source: file, path: review.md}
pattern: "\\b(COMMENT|APPROVE|REQUEST_CHANGES)\\b|\\b(Comment|Approve|Request changes|Commento|Approva|Richiedi modifiche|Richiesta di modifiche)\\b[^\\n]{0,100}([Rr]ecommend|[Cc]onsigli|[Rr]accomand)|([Rr]ecommend|[Cc]onsigli|[Rr]accomand)[^\\n]{0,100}\\b(Comment|Approve|Request changes|Commento|Approva|Richiedi modifiche)\\b"
weight: 3
---
