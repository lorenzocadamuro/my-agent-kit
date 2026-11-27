---
# The reply asks whether to take CI's new lint command, naming it.
type: regex
target: last_message
pattern: "biome[\\s\\S]*\\?|\\?[\\s\\S]*biome"
flags: i
weight: 2
---
