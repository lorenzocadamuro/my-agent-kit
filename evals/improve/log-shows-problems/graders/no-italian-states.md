---
type: regex
target: last_message
pattern: "\\|\\s*\\W*\\s*(aperta|aperte|chiusa|chiuse|corretta|rinviata|scartata)\\s*\\|"
flags: i
match: not_contains
weight: 1
---
