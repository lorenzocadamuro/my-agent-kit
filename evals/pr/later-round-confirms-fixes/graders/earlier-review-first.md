---
type: regex
target: {source: file, path: review.md}
pattern: "\\n#+[^\\n]*(precedent|previous|last|ultim|scorsa|since|earlier|cambiat|changed)[^\\n]*\\n[\\s\\S]*?(?<!un)(?<!non )(\\brisolt|\\bfixed|\\bresolved)[\\s\\S]*?\\n#+[^\\n]*scenario"
flags: i
weight: 3
---
