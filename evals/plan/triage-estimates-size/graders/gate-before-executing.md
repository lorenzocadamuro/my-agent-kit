---
type: regex
target: {source: file, path: report.md}
pattern: "^(?=[\\s\\S]*(~|≈|circa |about )\\d+[^\\n]*(righe|lines))(?=[\\s\\S]*(\\b(split|divid\\w*)\\b[^\\n]*(\\?|recommended|consigliat\\w*|raccomandat\\w*|\\bgate\\b)|\\bgate\\b[^\\n]*\\b(split|budget|size|dimension\\w*)\\b))"
flags: i
weight: 3
---
