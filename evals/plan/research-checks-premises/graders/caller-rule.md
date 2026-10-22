---
type: regex
target: {source: file, path: plan.md}
pattern: "(sync\\.py|import_from_drive)[\\s\\S]{0,500}(skip|silent|drop|scart|salt|perd|lost|loss|ignor)"
flags: i
weight: 2
---
