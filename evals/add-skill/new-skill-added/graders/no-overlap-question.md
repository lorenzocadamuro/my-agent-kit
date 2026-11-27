---
# No existing skill does this job: the reply does not ask whether to integrate, improve or add.
type: regex
target: last_message
pattern: "\\bintegrat"
flags: i
match: not_contains
weight: 1
---
