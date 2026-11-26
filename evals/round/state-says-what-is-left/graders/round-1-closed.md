---
type: regex
target: {source: file, path: kit-data/state/acme-shop-feature.json}
pattern: '"rounds"\s*:\s*\[\s*\{(?=[^{}]*"n"\s*:\s*1\s*[,}])(?=[^{}]*"endedAt"\s*:\s*"[^"]+")(?=[^{}]*"verdict"\s*:\s*"[^"]*[^"\s][^"]*")[^{}]*\}'
weight: 1
---
