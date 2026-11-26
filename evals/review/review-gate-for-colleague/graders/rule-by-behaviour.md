---
type: regex
target: {source: file, path: review.md}
pattern: "(feature gate|feature flag|flags\\.enabled|default[- ]off|off by default)[^\\n]{0,200}(block|missing|without|not behind|manca|senza|nessun)|(block|missing|without|unconditionally|not behind|manca|senza|no feature)[^\\n]{0,200}(feature gate|feature flag|flags\\.enabled|default[- ]off|off by default)"
flags: i
weight: 3
---
