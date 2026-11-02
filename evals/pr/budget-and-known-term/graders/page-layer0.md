---
type: regex
target: {source: file, path: kit-data/study/page.md}
pattern: "(?<![\\s\\S])(?:(?:(?!\\n## )[\\s\\S])*\\n)?## [^\\n]*\\n(?=(?:(?!\\n## )[\\s\\S])*?\\d+(?:[^\\S\\n]+\\S+){0,2}[^\\S\\n]*(?:blocking|bloccant))(?:(?!\\n## )[\\s\\S]){0,1200}(?:\\n## |$)"
flags: i
weight: 1
---
