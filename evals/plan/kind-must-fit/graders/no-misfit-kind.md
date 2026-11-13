---
type: regex
target: {source: file, path: questions.md}
pattern: "K31[^\\n]*(Recommended|raccomandat|consigliat)|(Recommended|raccomandat|consigliat)[^\\n]*K31(?![^\\n]{0,160}(weak|not (a )?(clear )?fit|does ?n.t (clearly )?fit|does not apply|doesn.t apply|neighbo|non (si )?applica|non calza|debole))"
flags: i
match: not_contains
weight: 3
---
