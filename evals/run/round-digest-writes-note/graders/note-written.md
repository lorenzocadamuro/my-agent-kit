---
type: regex
target: {source: file, path: kit-data/suite-log.md}
pattern: "\\n## \\d{8}-\\d{2} [^\\n]*\\n(?:(?!\\n## )[\\s\\S])*rounding mode"
flags: i
weight: 2
---
