---
type: regex
target: {source: file, path: plan.md}
pattern: "(status_label|labels\\.py)[\\s\\S]{0,400}(classic|flag[- ]off|off path|unchanged|boundary|confine|spent|today)|(classic|flag[- ]off|boundary|confine)[\\s\\S]{0,400}(status_label|labels\\.py)"
flags: i
weight: 3
---
