---
type: regex
target: {source: file, path: wt/.plans/round-2.md}
pattern: "(remov\\w*|drop\\w*|delet\\w*|revert\\w*|comment\\w* out|skip\\w*|without|omit\\w*|ignor\\w*)[^\\n]{0,80}(cover\\w*|save\\w*)[^\\n]{0,40}(check|clause|condition|test|guard)?[^\\n]{0,100}\\b(fail|fails|failing|goes red|turns red)\\b"
flags: i
weight: 2
---
