---
type: regex
target: {source: file, path: review.md}
pattern: "\\n#+[^\\n]*(precedent|previous|last review|ultima review|scorsa|since|earlier)[^\\n]*\\n[\\s\\S]*?(risolt|fixed|resolved)[\\s\\S]*?\\n#+[^\\n]*scenario"
flags: i
weight: 3
---
