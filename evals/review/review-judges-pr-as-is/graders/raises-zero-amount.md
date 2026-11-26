---
type: regex
target: {source: file, path: review.md}
pattern: "\\bzero\\b|ge=0|gt=0|\\bpositive\\b|€\\s?0|0\\.00|amount(_cents)?\\s*(==|<=|=)\\s*0\\b|\\b0\\s*(cents|amount)"
flags: i
weight: 2
---
