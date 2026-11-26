---
type: regex
target: {source: file, path: plan.md}
pattern: "(30 ?s\\b|30[- ]second|30 second|30 secondi|gateway)[^\\n]{0,300}(retr|attempt|tentativ|backoff)|(retr|attempt|tentativ|backoff)[^\\n]{0,300}(30 ?s\\b|30[- ]second|30 secondi|gateway)"
flags: i
weight: 1
---
