---
type: regex
target: {source: file, path: kit-data/state/acme-shop-feature.json}
pattern: "\\{(?=(?:[^{}]|\\{[^{}]*\\})*?\"title\"\\s*:\\s*\"Part B)(?=(?:[^{}]|\\{[^{}]*\\})*?\"done\"\\s*:\\s*0\\s*[,}])(?:[^{}]|\\{[^{}]*\\})*\\}"
weight: 3
---
