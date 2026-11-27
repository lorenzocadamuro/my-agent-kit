---
# The new skill ends with its Reply: line (skill-template.md; check.sh requires it).
type: regex
target: {source: file, path: kit/skills/pr/todo-sweep/SKILL.md}
pattern: "^\\**Reply:"
flags: m
weight: 1
---
