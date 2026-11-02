---
type: regex
target: {source: file, path: summary.md}
pattern: "((togliere|rinunciare|drop|senza|remove|togli\\w*|rimuov\\w*|elimin\\w*|rinunci\\w*)[^\\n]{0,80}\\bpop\\b|lascia\\w*[^\\n]{0,40}\\bpop\\b[^\\n]{0,40}fuori)[\\s\\S]{0,400}?(goal|obiettivo|dashboard)"
flags: i
weight: 2
---
