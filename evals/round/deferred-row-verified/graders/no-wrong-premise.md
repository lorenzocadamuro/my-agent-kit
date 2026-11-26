---
type: regex
target: {source: file, path: wt/.plans/round-4.md}
pattern: "^(?![^\\n]*\\b(not|never|no|unverified|wrong|incorrect|instead|false|mistaken\\w*|misread|corrected|correction|drop\\w*|removed?|stale|does ?n.t|did ?n.t|isn.t|wasn.t)\\b)[^\\n]*realtime"
match: not_contains
flags: im
weight: 3
---
