---
# The candidate does what /my:sync does: the reply asks whether to integrate, improve or add.
type: regex
target: last_message
pattern: "integrat[\\s\\S]*\\?|\\?[\\s\\S]*integrat"
flags: i
weight: 2
---
