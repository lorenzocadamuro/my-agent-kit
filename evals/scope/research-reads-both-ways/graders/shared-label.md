---
type: regex
target: {source: file, path: plan.md}
pattern: "(status_label|labels\\.py|label helper|shared label)[^\\n]{0,200}((?<![/\\w])shared(?![/\\w])|condivis|also (read|used)|anche (da|la|nella)|flag[- ]off|classic)|((?<![/\\w])shared(?![/\\w.])|condivis|flag[- ]off|classic)[^\\n]{0,200}(status_label|labels\\.py|label helper)"
flags: i
weight: 3
---
