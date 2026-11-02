---
type: regex
target: {source: file, path: report.md}
pattern: "^(?=[\\s\\S]*(~|≈|circa |about )\\d+[^\\n]*(righe|lines))(?=[\\s\\S]*(\\b(split|divid\\w*)\\b[^\\n]*(?:\\?|\\bgate\\b|recommended|(?<!\\b(?:un|il|del|nel|al|dal|questo|quel|mio|tuo|suo)\\s+)consigli[ao]\\b|consigliat\\w*|raccomand\\w*|suggerisc\\w*|recommend\\w*)|\\b(split|divid\\w*)\\b[^\\n]*(?:\\n[^\\n]*){0,2}?(?:recommended|(?<!\\b(?:un|il|del|nel|al|dal|questo|quel|mio|tuo|suo)\\s+)consigli[ao]\\b|consigliat\\w*|raccomand\\w*|suggerisc\\w*|recommend\\w*)|\\bgate\\b[^\\n]*\\b(split|budget|size|dimension\\w*)\\b))"
flags: i
weight: 3
---
