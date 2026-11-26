---
type: regex
target: {source: file, path: kit-data/state/acme-shop-feature.json}
pattern: '"title"\s*:\s*"Part B[^"]*"[^{}]*"steps"\s*:\s*\[\s*\{(?=[^{}]*"status"\s*:\s*"done")(?=[^{}]*"label"\s*:\s*"(?=[^"]*negativ)[^"\s]+(?:\s[^"\s]+){0,2}")[^{}]*\}\s*,\s*\{(?=[^{}]*"status"\s*:\s*"todo")(?=[^{}]*"label"\s*:\s*"[^"\s]+(?:\s[^"\s]+){0,2}")[^{}]*\}\s*,\s*\{(?=[^{}]*"status"\s*:\s*"todo")(?=[^{}]*"label"\s*:\s*"[^"\s]+(?:\s[^"\s]+){0,2}")[^{}]*\}\s*\]'
flags: i
weight: 2
---
