---
type: regex
target: {source: file, path: report.md}
pattern: "^(?=[\\s\\S]*(~|≈|circa |about )\\d+[^\\n]*(righe|lines))(?=[\\s\\S]*(\\b(split|divid\\w*)\\b[^\\n]*(\\?|recommended|(?<!\\b(?:un|il|del|nel|al|dal|questo|quel|mio|tuo|suo)\\s+)consigli[ao]\\b|consigliat\\w*|raccomand\\w*|suggerisc\\w*|recommend\\w*|\\bgate\\b)|\\bgate\\b[^\\n]*\\b(split|budget|size|dimension\\w*)\\b))"
flags: i
weight: 3
---
