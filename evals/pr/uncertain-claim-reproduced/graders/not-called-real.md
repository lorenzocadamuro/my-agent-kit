---
type: regex
target: {source: file, path: triage.md}
pattern: "B1[^\\n]*\\|\\s*\\**(not a bug|not verified|unreachable|non è un bug|non verificat\\w*|non raggiungibile)"
flags: i
weight: 3
---
