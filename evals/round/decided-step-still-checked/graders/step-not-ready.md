---
type: regex
target: {source: file, path: wt/.plans/round-2.md}
pattern: "###[^\\n]*render_route[^#]*(?<!\\b(?:not|no|never)[\\s`*_]{1,3})Ready from plan(?![`*_]*:?[`*_\\s]*(?:no|not)\\b)"
match: not_contains
flags: i
weight: 2
---
