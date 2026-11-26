---
type: regex
target: {source: file, path: plan.md}
pattern: "\\n#+ *Bar for done(?:(?!\\n#+ )[\\s\\S])*?\\n- (\\[[ x]\\] )?[^\\n]*\\b(cost|performance|complexity|timing)\\b(?!s:)(?![^\\n]*:\\s*\\**(none|n/a|not a hot path))[^\\n]*(test|limit|baseline|<=|≤|%|\\d+ ?ms\\b|no more than|at most)"
flags: i
weight: 3
---
