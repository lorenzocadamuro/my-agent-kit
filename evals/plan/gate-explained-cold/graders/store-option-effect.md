---
type: regex
target: {source: file, path: summary.md}
pattern: "STORE_POP[\\s\\S]{0,600}?(worker|iad1)[\\s\\S]{0,300}?(non |not |wrong|sbagliat|fuorviant|un.unica regione|one region|single|sola regione)"
flags: i
weight: 2
---
