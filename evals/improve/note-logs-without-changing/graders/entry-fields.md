---
type: regex
target: {source: file, path: kit-data/suite-log.md}
pattern: "^(?=[\\s\\S]*^- Expected:[ \\t]*\\S)(?=[\\s\\S]*^- Suspected cause:[ \\t]*\\S)(?=[\\s\\S]*^- Signal:[^\\n]*question re-asked)"
flags: m
weight: 1
---
