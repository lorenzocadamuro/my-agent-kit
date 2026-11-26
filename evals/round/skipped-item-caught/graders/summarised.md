---
type: regex
target: last_message
pattern: "\\|\\s*Item\\s*\\|\\s*State\\s*\\|\\s*Commit\\s*\\|\\s*Note\\s*\\||\\|\\s*[12]\\s*\\|\\s*done\\s*\\|\\s*(c0ffee1|e5f6a7b)\\s*\\|"
flags: i
match: not_contains
weight: 1
---
